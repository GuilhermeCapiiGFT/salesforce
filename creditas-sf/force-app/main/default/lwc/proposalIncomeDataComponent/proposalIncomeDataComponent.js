import { LightningElement, api, wire, track } from 'lwc';

import FINANCIAL_RESOURCES_OBJECT from '@salesforce/schema/FinancialResources__c';
import SECTION_OBJECT from '@salesforce/schema/IncomeDataSection__c';

import PROFESSIONALSITUATIONSTATUS from '@salesforce/schema/IncomeDataSection__c.ProfessionalSituationStatus__c';
import PROFESSIONALSITUATIONPENDINGREASON from '@salesforce/schema/IncomeDataSection__c.ProfessionalSituationPendingReason__c';
import PROFESSIONALSITUATIONOBSERVATION from '@salesforce/schema/IncomeDataSection__c.ProfessionalSituationObservation__c';

import PROFESSIONSTATUS from '@salesforce/schema/IncomeDataSection__c.ProfessionStatus__c';
import PROFESSIONPENDINGREASON from '@salesforce/schema/IncomeDataSection__c.ProfessionPendingReason__c';
import PROFESSIONOBSERVATION from '@salesforce/schema/IncomeDataSection__c.ProfessionObservation__c';

import NETWORTHSTATUS from '@salesforce/schema/IncomeDataSection__c.NetWorthStatus__c';

import MONTHLYINCOMESTATUS from '@salesforce/schema/IncomeDataSection__c.MonthlyIncomeStatus__c';
import MONTHLYINCOMEPENDINGREASON from '@salesforce/schema/IncomeDataSection__c.ReportedIncomePendingReason__c';
import MONTHLYINCOMEOBSERVATION from '@salesforce/schema/IncomeDataSection__c.MonthlyIncomeObservation__c';

import MINIMALREQUIREDINCOMESTATUS from '@salesforce/schema/IncomeDataSection__c.MinimalRequiredIncomeStatus__c';
import MINIMALREQUIREDINCOMEREJECTREASON from '@salesforce/schema/IncomeDataSection__c.MinimalRequiredIncomeRejectReason__c';
import MINIMALREQUIREDINCOMEOBSERVATION from '@salesforce/schema/IncomeDataSection__c.MinimalRequiredIncomeObservation__c';

import PRESUMEDMONTHLYINCOMESTATUS from '@salesforce/schema/IncomeDataSection__c.PresumedMonthlyIncomeStatus__c';

import CONFIRMEDMONTHLYINCOMESTATUS from '@salesforce/schema/IncomeDataSection__c.ConfirmedMonthlyIncomeStatus__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getRecordIncomeSection from '@salesforce/apex/ProposalIncomeDataController.getIncomeDataSectiontDetails';
import upsertIncomeSection from '@salesforce/apex/ProposalIncomeDataController.saveIncomeDataSection';

const FIELDSVALIDATIONPROFESSIONALSITUATION = [PROFESSIONALSITUATIONSTATUS, PROFESSIONALSITUATIONPENDINGREASON, PROFESSIONALSITUATIONOBSERVATION]
const FIELDSVALIDATIONPROFESSION = [PROFESSIONSTATUS, PROFESSIONPENDINGREASON, PROFESSIONOBSERVATION]
const FIELDSVALIDATIONNETWORTH = [NETWORTHSTATUS]
const FIELDSVALIDATIONMONTHLYINCOME = [MONTHLYINCOMESTATUS, MONTHLYINCOMEPENDINGREASON, MONTHLYINCOMEOBSERVATION]
const FIELDSVALIDATIONMINIMALREQUIREDINCOME = [MINIMALREQUIREDINCOMESTATUS, MINIMALREQUIREDINCOMEREJECTREASON, MINIMALREQUIREDINCOMEOBSERVATION]
const FIELDSVALIDATIONPRESUMEDINCOME = [PRESUMEDMONTHLYINCOMESTATUS]
const FIELDSVALIDATIONCONFIRMEDINCOME = [CONFIRMEDMONTHLYINCOMESTATUS]


