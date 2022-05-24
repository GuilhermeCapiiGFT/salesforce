import { LightningElement, wire, api } from 'lwc';

import CONTACTDETAILSSECTION_OBJECT from '@salesforce/schema/ContactDetailsSection__c';

import MOBILESTATUS from '@salesforce/schema/ContactDetailsSection__c.MobileStatus__c';
import MOBILEREJECTION from '@salesforce/schema/ContactDetailsSection__c.MobileRejectReason__c';
import MOBILEPENDING from '@salesforce/schema/ContactDetailsSection__c.MobilePendingReason__c';
import MOBILEDESC from '@salesforce/schema/ContactDetailsSection__c.MobileObservation__c';

import EMAILSTATUS from '@salesforce/schema/ContactDetailsSection__c.EmailStatus__c';
import EMAILREJECTION from '@salesforce/schema/ContactDetailsSection__c.EmailRejectReason__c';
import EMAILPENDING from '@salesforce/schema/ContactDetailsSection__c.EmailPendingReason__c';
import EMAILDESC from '@salesforce/schema/ContactDetailsSection__c.EmailObservation__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getRecordContactDetailsSection from '@salesforce/apex/ProposalContactDataController.getContactDetails';
import upsertContactDetailsSection from '@salesforce/apex/ProposalContactDataController.saveContactDetailsSection';


const FIELDSVALIDATIONEMAIL = [EMAILSTATUS, EMAILREJECTION, EMAILPENDING, EMAILDESC];
const FIELDSVALIDATIONSMS = [MOBILESTATUS, MOBILEREJECTION, MOBILEPENDING, MOBILEDESC];
export default class ProposalContactDataComponent extends LightningElement {


  @api opportunityid;

  account;
  error;
  recordTypeId;
  fieldReadOnly = true;

  fieldsValidationEmail = FIELDSVALIDATIONEMAIL;
  fieldsValidationSMS = FIELDSVALIDATIONSMS;
  fieldsStatus = ['EmailStatus__c','MobileStatus__c'];
  // Controller btn save
  disabledBtnSave = false;
  completionPercentage = 0;
  saveRecord = true;
  statusReturnedPendency = 'Voltou de pendência';

  // Contact Data Info
  recordContactDataId = '';
  contactData;
  
  valueSMS = '';
  valueEmail = '';
  
  // Checkboxes Values
  value = [];
  preValue = [];

  // refresh apex 
  recordCommunication;
  resultRecordCommunication;

  // object of validation Section ContactDetailsSection__c
  objValidationSection = {
    'sobjectType': 'ContactDetailsSection__c',
    'MobileStatus__c': '',
    'MobileRejectReason__c': '',
    'MobilePendingReason__c': '',
    'MobileObservation__c': '',
    'EmailStatus__c': '',
    'EmailRejectReason__c': '',
    'EmailPendingReason__c': '',
    'EmailObservation__c':'',
    'Email__c':'',
    'Mobile__c':'',
    'Opportunity__c' : ''
  }
  
  

 @wire(getObjectInfo, { objectApiName: CONTACTDETAILSSECTION_OBJECT  })
  recordTypeContact({ error, data }) {
    if(data) {
        this.fieldReadOnly = !data?.fields?.Email__c?.updateable;
        this.fieldReadOnly = !data?.fields?.Mobile__c?.updateable;
    }
    else if(error){
        console.log(error);
    }
  }

 @wire(getRecordContactDetailsSection, {opportunityId: '$opportunityid'})
  recordCommunication(result) {
    this.recordCommunication = result;
    if(result.data) {
      let data = result.data;

      this.valueSMS = data.Mobile__c;
      this.valueEmail = data.Email__c;

      let resultValidationSection = {...this.objValidationSection, ...result.data};
      this.objValidationSection = resultValidationSection;
      
      let listStatus = this.fieldsStatus;
      for(let index in listStatus){
        let status = listStatus[index];
        this.template.querySelectorAll("[data-status='"+status+"']").forEach(function(item) {
          if (item.value === resultValidationSection[status]) {
            item.checked = true;
            item.setAttribute('data-value', item.value);
          }
        })
      }
      let info = this.getPercentage();
      this.sendInfo(info);
    }else if(result.error){
      console.log('Error');
    }
  }

  handleSaveSection() {
    this.disabledBtnSave = true;
    this.saveFieldsValidation();

  }

