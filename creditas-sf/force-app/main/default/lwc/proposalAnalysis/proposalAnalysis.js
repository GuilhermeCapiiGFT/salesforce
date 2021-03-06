import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import OWNER_ID_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import CONTRACT_NUMBER_FIELD from '@salesforce/schema/Opportunity.CCBnumber__c';
import OPP_REASON_FIELD from '@salesforce/schema/Opportunity.CommitteeReason__c';
import OPP_OTHER_REASON_FIELD from '@salesforce/schema/Opportunity.CommitteeOtherReason__c';
import OPP_OBSERVATION_FIELD from '@salesforce/schema/Opportunity.CommitteeObservation__c';
import OPP_EXTERNALID_FIELD from '@salesforce/schema/Opportunity.ExternalId__c';
import finishAnalysis from '@salesforce/apex/ProposalIntegrationController.finishAnalysis';
import startAnalysis from '@salesforce/apex/ProposalController.createNewInstance';
import sendContract from '@salesforce/apex/ProposalContractController.sendContract';
import generateContract from '@salesforce/apex/ProposalContractController.generateContract';
import viewContract from '@salesforce/apex/ProposalContractController.viewContract';
import { subscribe } from 'lightning/empApi';
import generalDataSection from '@salesforce/resourceUrl/generalDataSection';
import operationDataSection from '@salesforce/resourceUrl/operationDataSection';
import addressDataSection from '@salesforce/resourceUrl/addressDataSection';
import contactDetailDataSection from '@salesforce/resourceUrl/contactDetailDataSection';
import incomeDataSection from '@salesforce/resourceUrl/incomeDataSection';
import othersDataSection from '@salesforce/resourceUrl/othersDataSection';
import personalDataSection from '@salesforce/resourceUrl/personalDataSection';
import warrantyDataSection from '@salesforce/resourceUrl/warrantyDataSection';

const APPROVED = 'APPROVED';
const COMPLETED = 'COMPLETE';
const PENDING = 'PENDING';
const REJECTED = 'REJECTED';
const VARIANT_BASE = 'base';
const VARIANT_BASE_COMPLETE = 'base-autocomplete';
const VARIANT_EXPIRED = 'expired';
const VARIANT_WARNING = 'warning';

const VARIANTBYSTATUS = {
  [COMPLETED]: { status: VARIANT_BASE_COMPLETE, priority : 0 },
  [APPROVED] : { status: VARIANT_BASE, priority: 10 },
  [PENDING] : { status: VARIANT_WARNING, priority: 100 },
  [REJECTED]  : { status: VARIANT_EXPIRED, priority : 200 }

}
const fields = [
  STAGENAME_FIELD, 
  OWNER_ID_FIELD, 
  OPP_REASON_FIELD, 
  OPP_OTHER_REASON_FIELD, 
  OPP_OBSERVATION_FIELD, 
  OPP_EXTERNALID_FIELD,
  CONTRACT_NUMBER_FIELD
];

const PROPOSAL_APPROVED = 'approved';
const PROPOSAL_PENDENCY = 'pending';
const PROPOSAL_REJECTED = 'rejected';

const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE  = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT  = 'error';

const SUCCESS_OCCURRED = 'Sucesso';
const SUCCESS_MESSAGE  = 'An??lise da proposta enviada com sucesso!';
const SUCCESS_STAGE_MESSAGE  = 'Stage alterado com sucesso!';
const SUCCESS_VARIANT = 'success';

const STATUS_WAITING_UE = 'Aguardando An??lise de Formaliza????o';
const STATUS_WAITING_DISTRIBUTION = 'Aguardando Distribui????o para Comit?? de Formaliza????o';
const STATUS_IN_ANALYSIS_UE = 'Em An??lise de Formaliza????o';
const STATUS_WAITING_COMMITTEE = 'Aguardando An??lise de Comit?? de Formaliza????o';
const STATUS_IN_ANALYSIS_COMMITTEE = 'Em An??lise de Comit?? de Formaliza????o';

