import { LightningElement, api } from 'lwc';
import identity_document_img from '@salesforce/resourceUrl/identity_document_test';

export default class ProposalAnalysis extends LightningElement {

  @api accountid

  generalVariant = ''
  personalInfoVariant = 'base-autocomplete'
  contactInfoVariant = ''
  addressesInfoVariant = ''
  value = [];
  preValue = [];

  openModalDocument = false;
  sourceImg = '';
  cpf_document = identity_document_img;

  handleChangeCheckbox(event) {

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
    })
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
    console.log(event.target.parentElement.classList)
    // console.log(event.target.previousSibling)

    // let sectionPersonal = event.target.getElement('data-id')
    // this.template.querySelector('#' + sectionPersonal).toggle('slds-is-open')

    event.target.parentElement.classList.toggle('slds-is-open')

  }

  get isCompleted() {
    //let allCheckboxes = this.template.querySelectorAll()

    // 1. pegar todas as checkboxes da seção específica e verificar se estão marcadas
    // como pegar as checkboxes apenas dessa seção que estiver sendo analisada?
    // 2. se estiverem, retorna true
  }

  handlerCloseDocumentModal(){
    this.openModalDocument = false;
  }
}