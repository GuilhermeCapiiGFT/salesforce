import { LightningElement, api } from 'lwc';
export default class ProposalAnalysis extends LightningElement {

  @api accountid
  @api opportunityid

  isAnalysisStarted = false
  startDate = ''

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
  openModalComite = false
  isAnalysisComplete = false
  
  // Info about the buttons
  isAllApproved = false
  isAnyPending = false
  isAnyRejected = false

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