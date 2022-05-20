import { LightningElement, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange  } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';

import OPP_REASON_FIELD from '@salesforce/schema/Opportunity.CommitteeReason__c';
import OPP_OTHER_REASON_FIELD from '@salesforce/schema/Opportunity.CommitteeOtherReason__c';
import OPP_OBSERVATION_FIELD from '@salesforce/schema/Opportunity.CommitteeObservation__c';

import finishAnalysis from '@salesforce/apex/ProposalIntegrationController.finishAnalysis';
import startAnalysis from '@salesforce/apex/ProposalController.createNewInstance';

const fields = [STAGENAME_FIELD, OPP_REASON_FIELD, OPP_OTHER_REASON_FIELD, OPP_OBSERVATION_FIELD];

const PROPOSAL_APPROVED = 'approved';
const PROPOSAL_PENDENCY = 'pendency';
const PROPOSAL_REJECTED = 'rejected';

const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT = 'error';

const SUCCESS_OCCURRED = 'Sucesso';
const SUCCESS_MESSAGE = 'Análise da proposata enviada com sucesso!';
const SUCCESS_VARIANT = 'success';

export default class ProposalAnalysis extends LightningElement {

  @api accountid
  @api opportunityid
  
  isStageWaitingForUE = false
  isStageInAnalysis = false
  isAnalysisStarted = false
  isStageWaitingForCommittee = false
  isStageOnCommittee = false
  isLoading = false
  
  startDate = ''
  openSection = false;
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
  enableCommiteeButton = true;
  committeeReasons = []
  committeeOtherReasons = ''
  committeeObservation = ''

  sectionComponentMap = new Map([
    ["ContactDetailsSection__c", "c-proposal-contact-data-component"],
    ["PersonalDataSection__c", "c-proposal-personal-data-component"],
    ["AddressDataSection__c", "c-proposal-addresses-component"],
    ["WarrantyDataSection__c", "c-proposal-warranty-component"],
    ["IncomeDataSection__c", "c-proposal-income-data-component"],
    ["OperationSection__c", "c-proposal-operation-component"]
  ])

  connectedCallback() {
    this.mapInfoSection.set('ContainerDadosPessoais', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosPessoais'})
    this.mapInfoSection.set('ContainerDadosContato', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosContato'})
    this.mapInfoSection.set('ContainerDadosEndereco', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosEndereco'})
    this.mapInfoSection.set('ContainerDadosGarantia', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosGarantia'})
    this.mapInfoSection.set('ContainerOperation', {'variant': '', 'value': 0, 'returnedId': 'ContainerOperation'})
    this.mapInfoSection.set('ContainerDadosRenda', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosRenda'})
  }

  @wire(getRecord, { recordId: '$opportunityid', fields })
  getOpportunity({ error, data }) {
    if (data) {
      
      this.getStageName(data)
      this.getCommitteeReasons(data)

    } else if (error) {
      this.showToast(ERROR_OCCURRED, 'Houve um erro ao buscar a oportunidade.', ERROR_VARIANT);
    }
  }

  getCommitteeReasons(data) {
    console.log({data})
    this.committeeReasons = data?.fields?.CommitteeReason__c?.displayValue.split(';')
    this.committeeOtherReasons = data?.fields?.CommitteeOtherReason__c?.value
    this.committeeObservation = data?.fields?.CommitteeObservation__c?.value

    console.log(this.committeeOtherReasons)
    console.log(this.committeeObservation)
  }

  getStageName(data) {
    let stageName = data?.fields?.StageName?.value
      
      if (stageName === 'Aguardando Análise de Formalização') {
        this.isStageWaitingForUE = true
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageOnCommittee = false
      }

      else if (stageName === 'Aguardando Distribuição para Comitê de Formalização') {
        this.isStageWaitingForUE = true
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.isStageOnCommittee = false
      }
      
      else if (stageName === 'Em Análise de Formalização') {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = true
        this.showCommitteeButton = true;
        this.openSection = true;
      }
      
      else if (stageName === 'Aguardando Análise de Comitê de Formalização') {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
        this.openSection = false;
        this.isStageWaitingForCommittee = true
        this.isStageOnCommittee = false
      }
        
      else if (stageName === 'Em Análise de Comitê de Formalização') {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = true
        this.showCommitteeButton = false;
        this.openSection = true;
        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = true;
      }
        
      else {
        this.isStageWaitingForUE = false
        this.isAnalysisStarted = false
        this.showCommitteeButton = false;
      }
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

    this.isCompleted()
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
      event.target.parentElement.parentElement.parentElement.classList.toggle('slds-is-open')
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
    fields[STAGENAME_FIELD.fieldApiName] = 'Em Análise de Comitê de Formalização';

    const recordField = {fields}

    updateRecord(recordField)
      .then(() => {
        this.showToast(SUCCESS_OCCURRED, 'Stage Alterado com sucesso!', SUCCESS_VARIANT)
        this.isStageWaitingForCommittee = false
        this.isStageOnCommittee = true
        this.isLoading = false
      })
      .catch(error => {
        this.showToast(ERROR_OCCURRED, 'Houve um erro na alteração do stage', ERROR_VARIANT)
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
      this.showToast(SUCCESS_OCCURRED, 'Stage Alterado com sucesso!', SUCCESS_VARIANT);
        this.isAnalysisStarted = true;
        this.isLoading = false
    })
    .catch( error =>{
      console.log({ error });
      this.isAnalysisStarted = false;
      this.showToast(ERROR_OCCURRED, 'Houve um erro na alteração do stage', ERROR_VARIANT);
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
      
      this.enableCommiteeButton = false;
      this.statusAnalysis = result;
    }
    else {
      approveBtn.disabled = true
      pendingBtn.disabled = true
      rejectBtn.disabled = true
      this.enableCommiteeButton = true;
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
}