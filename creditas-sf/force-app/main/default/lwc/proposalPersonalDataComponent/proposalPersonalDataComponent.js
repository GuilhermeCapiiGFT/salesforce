import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import MOTHER_FIELD from '@salesforce/schema/Account.Mother__c';
import FATHER_FIELD from '@salesforce/schema/Account.Father__c';
import BIRTHCITY_FIELD from '@salesforce/schema/Account.BirthCity__c';
import BIRTHCOUNTRY_FIELD from '@salesforce/schema/Account.Birth_Country__c';
import DOCUMENT_NUMBER_FIELD from '@salesforce/schema/Account.DocumentNumber__c';
import CIVIL_STATUS_FIELD from '@salesforce/schema/Account.CivilStatus__c';
import PEP_FIELD from '@salesforce/schema/Account.PoliticallyExposed__c';
import BIRTHDATE_FIELD from '@salesforce/schema/Account.BirthDate__c';
import NATIONALITY_FIELD from '@salesforce/schema/Account.Nationality__c';

import PERSONAL_DATA_OBJECT from '@salesforce/schema/PersonalDataSection__c';
import PERSONAL_DATA_ID_FIELD from '@salesforce/schema/PersonalDataSection__c.Id';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/PersonalDataSection__c.Opportunity__c';
import NAME_STATUS_FIELD from '@salesforce/schema/PersonalDataSection__c.NameStatus__c';
import MOTHER_STATUS_FIELD from '@salesforce/schema/PersonalDataSection__c.MothersNameStatus__c';
import DOCUMENT_STATUS_FIELD from '@salesforce/schema/PersonalDataSection__c.CPFStatus__c';


import getRecordId from '@salesforce/apex/ProposalController.getRecordId';

const ACCOUNT_FIELDS = [NAME_FIELD, MOTHER_FIELD, DOCUMENT_NUMBER_FIELD, CIVIL_STATUS_FIELD, PEP_FIELD, BIRTHDATE_FIELD, FATHER_FIELD, BIRTHCITY_FIELD, BIRTHCOUNTRY_FIELD, NATIONALITY_FIELD]
const SECTION_FIELDS = [NAME_STATUS_FIELD, MOTHER_STATUS_FIELD, DOCUMENT_STATUS_FIELD]

export default class ProposalPersonalDataComponent extends LightningElement {

  // Account Info
  @api accountid
  @api opportunityid
  account
  error
  recordTypeId
  
  // Account Info Fields
  name = ''
  mother = ''
  father = ''
  documentNumber = ''
  birthCity = ''
  birthCountry = ''
  civilStatus = ''
  politicallyExposed = ''
  birthdate 
  nationality = ''

  // Personal Data Info
  recordPersonalSectionId = ''
  personalData
 
  // Picklist options
  civilStatusOptions = []
  politicallyExposedOptions = [{ label: 'Sim', value: 'SIM' }, { label: 'Não', value: 'NÃO' }]
  
  // Checkboxes Values
  value = [];
  preValue = [];

  // Map for personal data
  mapSection = 
    {
      'NameStatus__c': '',
      'MothersNameStatus__c': '',
      'FathersNameStatus__c': '',
      'CPFStatus__c' : '',
      // 'CPFPendingReason__c' : '',
      // 'CPFRejectReason__c' : '',
      // 'CPFDescription__c': '',
      'BirthCityStatus__c': '',
      'BirthCountryStatus__c': '',
      'NacionalityStatus__c': '',
      'PoliticallyExposedPersonStatus__c': ''
      // 'PersonExposedRejectReason__c': ''
    }


  @wire(getRecord, { recordId: '$accountid', fields: ACCOUNT_FIELDS })
  getAccountInfo({ error, data }) {
    if (data) {
      this.account = data
      this.error = undefined

      console.log(JSON.parse(JSON.stringify(this.account)))

      let fields = this.account.fields

      this.name = fields.Name.value
      this.mother = fields.Mother__c.value
      this.father = fields.Father__c.value
      this.documentNumber = fields.DocumentNumber__c.value
      this.birthCity = fields.BirthCity__c.value
      this.birthCountry = fields.Birth_Country__c.value
      this.nationality = fields.Nationality__c.value
      this.civilStatus = fields.CivilStatus__c.value
      this.politicallyExposed = fields.PoliticallyExposed__c.value ? 'SIM' : 'NÃO'
      this.birthdate = fields.BirthDate__c.value

    } else if (error) {
      this.error = error
      console.log('an error happened')
    }
  }

