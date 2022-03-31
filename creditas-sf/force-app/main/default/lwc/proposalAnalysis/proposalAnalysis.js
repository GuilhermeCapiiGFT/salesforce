import { LightningElement, api } from 'lwc';

const quickLinks = [
  {label : 'Crivo', url: 'https://creditas-crivo.crivo.com.br/Login.aspx?ReturnUrl=%2Fresultado.aspx%3Flogs%3D2682204&logs=2682204'},
  {label : 'BrFlow', url: 'https://www.brflow.com.br/autenticacao/autenticacao/login'},
  {label : 'Receita Federal', url: 'https://servicos.receita.fazenda.gov.br/Servicos/CPF/ConsultaSituacao/ConsultaPublica.asp'},
  {label : 'Checktudo', url: 'https://www.checktudo.com.br/'},
  {label : 'Emailage', url: 'https://app.emailage.com/query'},
  {label : 'Data Trust', url: 'https://datatrust.clearsale.com.br/#/'},
  {label : 'DENATRAM', url: 'https://portalservicos.senatran.serpro.gov.br/#/consultas/veiculo'},
  {label : 'Zapay', url: 'https://usezapay.com.br/creditas'},
  {label : 'OITI - Visualizar', url: 'https://www.certiface.com.br:8443/certifacepainel/#/dashboard'},
  {label : 'OITI - Enviar', url: 'https://www.certiface.com.br/tokensms/certifacetoken/oiti'}
]
export default class ProposalAnalysis extends LightningElement {

  @api accountid
  @api opportunityid

  isAnalysisStarted = false
  startDate = ''

  // Info sections
  mapInfoSection = new Map()
  sectionQuickLinks = quickLinks;

  // Info about progress ring variants
  generalInfoVariant = ''
  personalInfoVariant = ''
  contactInfoVariant = ''
  addressesInfoVariant = ''
  warrantyInfoVariant = ''

  // Info about progress ring value
  generalInfoValue = 0
  personalInfoValue = 0
  contactInfoValue = 0
  addressesInfoValue = 0
  warrantyInfoValue = ''

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
  openModalComite = false
  isAnalysisComplete = false
  
  // Info about the buttons
  isAllApproved = false
  isAnyPending = false
  isAnyRejected = false

  connectedCallback() {
    this.mapInfoSection.set('ContainerDadosPessoais', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosPessoais'})
    this.mapInfoSection.set('ContainerDadosContato', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosContato'})
    this.mapInfoSection.set('ContainerDadosEndereco', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosEndereco'})
    this.mapInfoSection.set('ContainerDadosGarantia', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosGarantia'})
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
    this.isAnalysisStarted = true

    let myDate = new Date()
    this.startDate = this.formatDate(myDate)
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

      if (isApproved) {
        approveBtn.disabled = false
        pendingBtn.disabled = true
        rejectBtn.disabled = true
      }
      if (isPending) {
        approveBtn.disabled = true
        pendingBtn.disabled = false
        rejectBtn.disabled = true
      }
      if (isRejected) {
        approveBtn.disabled = true
        pendingBtn.disabled = true
        rejectBtn.disabled = false
      }
    }

    else {
      approveBtn.disabled = true
      pendingBtn.disabled = true
      rejectBtn.disabled = true
    }
  }

  handlerCloseDocumentModal(){
    this.openModalDocument = false;
  }

  handleSaveSection() {
  }

  handlerSelectedReason(event){
    let result = event.detail;
    if(result){
      this.validationResult.set(result.field, JSON.parse(JSON.stringify(result)));

      if(result.object =='ContactDetailsSection__c'){
        this.template.querySelector('c-proposal-contact-data-component').getReasonSelected(JSON.stringify(result));
      }

      else if (result.object == 'PersonalDataSection__c') {
        this.template.querySelector('c-proposal-personal-data-component').getReasonSelected(JSON.stringify(result));
      }
        
      else if (result.object == 'AddressDataSection__c') {
        this.template.querySelector('c-proposal-addresses-component').getReasonSelected(JSON.stringify(result));
      }

      else if (result.object == 'WarrantyDataSection__c') {
        this.template.querySelector('c-proposal-warranty-component').getReasonSelected(JSON.stringify(result));
      }

    }
    this.openModalReason = false;
  }

  handleComiteProposal() {
    this.openModalComite = true
  }

  handlerCloseModalComite() {
    this.openModalComite = false
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
    this.isAnalysisComplete = true

    let openSections = this.template.querySelectorAll("section")
    let approveBtn = this.template.querySelector('[data-id="approve-btn"]')

    openSections.forEach(section => {
      section.classList.remove('slds-is-open')
    })

    approveBtn.disabled = true
  }

  handlerAnalysisPending() {
    this.isAnalysisComplete = true

    let openSections = this.template.querySelectorAll("section")
    let pendingBtn = this.template.querySelector('[data-id="pending-btn"]')

    openSections.forEach(section => {
      section.classList.remove('slds-is-open')
    })

    pendingBtn.disabled = true
  }
}