  saveFieldsValidation() {
    this.objValidationSection.Opportunity__c = this.opportunityid;
    let payload = this.objValidationSection
    upsertContactDetailsSection({recordContactDetails : payload})
    .then( result=>{
      refreshApex(this.recordCommunication);
      
      this.showToast('', 'Registro atualizado com sucesso!', 'success')
      this.saveRecord = true;
      this.sendInfo(this.getPercentage());
  
    })
    .catch(error =>{
      console.log(error);
      this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error')
    })
    .finally( ()=>{
      this.disabledBtnSave = false;
    })
  }

  handleChangeCheckbox(event) {
    this.saveRecord = false;
    this.checksOnlyOne(event);
    this.saveObjectValues(event);
    this.sendInfo(this.getPercentage());
  }

  saveObjectValues(event) {
    let nameStatus = event.target.getAttribute('data-status');
    let valueStatus = event.target.checked ? event.target.value : null;
    let fieldsEmailAPI = this.fieldsValidationEmail.map((item) => item.fieldApiName);
    let fieldsEmailSMS = this.fieldsValidationSMS.map((item) => item.fieldApiName);
    fieldsEmailAPI.indexOf(nameStatus) > -1 ? this.resetFieldsValidation(fieldsEmailAPI):'';
    fieldsEmailSMS.indexOf(nameStatus) > -1 ? this.resetFieldsValidation(fieldsEmailSMS):'';
       
    this.objValidationSection[nameStatus] = valueStatus;
  }

  resetFieldsValidation(fieldsValidationAPI){
    fieldsValidationAPI.map((item) => this.objValidationSection[item] = null);
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
        let modalReason = (currentCheckboxValue == 'Rejeitar') ? 'reject' : 'pendency';
        modal['modalReason'] = modalReason;
        modal['openModalReason'] = true;
        modal['fieldReason'] = event.target.getAttribute('data-field');
        modal['objectReason'] = 'ContactDetailsSection__c';
      }
    });

    let info = this.getPercentage();
    info = {...info, modal};

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
    let returnedId = this.template.querySelector("div[data-id='ContainerDadosContato']").getAttribute("data-id")
    let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')
    let totalLines = 2;

    let isPending = false
    let isRejected = false

    let infoVariant = ''
    let infoValue = ''

    let info = {}
    
    let countSelectedCheckbox = 0;

    selectedCheckboxes.forEach(element => {
      countSelectedCheckbox++

      if (element.value === 'Aprovar')         infoVariant = 'base-autocomplete'
      else if (element.value === 'Pendenciar') isPending = true
      else if (element.value === 'Rejeitar')   isRejected = true
    })
    
    if (isPending && !isRejected) infoVariant = 'warning';
    if (isRejected) infoVariant = 'expired';
    
    infoValue = (countSelectedCheckbox / totalLines) * 100;
    selectedCheckboxes = 0;

    this.completionPercentage = (infoValue == 100 && !this.saveRecord) ? 99 : infoValue;
    
    
    info.variant = infoVariant;
    info.value = this.completionPercentage;
    info.returnedId = returnedId;

    return info;
  }
  get controllerSaveBtn(){

    return (this.disabledBtnSave || (this.completionPercentage < 99) || this.saveRecord) ? true : false;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

  @api
  getReasonSelected(result){
    let validationReason = JSON.parse(result);
    if(validationReason.reason == null){
      this.uncheckReason(validationReason.field);
    }else{
      this.setMapReason(validationReason);
    }
  }

  uncheckReason(reason){
    let field = this.template.querySelector('[data-field="'+reason+'"]');
    field.checked = false;
    field.setAttribute('data-value', '');
    let info = this.getPercentage()
    this.sendInfo(info)
  }

  setMapReason(selectedReason){

    let description = selectedReason.description ? selectedReason.description : '';
    let objValidationSection = this.objValidationSection;

    if( ['EmailPendingReason__c','EmailRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason;
      objValidationSection.EmailObservation__c = description;
    }
    else if(['MobilePendingReason__c','MobileRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason;
      objValidationSection.MobileObservation__c = description;
    }
  }

  handleInputChange(event){
    let key = event.target.getAttribute('data-id');
    let currentValue = event.target.value;
    let objValidationSection = this.objValidationSection;
    if(key == 'EMAIL'){ 
      objValidationSection.Email__c = currentValue}
      else if(key == 'SMS'){objValidationSection.Mobile__c = currentValue}
      this.saveRecord = false;
      this.sendInfo(this.getPercentage());
  }

}