  @wire(getRecordId, {recordId: '$opportunityid'})
  getDataSectionId({ error, data }) {
    if (data) {
      this.error = undefined
  
      console.log(JSON.parse(JSON.stringify(data)))

      this.recordPersonalSectionId = Object.keys(data).length === 0 ? '' : data.dadosPessoais.Id
      
      console.log('id do record personal')
      console.log(this.recordPersonalSectionId)
    
      if (this.recordPersonalSectionId !== '') {
        
        this.personalData = data.dadosPessoais

        console.log(this.mapSection)

        this.mapSection.NameStatus__c = this.personalData.NameStatus__c
        this.mapSection.MothersNameStatus__c = this.personalData.MothersNameStatus__c
        this.mapSection.CPFStatus__c = this.personalData.CPFStatus__c
        // this.mapSection.CPFPendingReason__c = this.personalData.CPFPendingReason__c
        // this.mapSection.CPFRejectReason__c = this.personalData.CPFRejectReason__c
        // this.mapSection.CPFDescription__c = this.personalData.CPFDescription__c
        this.mapSection.BirthCityStatus__c = this.personalData.BirthCityStatus__c
        this.mapSection.BirthCountryStatus__c = this.personalData.BirthCountryStatus__c
        this.mapSection.NacionalityStatus__c = this.personalData.NacionalityStatus__c
        this.mapSection.PoliticallyExposedPersonStatus__c = this.personalData.PoliticallyExposedPersonStatus__c
        // this.mapSection.PersonExposedRejectReason__c = this.personalData.PersonExposedRejectReason__c

        console.log(this.mapSection)

        let { Id, Name, Opportunity__c, ...filteredData } = this.personalData
        
        console.log(this.personalData)
        console.log({filteredData})
        
        for (let indexField in filteredData) {
          
          this.template.querySelectorAll("[data-status='"+indexField+"']").forEach(function(item) {
              
            if (item.value === filteredData[indexField]) {
              item.checked = true
              item.setAttribute('data-value', item.value)
            }

            // if (item.value === 'Pendenciar' && filteredData[indexField] === 'Pendenciar') {
            //   item.checked = true
            //   item.setAttribute('data-value', 'Pendenciar')
            // }

            // if (item.value === 'reprovado' && filteredData[indexField] === 'Rejeitar') {
            //   item.checked = true
            //   item.setAttribute('data-value', 'reprovado')
            // }
          })
        }

        let info = this.getPercentage()
        this.sendInfo(info)
      } 
    } else if (error) {
      this.error = error
      console.log({error})
    }
  }

  @wire(getPicklistValues, { recordTypeId: '$account.recordTypeId', fieldApiName: CIVIL_STATUS_FIELD })
  getCivilStatusPicklist({ error, data }) {
    if (data) {
      this.civilStatusOptions = data.values
    } else if(error) {
      this.showToast('Erro', error.body.message, 'error')
    }
  }

  handleSaveSection(event) {
    let saveBtn = this.template.querySelector('[data-id="save-personal-data-btn"]')
    saveBtn.disabled = true

    const fields = {}

    fields[ACCOUNTID_FIELD.fieldApiName]       = this.accountid
    fields[NAME_FIELD.fieldApiName]            = this.template.querySelector("[data-id='Name']").value
    fields[MOTHER_FIELD.fieldApiName]          = this.template.querySelector("[data-id='Mother__c']").value
    fields[DOCUMENT_NUMBER_FIELD.fieldApiName] = this.template.querySelector("[data-id='DocumentNumber__c']").value
    fields[CIVIL_STATUS_FIELD.fieldApiName]    = this.template.querySelector("[data-id='CivilStatus__c']").value
    fields[PEP_FIELD.fieldApiName]             = (this.template.querySelector("[data-id='PoliticallyExposed__c']").value === 'SIM') ? true : false
    fields[BIRTHDATE_FIELD.fieldApiName]       = this.template.querySelector("[data-id='BirthDate__c']").value
    
    const recordInput = { fields }

    console.log(recordInput)
    
    updateRecord(recordInput)
      .then(() => {
        console.log('teste 0')
        saveBtn.disabled = false
        this.saveCheckboxes()
      })
      .catch(error => {
        saveBtn.disabled = false
        this.showToast('Erro', error.body.message, 'error')
      });
    
  }