const STATUS_WAITING_CONTRACT = 'Aguardando emiss??o de contrato';
const STATUS_EMITED_CONTRACT = 'Contrato emitido';

export default class ProposalAnalysis extends LightningElement {

  @api accountid
  @api opportunityid

  channelName = '/event/AutoFinContractUpdate__e';
  disableBtnGenerateContract = false;
  disableBtnViewContract = true;
  disableBtnSendContract = true;
  disableBtnCorrectContract = false;
  dateContract = '';
  isStageWaitingForUE = false
  isStageInAnalysis = false
  isAnalysisStarted = false
  isStageWaitingForCommittee = false
  isStageOnCommittee = false
  isLoading = false
  openSection = false;
  startDate = '';
  showContractGenerated = false;
  

  @api
  get disabled(){
    return !this.openSection;
  }

  //sections fields
  @track allSectionsComplete = false;
  @track generalDataField;
  @track operationDataField;
  @track addressDataField;
  @track incomeDataField;
  @track contactDataField;
  @track othersDataField;  
  @track overallStatus = '';
  @track disableActionButton = {
    [APPROVED] : true,
    [COMPLETED] : true,
    [REJECTED] : true,
    [PENDING]  : true
  };
  @track overallVariantType = '';
  @track personalDataField;
  @track warrantyDataField;
  
  // Info sections
  mapInfoSection = new Map()

  // Info about progress ring variants
  generalInfoVariant = ''
  personalInfoVariant = ''
  contactInfoVariant = ''
  addressesInfoVariant = ''
  warrantyInfoVariant = ''
  incomeInfoVariant = ''
  operationInfoVariant = ''

  // Info about progress ring value
  generalInfoValue = 0
  personalInfoValue = 0
  contactInfoValue = 0
  addressesInfoValue = 0
  warrantyInfoValue = ''
  operationInfoValue = 0
  incomeInfoValue = 0

  // Info about Modal
  openModalReason = false;
  modalReason = '';
  modalReasonField = '';
  modalReasonObject = ''
  validationResult = new Map();

  openModalDocument = false;
  sourceImg = '';

  openModalRejection = false;
  openModalPendency = false
  openModalApprove = false
  isAnalysisComplete = false
  
  // Info about the buttons
  isAllApproved = false
  isAnyPending = false
  isAnyRejected = false
  
  statusAnalysis;
  
  //Committee
  openModalCommittee = false
  showCommitteeButton = false;
  disableCommiteeButton = true;
  committeeReasons = []
  committeeOtherReasons = ''
  committeeObservation = ''

  //Contract
  openSendContractModal = false;
  showContractButton = false;
  showApproveButtons = false;

  enableContractButton = true;

  opportunityData;

  get StageName(){
    return getFieldValue(this.opportunityData, STAGENAME_FIELD);
  }

  get CCBNumber(){
    return getFieldValue(this.opportunityData, CONTRACT_NUMBER_FIELD);
  }

  get ExternalId(){
    return getFieldValue(this.opportunityData, OPP_EXTERNALID_FIELD);
  }


  sectionComponentMap = new Map([
    ["ContactDetailsSection__c", "c-proposal-contact-data-component"],
    ["PersonalDataSection__c", "c-proposal-personal-data-component"],
    ["AddressDataSection__c", "c-proposal-addresses-component"],
    ["WarrantyDataSection__c", "c-proposal-warranty-component"],
    ["IncomeDataSection__c", "c-proposal-income-data-component"],
    ["OperationSection__c", "c-proposal-operation-component"]
  ])
  sectionsStatus = new Map([
    [ "general-section"                     ,      {percentage: 0, status : "", complete : false}],
    [ "section-dados-pessoais"              ,      {percentage: 0, status : "", complete : false}],
    [ "section-3"                           ,      {percentage: 0, status : "", complete : false}],
    [ "section-4"                           ,      {percentage: 0, status : "", complete : false}],
    [ "section-6"                           ,      {percentage: 0, status : "", complete : false}],
    [ "section-7"                           ,      {percentage: 0, status : "", complete : false}],
    [ "section-8"                           ,      {percentage: 0, status : "", complete : false}],
    [ "section-9"                           ,      {percentage: 0, status : "", complete : false}]
  ]);