export default class ProposalIncomeDataComponent extends LightningElement {

  @api opportunityid
  error

  income
  recordTypeId

  fieldsValidation = [FIELDSVALIDATIONPROFESSIONALSITUATION, FIELDSVALIDATIONPROFESSION, FIELDSVALIDATIONNETWORTH, FIELDSVALIDATIONMONTHLYINCOME, FIELDSVALIDATIONMINIMALREQUIREDINCOME, FIELDSVALIDATIONPRESUMEDINCOME, FIELDSVALIDATIONCONFIRMEDINCOME]
  fieldsStatus = ['ProfessionalSituationStatus__c', 'ProfessionStatus__c', 'NetWorthStatus__c', 'MonthlyIncomeStatus__c', 'MinimalRequiredIncomeStatus__c', 'PresumedMonthlyIncomeStatus__c', 'ConfirmedMonthlyIncomeStatus__c']
    
  // Controller save button
  disabledBtnSave = true

  recordIncomeId = ''
  incomeData

  // Income Info Fields
  @track status                 = {value: '', fieldReadOnly: true} 
  @track jobTitle               = {value: '', fieldReadOnly: true}
  @track networth               = {value: '', fieldReadOnly: true}
  @track monthlyIncome          = {value: '', fieldReadOnly: true}
  @track minimalRequiredIncome  = {value: '', fieldReadOnly: true}
  @track presumedMonthlyIncome  = {value: '', fieldReadOnly: true}
  @track confirmedMonthlyIncome = {value: '', fieldReadOnly: true}

  // Checkboxes Values
  value = [];
  preValue = [];

  // Array converted to payload afterwards
  incomeValue = []

  // refresh apex
  recordIncome
  resultRecordIncome
  
  // validation object for the income section
  objValidationSection = {
    'sobjectType': SECTION_OBJECT.objectApiName
  }

  @wire(getRecordIncomeSection, { opportunityId: '$opportunityid' })
  recordIncomeSection(result) {
    this.recordIncome = result

    if (result.data) {
      let resultValidationSection = { ...this.objValidationSection, ...result.data }
      this.objValidationSection = resultValidationSection

      let listStatus = this.fieldsStatus

      for (let index in listStatus) {
        let status = listStatus[index]
        this.template.querySelectorAll("[data-status='" + status + "']").forEach(function (item) {
          if (item.value === resultValidationSection[status]) {
            item.checked = true
            item.setAttribute('data-value', item.value)
          }
        })
      }
      let info = this.getPercentage()
      this.sendInfo(info)
    } else if (result.error) {
      console.log('Error on getting checkboxes values')
    } 
  }
  
  handleSaveSection() {
    this.saveFieldsValidation()
  }

  // saveFields() {
  //   this.disabledBtnSave = true;
  //   let payload = this.addressValue;

  //   upsertAddress({addresses : payload})
  //   .then(result => {
  //     refreshApex(this.resultRecordCommunication);
  //     console.log({ result })
  //     this.saveFieldsValidation()
  //   })
  //   .catch(error =>{
  //     console.log(error);
  //     this.disabledBtnSave = false;
  //     this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error')
  //   })
  // }

  saveFieldsValidation() {
    this.objValidationSection.Opportunity__c = this.opportunityid;
    let payload = this.objValidationSection
    
    console.log({ payload })
    
    upsertIncomeSection({incomeDataSection : payload})
    .then(result => {
      refreshApex(this.recordIncome);
      this.showToast('', 'Registro atualizado com sucesso!', 'success')
      this.disabledBtnSave = false;
    })
    .catch(error =>{
      console.log(error);
      this.disabledBtnSave = false;
      this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error')
    })
  }

  handleChangeCheckbox(event) {
    this.checksOnlyOne(event)
    this.saveObjectValues(event)
  }

