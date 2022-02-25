import { LightningElement, api } from 'lwc';
import identity_document_img from '@salesforce/resourceUrl/identity_document_test';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

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

  // Info about progress ring value
  generalInfoValue = 0
  personalInfoValue = 0
  contactInfoValue = 0
  addressesInfoValue = 0

  // Info about Modal
  openModalReason = false;
  modalReason = '';
  modalReasonField = '';
  modalReasonObject = ''
  validationResult = new Map();

  openModalDocument = false;
  sourceImg = '';
  cpf_document = identity_document_img;

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
    // this.mapInfoSection.set('dadosGeral', {'variant': 'base-autocomplete', 'value': 33, 'returnedId': 'dadosGeral'})
    this.mapInfoSection.set('ContainerDadosPessoais', {'variant': '', 'value': 0, 'returnedId': 'ContainerDadosPessoais'})
  }

  setInfoValueAndVariant(event) {
    
    let infoSection = event.detail

    this.mapInfoSection.set(infoSection.returnedId, JSON.parse(JSON.stringify(infoSection)))

    console.log(this.mapInfoSection)
    
    if (infoSection.returnedId === 'ContainerDadosPessoais') {
      this.personalInfoVariant = infoSection.variant
      this.personalInfoValue = infoSection.value

      if (infoSection.modal && Object.keys(infoSection.modal).length !== 0) {
        this.modalReason = infoSection.modal.modalReason
        this.openModalReason = infoSection.modal.openModalReason
        this.modalReasonField = infoSection.modal.fieldReason
        this.modalReasonObject = infoSection.modal.objectReason
      
      }
    }

    else if (infoSection.returnedId === 'generalContainer') {
      this.generalInfoVariant = infoSection.variant
      this.generalInfoValue = infoSection.value  
    }

    else if (infoSection.returnedId === 'dadosContatoContainer') {
      this.contactInfoVariant = infoSection.variant
      this.contactInfoValue = infoSection.value  
    }

    else if (infoSection.returnedId === 'dadosEndereçoContainer') {
      this.addressesInfoVariant = infoSection.variant
      this.addressesInfoValue = infoSection.value  
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

    // console.log({percentageSections})
    // console.log({ totalPercentage })
    
    // console.log(typeof totalPercentage)

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
  handlerCloseModalReason(){
    this.openModalReason = false;
  }

  handleSaveSection() {
    console.log('saves')
  }
  handlerSelectedReason(event){
    let result = event.detail;
    if(result){
      this.validationResult.set(result.field, JSON.parse(JSON.stringify(result)));
    }
    console.log(this.validationResult);
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

    console.log('open sections:', openSections.length)
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