  handleSectionComplete ( event ) {
    try{
      this.clearButtons();
      const section = event.detail;
      const sectionStatus = {
        progress : section.progress,
        status : section.status,
        type : section.type,
        complete : section.complete,
      }
      if(this.sectionsStatus.has(section.uniquekey)){
        this.sectionsStatus.set(section.uniquekey, sectionStatus);
      }
      let allSectionsComplete = true;
      this.overallStatus = '';
      let status = '';
      let variantType = '';
      this.sectionsStatus.forEach((value, key, map) =>{
        if(value.complete){
          status = status ? status: value.status;
          allSectionsComplete &= value.complete;
          status = this.calcStatus(value.status, status);
          variantType = VARIANTBYSTATUS[value.status];

        }else {
          allSectionsComplete = false;
          status = '';
        }
      });
      if(status && allSectionsComplete){
        this.overallStatus = status
        this.statusAnalysis = status == COMPLETED? 
                              APPROVED.toLowerCase():
                              status.toLowerCase();
        this.disableCommiteeButton = false;
        this.disableActionButton[status] = false
      }
      this.overallVariantType = variantType;
      this.allSectionsComplete = allSectionsComplete;
      
    }catch(e){
      console.error(e);
    }
  
  }
  calcStatus(oldStatus, newStatus){
    return  VARIANTBYSTATUS[oldStatus].priority > VARIANTBYSTATUS[newStatus].priority?
            oldStatus : newStatus;
  }
  clearButtons = () =>{
    this.disableActionButton = {
      [APPROVED] : true,
      [COMPLETED] : true,
      [REJECTED] : true,
      [PENDING]  : true
    };
  }
  connectedCallback() {
    this.mapInfoSection.set('ContainerDadosPessoais', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosPessoais'})
    this.mapInfoSection.set('ContainerDadosContato', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosContato'})
    this.mapInfoSection.set('ContainerDadosEndereco', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosEndereco'})
    this.mapInfoSection.set('ContainerDadosGarantia', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosGarantia'})
    this.mapInfoSection.set('ContainerOperation', {'variant': '', 'value': 0, 'returnedId': 'ContainerOperation'})
    this.mapInfoSection.set('ContainerDadosRenda', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosRenda'})
    this.subscribeAutoFinContractUpdateEvent(this);

    this.buildSectionsFields();
  }

  renderedCallback(){
    this.checkCcbNumber();
  }

  @wire(getRecord, { recordId: '$opportunityid', fields })
  getOpportunity({ error, data }) {
    if (data) {
      this.opportunityData = data;
      this.getStageName(data)
      this.getCommitteeReasons(data)
      this.setContractButtonsVisibility();
    } else if (error) {
      this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
    }
  }

  getCommitteeReasons(data) {
    this.committeeReasons = data?.fields?.CommitteeReason__c?.displayValue?.split(';')
    this.committeeOtherReasons = data?.fields?.CommitteeOtherReason__c?.value
    this.committeeObservation = data?.fields?.CommitteeObservation__c?.value
  }

  getStageName(data) {
    let stageName = data?.fields?.StageName?.value
      
      if (stageName === STATUS_WAITING_UE) {
        this.isStageWaitingForUE = true
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageOnCommittee = false


        this.showContractButton = false
        this.showApproveButtons = true

        this.isStageOnCommittee = false
      }

      else if (stageName === STATUS_WAITING_DISTRIBUTION) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageWaitingForCommittee = false;
        this.isStageOnCommittee = false

        this.showContractButton = false
        this.showApproveButtons = true
      }
      
      else if (stageName === STATUS_IN_ANALYSIS_UE) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = true
        this.showCommitteeButton = true;

        this.showContractButton = false
        this.showApproveButtons = true

        this.openSection = true;
      }
      
      else if (stageName === STATUS_WAITING_COMMITTEE) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageWaitingForCommittee = true
        this.isStageOnCommittee = false

        this.showContractButton = false
        this.showApproveButtons = true

        this.openSection = false;
      }
        
      else if (stageName === STATUS_IN_ANALYSIS_COMMITTEE) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = true
        this.showCommitteeButton = false;
        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = true;

        this.showApproveButtons = true
        this.showContractButton = false

        this.openSection = true;
      }

      else if (stageName === STATUS_WAITING_CONTRACT) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;

        this.showApproveButtons = false
        this.showContractButton = true

        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = false     

        this.openSection = false;
      }

      else if (stageName === STATUS_EMITED_CONTRACT) {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;

        this.showApproveButtons = false
        this.showContractButton = true        

        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = false     

        this.openSection = false;
      }
        
      else {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = false;
        this.showApproveButtons = true
        this.showContractButton = false
      }
  }