  saveCheckboxes() {
    const fields = {...this.mapSection}
    
    if (this.recordPersonalSectionId == '') {
      
      fields[OPPORTUNITY_ID_FIELD.fieldApiName] = this.opportunityid
      
      console.log({ fields })
      
      const recordInput = { apiName: PERSONAL_DATA_OBJECT.objectApiName, fields }
      
      createRecord(recordInput)
        .then(record => {
          console.log({ record })
          this.recordPersonalSectionId = record.id

          this.showToast('Sucesso', 'Dados Pessoais atualizado com sucesso!', 'success')
        })
        .catch(error => {
          this.showToast('Erro', error.body.message, 'error')
        })
    }

    else {
      
      console.log('registro já existe. Atualizando..')

      fields[PERSONAL_DATA_ID_FIELD.fieldApiName] = this.recordPersonalSectionId

      console.log({ fields })

      const recordInput = { fields }

      updateRecord(recordInput)
        .then(recordInput => {
          console.log({ recordInput })
          this.showToast('Sucesso', 'Dados Pessoais atualizado com sucesso!', 'success')
        })
        .catch(error => {
          this.showToast('Erro', error.body.message, 'error')
        })

      console.log('recordPersonalSection Id: ', this.recordPersonalSectionId)
    }
  }

  handleChangeCheckbox(event) {
    this.checksOnlyOne(event)

    this.saveObjectValues(event)
  }

  saveObjectValues(event) {
    console.log('tyumi entrou no saveObject')

    // let nameField = event.target.getAttribute('data-field')
    let nameStatus = event.target.getAttribute('data-status')
    let valueStatus = event.target.checked ? event.target.value : ''
    
    // let fields = new Map()
    // fields.set(nameStatus, valueStatus)
    // this.mapSection.set(nameField, fields)

    this.mapSection[nameStatus] = valueStatus

    console.log(this.mapSection)
  }

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name
    let currentCheckboxValue = event.currentTarget.value
    let modal = {}

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

      
      if (event.target.checked && (currentCheckboxValue == 'Rejeitar' || currentCheckboxValue == 'Pendenciar'))
      {
        let modalReason = (currentCheckboxValue == 'Rejeitar') ? 'reject' : 'pendency';
        let openModalReason = true;
        let modalReasonField = currentCheckbox;

        modal['modalReason'] = modalReason
        modal['openModalReason'] = openModalReason
        modal['modalReasonField'] = modalReasonField

        modal['fieldReason'] = elem.getAttribute('data-reason')
        modal['objectReason'] = 'PersonalDataSection__c'
      }

      // console.log(elem.value + ' '+ elem.checked)
    })

    
    let info = this.getPercentage()
    info = {...info, modal}

    // console.log({modal})
    console.log({info})

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

  getPercentage() {
    //let returnedId = event.target.closest("div[data-id='ContainerDadosPessoais']").getAttribute("data-id")
    //let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')

    let returnedId = this.template.querySelector("div[data-id='ContainerDadosPessoais']").getAttribute("data-id")
    let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    //let allCheckboxes = (topContainer.querySelectorAll('input[type="checkbox"]').length) / 3
    let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')

    let isPending = false
    let isRejected = false

    let infoVariant = ''
    let infoValue = ''

    let info = {}
    
    let countSelectedCheckbox = 0

    selectedCheckboxes.forEach(element => {
      console.log(element.value)
      countSelectedCheckbox++

      if (element.value === 'Aprovar') {
        infoVariant = 'base-autocomplete'
      }

      else if (element.value === 'Pendenciar') {
        isPending = true
      }

      else if (element.value === 'Rejeitar') {
        isRejected = true
      }
    })
    
    if (isPending && !isRejected) infoVariant = 'warning'
    if (isRejected) infoVariant = 'expired'
    
    infoValue = (countSelectedCheckbox / 9) * 100

    // console.log({allCheckboxes})
    
    selectedCheckboxes = 0
    
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