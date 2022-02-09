import { LightningElement, api } from 'lwc';
import identity_document_img from '@salesforce/resourceUrl/identity_document_test';

export default class ProposalAnalysis extends LightningElement {

  @api accountid

  myText = "1 \n <br/> Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

  isAnalysisStarted = false
  startDate = ''

  // Info about progress ring variants
  generalInfoVariant = ''
  personalInfoVariant = ''
  contactInfoVariant = ''
  addressesInfoVariant = ''

  // Info about progress ring value
  generalInfoValue = ''
  personalInfoValue = ''
  contactInfoValue = ''
  addressesInfoValue = ''

  // Checkboxes Values
  value = [];
  preValue = [];

  // Info about Modal
  openModalReason = false;
  modalReasonTitle = '';
  modalReasonField = '';

  openModalDocument = false;
  sourceImg = '';
  cpf_document = identity_document_img;

  // Info about the buttons
  isAllApproved = false
  isAnyPending = false
  isAnyRejected = false

  handleChangeCheckbox(event) {

    this.checksOnlyOne(event)
    this.setInfoValueAndVariant(event)
    
    this.isCompleted(event)
  }

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name
    let currentCheckboxValue = event.currentTarget.value

    // console.log({currentCheckbox})
    // console.log({currentCheckboxValue})

    this.template.querySelectorAll('input[name='+currentCheckbox+']').forEach(elem => {
      let oldValue = elem.getAttribute('data-value')
      let newValue = currentCheckboxValue

      if(oldValue !== null && elem.value === oldValue) {
        elem.checked = false
        newValue = ''
        
      } else if(elem.value === currentCheckboxValue) {
        newValue = currentCheckboxValue
        elem.checked = true
      }
      elem.setAttribute('data-value', newValue)

      if (event.target.checked && (currentCheckboxValue == 'reprovado' || currentCheckboxValue == 'pendenciado'))
      {
        this.modalReasonTitle = (currentCheckboxValue == 'reprovado') ? 'Motivo da reprovação' : 'Motivo do pendenciamento';
        this.openModalReason = true;
        this.modalReasonField = currentCheckbox;
      }
      
      // console.log(elem.value + ' '+ elem.checked)
    })
  }

  setInfoValueAndVariant(event) {
    let returnedId = event.target.closest("div[data-id]").getAttribute("data-id")

    let info = this.getPercentage(event, returnedId)

    if (returnedId === 'dadosPessoaisContainer') {
      this.personalInfoVariant = info.variant
      this.personalInfoValue = info.value  
    }

    else if (returnedId === 'generalContainer') {
      this.generalInfoVariant = info.variant
      this.generalInfoValue = info.value  
    }

    else if (returnedId === 'dadosContatoContainer') {
      this.contactInfoVariant = info.variant
      this.contactInfoValue = info.value  
    }

    else if (returnedId === 'dadosEndereçoContainer') {
      this.addressesInfoVariant = info.variant
      this.addressesInfoValue = info.value  
    }
  }

  getPercentage(event, returnedId) {
    
    let myDiv = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let allCheckboxes = (myDiv.querySelectorAll('input[type="checkbox"]').length) / 3
    let selectedCheckboxes = myDiv.querySelectorAll('input[type="checkbox"]:checked')

    let isPending = false
    let isRejected = false

    let infoVariant = ''
    let infoValue = ''

    let info = {}

    // console.log({allCheckboxes})
    // console.log({selectedCheckboxes})
    // console.log({returnedId})
    // console.log(myDiv)

    selectedCheckboxes.forEach(element => {
      console.log(element.value)

      if (element.value === 'aprovado') {
        infoVariant = 'base-autocomplete'
      }

      else if (element.value === 'pendenciado') {
        isPending = true
      }

      else if (element.value === 'reprovado') {
        isRejected = true
      }
    })
    
    if (isPending && !isRejected) infoVariant = 'warning'
    if (isRejected) infoVariant = 'expired'
    
    infoValue = (selectedCheckboxes.length / allCheckboxes) * 100
    
    selectedCheckboxes = 0;

    info.variant = infoVariant
    info.value = infoValue
  
    return info
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


  handleClick() {
    
  }

  handleDocumentModal(event) {
    console.log('opened modal')
    this.sourceImg = event.target.getAttribute('data-id');
    this.openModalDocument = true;
  }

  handleAccordionToggle(event) {
    
    // console.log(event.target.classList)

    // console.log(event.target.parentElement.classList)
    // console.log(event.target.previousSibling)

    // let sectionPersonal = event.target.getElement('data-id')
    // this.template.querySelector('#' + sectionPersonal).toggle('slds-is-open')

    if (this.isAnalysisStarted) {
      event.target.parentElement.parentElement.parentElement.classList.toggle('slds-is-open')
    }

  }

  handleAnalysisStart() {
    this.isAnalysisStarted = true

    let myDate = new Date()
    this.startDate = this.formatDate(myDate)
  }

  isCompleted(event) {
    let topComponent = this.template.querySelector('[data-id="top-component"]')
    
    let allCheckboxes = (topComponent.querySelectorAll('input[type="checkbox"]').length) / 3
    let selectedCheckboxes = topComponent.querySelectorAll('input[type="checkbox"]:checked')

    let approveBtn = this.template.querySelector('[data-id="approve-btn"]')
    let pendingBtn = this.template.querySelector('[data-id="pending-btn"]')
    let rejectBtn = this.template.querySelector('[data-id="reject-btn"]')

    let isApproved = false
    let isPending = false
    let isRejected = false

    // let isApproved = selectedCheckboxes.every(function (element) {
    //   return element.value === 'aprovado'
    // })

    // isPending = selectedCheckboxes.some(function(element) { return element.value === 'pendenciado'})
    // isRejected = selectedCheckboxes.some(function(element) { return element.value === 'reprovado'})

    selectedCheckboxes.forEach(element => {
      
      if (element.value === 'aprovado') {
        isApproved = true
      }

      else if (element.value === 'pendenciado') {
        isApproved = false
        isPending = true
      }

      else if (element.value === 'reprovado') {
        isApproved = false
        isPending = false
        isRejected = true
      }
    })
    
    let totalPercentage = 0

    totalPercentage = (selectedCheckboxes.length)/(allCheckboxes) * 100

    console.log({totalPercentage})

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
      console.log('desabilitou')
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
}