  setContractButtonsVisibility(){    
    this.disableBtnSendContract = this.StageName == STATUS_WAITING_CONTRACT && this.CCBNumber ? false : true;
    this.disableBtnCorrectContract = this.StageName == STATUS_EMITED_CONTRACT ? true: false;
  }
  
  setInfoValueAndVariant(event) {
    let infoSection = event.detail

    this.mapInfoSection.set(infoSection.returnedId, JSON.parse(JSON.stringify(infoSection)))

    if (infoSection.returnedId === 'ContainerDadosPessoais') {
      this.personalInfoVariant = infoSection.variant
      this.personalInfoValue = infoSection.value
    }

    else if (infoSection.returnedId === 'generalContainer') {
      this.generalInfoVariant = infoSection.variant
      this.generalInfoValue = infoSection.value  
    }

    else if (infoSection.returnedId === 'ContainerDadosContato') {
      this.contactInfoVariant = infoSection.variant
      this.contactInfoValue = infoSection.value  
    }

    else if (infoSection.returnedId === 'ContainerDadosEndereco') {
      this.addressesInfoVariant = infoSection.variant
      this.addressesInfoValue = infoSection.value  
    }

    else if (infoSection.returnedId === 'ContainerDadosGarantia') {
      this.warrantyInfoVariant = infoSection.variant
      this.warrantyInfoValue = infoSection.value  
    }
    
    else if (infoSection.returnedId === 'ContainerDadosRenda') {
      this.incomeInfoVariant = infoSection.variant
      this.incomeInfoValue = infoSection.value  
    }
      
    else if (infoSection.returnedId === 'ContainerOperation') {
      this.operationInfoVariant = infoSection.variant
      this.operationInfoValue = infoSection.value  
    }

    if (infoSection.modal && Object.keys(infoSection.modal).length !== 0) {
      this.modalReason = infoSection.modal.modalReason
      this.openModalReason = infoSection.modal.openModalReason
      this.modalReasonField = infoSection.modal.fieldReason
      this.modalReasonObject = infoSection.modal.objectReason
    }

    this.closeSectionWhenIsDone(infoSection);
  }

  closeSectionWhenIsDone(infoSection) {
    
    if ( infoSection.value === 100 ) {

      this.template.querySelectorAll('section').forEach(section => {

        if ( section.getAttribute('data-id') === infoSection.returnedId ) { 

          section.classList.remove('slds-is-open');
          section.scrollIntoView(false);

      }});
    } 
  }

  formatDate(date) {
    let dt = new Date(date)

    const formatter = new Intl.DateTimeFormat('pt-BR', {
      year: 'numeric',
      month: 'numeric',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    })

    let formattedDate = formatter.format(dt)

    return formattedDate
  }

  handleDocumentModal(event) {
    this.sourceImg = event.target.getAttribute('data-id');
    this.openModalDocument = true;
  }