  saveObjectValues(event) {
    let nameStatus = event.target.getAttribute('data-status')
    let valueStatus = event.target.checked ? event.target.value : null;

    for (let field of this.fieldsValidation)
    {
      let fieldApi = field.map(item => item.fieldApiName)
      fieldApi.indexOf(nameStatus) > - 1 ? this.resetFieldsValidation(fieldApi) : ''
    }
    
    this.objValidationSection[nameStatus] = valueStatus
  }

  resetFieldsValidation(fieldsValidationAPI){
    fieldsValidationAPI.map((item) => this.objValidationSection[item] = null)
  }

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name;
    let currentCheckboxValue = event.currentTarget.value;
    let modal = {};

    this.template.querySelectorAll('input[name='+currentCheckbox+']').forEach(elem => {
      let oldValue = elem.getAttribute('data-value');
      let newValue = currentCheckboxValue;

      if(oldValue !== null && elem.value === oldValue) {
        elem.checked = false;
        newValue = '';
        
      } else if(elem.value === currentCheckboxValue) {
        newValue = currentCheckboxValue;
        elem.checked = true;
      }
      elem.setAttribute('data-value', newValue);

      if (event.target.checked && (currentCheckboxValue == 'Rejeitar' || currentCheckboxValue == 'Pendenciar'))
      {
        let modalReason = (currentCheckboxValue == 'Rejeitar') ? 'reject' : 'pendency'
        modal['modalReason'] = modalReason
        modal['openModalReason'] = true
        modal['fieldReason'] = event.target.getAttribute('data-field')
        modal['objectReason'] = SECTION_OBJECT.objectApiName
      }
    });

    let info = this.getPercentage();
    info = {...info, modal};

    console.log({info})

    this.sendInfo(info);
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
    let returnedId = this.template.querySelector("div[data-id='ContainerDadosRenda']").getAttribute("data-id")
    let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')
    let totalLines = 7;

    let isPending = false
    let isRejected = false

    let infoVariant = ''
    let infoValue = ''

    let info = {}
    
    let countSelectedCheckbox = 0

    selectedCheckboxes.forEach(element => {
      countSelectedCheckbox++

      if (element.value === 'Aprovar')         infoVariant = 'base-autocomplete'
      else if (element.value === 'Pendenciar') isPending = true
      else if (element.value === 'Rejeitar')   isRejected = true
    })
    
    if (isPending && !isRejected) infoVariant = 'warning'
    if (isRejected) infoVariant = 'expired'
    
    infoValue = (countSelectedCheckbox / totalLines) * 100
    selectedCheckboxes = 0;
    
    info.variant = infoVariant
    info.value = infoValue
    info.returnedId = returnedId
  
    this.controllerSave(info.value)

    return info
  }

  controllerSave(percentageSection){
    this.disabledBtnSave = (percentageSection != 100) ? true : false
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event)
  }

  @api
  getReasonSelected(result){
    let validationReason = JSON.parse(result)
    if(validationReason.reason == null){
      this.uncheckReason(validationReason.field)
    }else{
      this.setMapReason(validationReason)
    }
  }

  uncheckReason(reason){
    let field = this.template.querySelector('[data-field="'+reason+'"]')
    field.checked = false
    field.setAttribute('data-value', '')
    let info = this.getPercentage()
    this.sendInfo(info)
  }

  setMapReason(selectedReason){

    let observation = selectedReason.observation ? selectedReason.observation : ''
    let objValidationSection = this.objValidationSection

    if( ['ProfessionalSituationPendingReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.ProfessionalSituationObservation__c = observation
    }
    else if(['ProfessionPendingReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.ProfessionObservation__c = observation
    }
    else if(['ReportedIncomePendingReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.MonthlyIncomeObservation__c = observation
    }
    else if(['MinimalRequiredIncomeRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.MinimalRequiredIncomeObservation__c = observation
    }
  }
}