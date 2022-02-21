import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import MOTHER_FIELD from '@salesforce/schema/Account.Mother__c';
import DOCUMENT_NUMBER_FIELD from '@salesforce/schema/Account.DocumentNumber__c';
import CIVIL_STATUS_FIELD from '@salesforce/schema/Account.CivilStatus__c';
import PEP_FIELD from '@salesforce/schema/Account.PoliticallyExposed__c';
import BIRTHDATE_FIELD from '@salesforce/schema/Account.BirthDate__c';

const ACCOUNT_FIELDS = [NAME_FIELD, MOTHER_FIELD, DOCUMENT_NUMBER_FIELD, CIVIL_STATUS_FIELD, PEP_FIELD, BIRTHDATE_FIELD]

export default class ProposalPersonalDataComponent extends LightningElement {

  // Account Info
  @api accountid
  @track account
  @track error

  // Account Info Fields
  name = ''
  mother = ''
  documentNumber = ''
  civilStatus = { 'displayValue': '', 'value': '' }
  politicallyExposed
  birthdate 
 
  // Picklist options
  civilStatusOptions = []
  politicallyExposedOptions = [{ label: 'Sim', value: 'SIM' }, { label: 'Não', value: 'NÃO' }]
  
  // Checkboxes Values
  value = [];
  preValue = [];


  @wire(getRecord, { recordId: '$accountid', fields: ACCOUNT_FIELDS })
  getAccountInfo({ error, data }) {
    if (data) {
      this.account = data
      this.error = undefined
      console.log(JSON.parse(JSON.stringify(this.account)))

      let fields = this.account.fields

      this.name = fields.Name.value
      this.mother = fields.Mother__c.value
      this.documentNumber = fields.DocumentNumber__c.value
      this.civilStatus['displayValue'] = fields.CivilStatus__c.displayValue
      this.civilStatus['value'] = fields.CivilStatus__c.value
      this.politicallyExposed = fields.PoliticallyExposed__c.value
      this.birthdate = fields.BirthDate__c.value
      
    } else if (error) {
      this.error = error
      console.log('an error happened')
    }
  }

  @wire(getPicklistValues, { recordTypeId: '$account.recordTypeId', fieldApiName: CIVIL_STATUS_FIELD })
  getCivilStatusPicklist({ error, data }) {
    if (data) {
      this.civilStatusOptions = data.values
      console.log(this.civilStatusOptions)
    } else if(error) {
      console.log('erro no status civil')
    }
  }

  handleInputChange(event) {
    let sectionName = event.target.getAttribute('data-id')
    
    console.log({ sectionName })
    console.log(event.target.value)

    if (sectionName === 'civilStatusSelection') {
      // let index = event.target.selectedIndex
      // let label = event.target.options[index].text
      
      this.civilStatus['value'] = event.target.value
      // this.civilStatus['displayValue'] = label

      console.log(this.civilStatus)
    }
    
    if (sectionName === 'nameField') this.name = event.target.value
    if (sectionName === 'motherField') this.mother = event.target.value
    if (sectionName === 'documentField') this.documentNumber = event.target.value
    if (sectionName === 'pepSelection') this.politicallyExposed = event.target.value === 'SIM' ? true : false
    if (sectionName === 'birthdateField') this.birthdate = event.target.value
    

    console.log(this.birthdate)
  }

  handleSaveSection(event) {
    console.log('clicked save')

    let saveBtn = this.template.querySelector('[data-id="save-personal-data-btn"]')
    saveBtn.disabled = true

    const fields = {}

    fields[ACCOUNTID_FIELD.fieldApiName]       = this.accountid
    fields[NAME_FIELD.fieldApiName]            = this.name
    fields[MOTHER_FIELD.fieldApiName]          = this.mother
    fields[DOCUMENT_NUMBER_FIELD.fieldApiName] = this.documentNumber
    fields[CIVIL_STATUS_FIELD.fieldApiName]    = this.civilStatus.value
    fields[PEP_FIELD.fieldApiName]             = this.politicallyExposed
    fields[BIRTHDATE_FIELD.fieldApiName]       = this.birthdate
    
    const recordInput = { fields }

    console.log(recordInput)
    
    updateRecord(recordInput)
      .then(() => {
        saveBtn.disabled = false
        this.showToast('Sucesso', 'Dados Pessoais atualizado com sucesso!', 'success')
      })
      .catch(error => {
        saveBtn.disabled = false
        this.showToast('Erro', error.body.message, 'error')
      });
  }

  handleChangeCheckbox(event) {
    this.checksOnlyOne(event)
  }

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name
    let currentCheckboxValue = event.currentTarget.value

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
        this.modalReason = (currentCheckboxValue == 'reprovado') ? 'reject' : 'pendency';
        this.openModalReason = true;
        this.modalReasonField = currentCheckbox;
      }
    })

    let info = this.getPercentage(event)

    this.sendInfo(info)
  }

  sendInfo(info) {
    const selectedEvent = new CustomEvent('sendinfo', {
        bubbles    : true,
        composed   : true,
        cancelable : true,
        detail: info
    });
    this.dispatchEvent(selectedEvent);
  }

  getPercentage(event) {
    let returnedId = event.target.closest("div[data-id]").getAttribute("data-id")

    let myDiv = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let allCheckboxes = (myDiv.querySelectorAll('input[type="checkbox"]').length) / 3
    let selectedCheckboxes = myDiv.querySelectorAll('input[type="checkbox"]:checked')

    let isPending = false
    let isRejected = false

    let infoVariant = ''
    let infoValue = ''

    let info = {}

    console.log({allCheckboxes})
    console.log({selectedCheckboxes})
    
    let countSelectedCheckbox = 0

    selectedCheckboxes.forEach(element => {
      console.log(element.value)

      countSelectedCheckbox++

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
    
    infoValue = (countSelectedCheckbox / allCheckboxes) * 100
    
    selectedCheckboxes = 0;

    info.variant = infoVariant
    info.value = infoValue
    info.returnedId = returnedId
  
    return info
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }  
}