  handleAccordionToggle(event) {
    if (this.isAnalysisStarted && !this.isAnalysisComplete) {
       event.target.parentElement.parentElement.parentElement.classList.toggle('slds-is-open');
    }
  }

  handleAnalysisStart() {
    let myDate = new Date()
    this.startDate = this.formatDate(myDate)

    if (this.isStageWaitingForCommittee) {
      this.showCommitteeReasons()
    } 

    else if (this.isStageWaitingForUE) {
      this.start()
    }
  }

  showCommitteeReasons() {
    const fields = {}
    this.isLoading = true;

    fields[OPP_ID_FIELD.fieldApiName]    = this.opportunityid;
    fields[STAGENAME_FIELD.fieldApiName] = STATUS_IN_ANALYSIS_COMMITTEE;

    const recordField = {fields}

    updateRecord(recordField)
      .then(() => {
        this.showToast(SUCCESS_OCCURRED, SUCCESS_STAGE_MESSAGE, SUCCESS_VARIANT)
        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = true
        this.isLoading = false
      })
      .catch(error => {
        this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT)
        this.isLoading = false
        this.isStageWaitingForCommittee = true
        this.isStageOnCommittee = false
    })

  }

  start() {
    this.isLoading = true

    startAnalysis({
      accId : this.accountid,
      oppId : this.opportunityid
    })
      .then(result => {
      getRecordNotifyChange([{recordId: this.opportunityid}]);
      this.showToast(SUCCESS_OCCURRED, SUCCESS_STAGE_MESSAGE, SUCCESS_VARIANT);
        this.isAnalysisStarted = true;
        this.isLoading = false
        this.openSection = true;
    })
    .catch( error =>{
      console.log({ error });
      this.isAnalysisStarted = false;
      this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
      this.isLoading = false
    })
  }
  
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

  isCompleted() {
    let approveBtn = this.template.querySelector('[data-id="approve-btn"]')
    let pendingBtn = this.template.querySelector('[data-id="pending-btn"]')
    let rejectBtn = this.template.querySelector('[data-id="reject-btn"]')

    let isApproved = false
    let isPending = false
    let isRejected = false

    let percentageSections = 0

    this.mapInfoSection.forEach((item) => {

      percentageSections +=  item.value

      if (item.variant === 'base-autocomplete') {
        isApproved = true
      }

      else if (item.variant === 'warning') { 
        isApproved = false
        isPending = true
      }

      else if (item.variant === 'expired') {
        isApproved = false
        isPending = false
        isRejected = true
      }
    })

    let totalPercentage = 0

    totalPercentage = (percentageSections) / this.mapInfoSection.size

    if (totalPercentage == '100') {
      let result = '';
      if (isApproved) {
        approveBtn.disabled = false
        pendingBtn.disabled = true
        rejectBtn.disabled = true
        result = PROPOSAL_APPROVED;
      }
      if (isPending) {
        approveBtn.disabled = true
        pendingBtn.disabled = false
        rejectBtn.disabled = true
        result = PROPOSAL_PENDENCY;
      }
      if (isRejected) {
        approveBtn.disabled = true
        pendingBtn.disabled = true
        rejectBtn.disabled = false
        result = PROPOSAL_REJECTED;
      }
      
      this.disableCommiteeButton = false;
      this.statusAnalysis = result;
    }
    else {
      approveBtn.disabled = true
      pendingBtn.disabled = true
      rejectBtn.disabled = true
      this.disableCommiteeButton = false;
    }
  }

  handlerCloseDocumentModal(){
    this.openModalDocument = false;
  }

  handlerSelectedReason(event) {
    let result = event.detail;
    if(result) {
      this.validationResult.set(result.field, JSON.parse(JSON.stringify(result)));

      if (this.sectionComponentMap.has(result.object)) {
        this.template.querySelector(this.sectionComponentMap.get(result.object)).getReasonSelected(JSON.stringify(result));
      }

    }
    this.openModalReason = false;
  }

  handleCommitteeProposal() {
    this.openModalCommittee = true   
  }

  handlerCloseModalCommittee() {
    this.openModalCommittee = false
  }

  handlerRejectProposal(){
    this.openModalRejection = true;
  }

  handlerCloseModalRejection(){
    this.openModalRejection = false;
  }

  handlerApproveProposal() {    
    this.openModalApprove = true
       
  }

  handlerCloseModalApprove(){
    this.openModalApprove = false;
  }

  handlerPendencyProposal() {
    this.openModalPendency = true
  }

  handlerCloseModalPendency() {
    this.openModalPendency = false
  }

  handlerAnaylisApprovement() {
    this.handlerCloseModalApprove();    
    const fields = {}   
    fields[OPP_ID_FIELD.fieldApiName]    = this.opportunityid;
    fields[CONTRACT_NUMBER_FIELD.fieldApiName] = "";
    
    const recordInput = {fields}

    updateRecord(recordInput)
      .then(() => {
        this.showToast(SUCCESS_OCCURRED, SUCCESS_MESSAGE, SUCCESS_VARIANT)
        this.showApproveButtons = true
        this.showCommitteeButton = false
        this.showContractButton = true 
      })
      .catch(error => {
        this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT)
        this.showApproveButtons = true
        this.showCommitteeButton = false
        this.showContractButton = false 
    }) 
    this.sendAnalysis('approve-btn');
  }

  handlerAnalysisPendency() {
    this.handlerCloseModalPendency();
    this.sendAnalysis('pending-btn');
  }

  handlerAnalysisReject() {
    this.handlerCloseModalRejection();
    this.sendAnalysis('reject-btn');
  }


  handleViewContract() {
    viewContract({ loanApplicationId: 'LAP-B9BBE976-49B1-4992-8747-00518E59202C' })
      .then(result => {
        let downloadLink = document.createElement("a");
        downloadLink.href = "data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,"+result;
        downloadLink.download = "Contrato.docx";
        downloadLink.click();
        (result != '') ? this.previewHandler(result) : this.dispatchShowToast('Warning', 'Contrato n??o localizado!', 'warning');;
      }).catch(error => {
        console.log('Erro: ' + error);
      });
  }


  handleGenerateContract(){
      this.disableBtnGenerateContract = true;
      this.disableBtnViewContract = false;
      this.disableBtnCorrectContract = false;

      let dateNow = new Date();
      let splitDate = new Intl.DateTimeFormat('pt-BR', { dateStyle: 'short'}).format(dateNow);
      let splitHours = new Intl.DateTimeFormat('pt-BR', { timeStyle: 'short' }).format(dateNow);
      this.dateContract = splitDate +' ??s '+splitHours;
      this.showContractGenerated = true;

    generateContract({ loanApplicationId: this.ExternalId })
      .then(result => {
        this.dispatchShowToast('Success','Contrato gerado com sucesso!','success');  
      }).catch(error => {
        this.dispatchShowToast('Error','Ops! N??o conseguimos gerar o contrato.','error');
        console.log('Erro: ' + error);
      });

      
  }

  handleCorrectContract(){     
    
      this.showApproveButtons = true
      this.showContractButton = false
      this.openSection = true;

      this.isAnalysisStarted = true
      this.showCommitteeButton = true;

  }

  dispatchShowToast(title, message, variant){
      this.dispatchEvent(
          new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
          }),
      );
  }

  previewHandler(doccumentId){
      console.log(doccumentId)
      this[NavigationMixin.Navigate]({ 
          type:'standard__namedPage',
          attributes:{ 
              pageName:'filePreview'
          },
          state:{ 
              selectedRecordId: doccumentId
          }
      })
  }

  handleSendContract() {
    this.openSendContractModal = true;
  }

  handleSendContractModalReturn(event) {
    const eventType = event.detail;
    this.openSendContractModal = false;
    if (eventType == 'yes') {
      if (!this.CCBNumber) {
        this.showToast(
          'Aviso',
          'O contrato n??o foi gerado. Tente novamente mais tarde.',
          'info'
        );
        return;
      }

      if (!this.ExternalId) {
        this.showError('Id externo n??o encontrado');
        return;
      }

      sendContract({ loanApplicationId: this.ExternalId })
        .then(result => {
          if (result == 201) {
            this.showToast('Sucesso!', 'Contrato enviado com sucesso.', 'success');
            this.disableBtnSendContract = true;
            const fields = {};
            fields[OPP_ID_FIELD.fieldApiName] = this.opportunityid;
            fields[STAGENAME_FIELD.fieldApiName] = STATUS_EMITED_CONTRACT;
            updateRecord({fields})
              .catch(()=>{
                this.showError('N??o foi poss??vel atualizar a fase da oportunidade');
              })
          } else {
            this.showError('A requisi????o n??o obteve sucesso');
          }
        })
        .catch(error => {
          this.showError('N??o foi poss??vel completar a requisi????o');
        });
    }
  }

  showError(message) {
    this.showToast(
      'Erro!',
      `${message}. Entre em contato com o administrador do sistema.`,
      'error'
    );
  }

  closeSections(){
    let openSections = this.template.querySelectorAll("section");
    openSections.forEach(section => {
      section.classList.remove('slds-is-open');
    })
  }

  get isReadyForAnalysis() {
    return !this.isAnalysisStarted && (this.isStageWaitingForUE || this.isStageWaitingForCommittee)
  }

  sendAnalysis(btn_action){
    let button = this.template.querySelector("[data-id='"+ btn_action +"']");
    button.disabled = true;
    finishAnalysis({
      opportunityId : this.opportunityid,
      status : this.statusAnalysis
    })
    .then( result =>{
      if(result === 'Success'){
        this.showToast(SUCCESS_OCCURRED, SUCCESS_MESSAGE, SUCCESS_VARIANT);
        this.isAnalysisComplete = true;
        this.closeSections();
      }
      else{
        this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
        button.disabled = false;
      }
    })
    .catch( error =>{
      console.log({error});
      button.disabled = false;
      this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
    })
  }

  subscribeAutoFinContractUpdateEvent(component) {
    const callback = function (message) {
      const id = message.data?.payload?.RecordId__c;
      if (id == component.opportunityid) {
        component.notifyChange();
      }
    };

    subscribe(component.channelName, -1, callback).then(response => {
      component.subscription = response;
    });
  }  

  notifyChange() {
    getRecordNotifyChange([{ recordId: this.opportunityid }]);
  }
  
  buildSectionsFields() {

    Promise.all([
      fetch(generalDataSection),
      fetch(operationDataSection),
      fetch(addressDataSection),
      fetch(contactDetailDataSection),
      fetch(incomeDataSection),
      fetch(othersDataSection),
      fetch(personalDataSection),
      fetch(warrantyDataSection)
    ]).then(responses => Promise.all( responses.map(response => response.json() )))
      .then( result => result.forEach( sectionFields => { let propertyName = sectionFields.shift().proposalAnalysisPropertyName;
                                                          this[propertyName] = sectionFields; } ))
      .catch( error => console.error(error) );
  }

  checkCcbNumber(){
    if (this.CCBNumber != null){
      this.disableBtnGenerateContract = true;
      this.disableBtnViewContract = false;
    }
    else if (this.CCBNumber != null && this.stageName != STATUS_EMITED_CONTRACT) {
      this.disableBtnSendContract = false;
    }
    else if (this.stageName != STATUS_EMITED_CONTRACT){
      this.disableBtnCorrectContract = false;
    }
    else if (this.stageName === STATUS_EMITED_CONTRACT){
      this.disableBtnCorrectContract = true;
      this.disableBtnGenerateContract = true;
      this.disableBtnSendContract = true;
      this.disableBtnViewContract = false;
    }
  }
}