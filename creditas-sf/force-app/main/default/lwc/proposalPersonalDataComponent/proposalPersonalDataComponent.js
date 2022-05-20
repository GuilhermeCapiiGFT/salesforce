import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo  } from 'lightning/uiObjectInfoApi';
import getLastPersonalDataSectionInstance from '@salesforce/apex/ProposalPersonalDataController.getLastPersonalDataSectionInstance';
import saveInstance from '@salesforce/apex/ProposalPersonalDataController.saveInstance';
export default class ProposalPersonalDataComponent extends LightningElement {

  @api accountid
  @api 
  get opportunityid() {

    return this.oppId;
  }
  set opportunityid( data) {

    this.oppId = data;
    this.getDataSectionInstance(data);

  }

  oppId;
  disabledBtnSave = true
  showContainer = false;
  initialRender = false;
  personalDataSectionRecord;
 
  // Picklist options
  politicallyExposedOptions = [{ label: 'Sim', value: true }, { label: 'Não', value: false }]
  
  // Checkboxes Values
  value = [];
  preValue = [];

  getDataSectionInstance(oppId) {

    getLastPersonalDataSectionInstance( {oppId : oppId})
      .then( result => {

        this.personalDataSectionRecord = result;
        this.buildDataSection();

        })
      .catch(error => {

        this.showError(error);

      });
    
  }


  handleInputChange(event) {
    
    this.personalDataSectionRecord[event.target.dataset.id] = event.target.value;

  }

  handleSaveSection() {
    // this.disabledBtnSave = true
    let recordToSend = JSON.stringify(this.personalDataSectionRecord);
    saveInstance({personalDataSectionInstance : recordToSend}).then( result => { console.log(result)});

   
  }

  saveCheckboxes() {
    const fields = {...this.mapSection}
    
    if (this.recordPersonalSectionId == '')
    {
      fields[OPPORTUNITY_ID_FIELD.fieldApiName] = this.opportunityid
      
      const recordInput = { apiName: PERSONAL_DATA_OBJECT.objectApiName, fields }
      
      createRecord(recordInput)
        .then(record => {
          this.recordPersonalSectionId = record.id
          this.disabledBtnSave = false
          this.showToast('Sucesso', 'Dados Pessoais atualizado com sucesso!', 'success')
        })
        .catch(error => {
          this.showError(error)
        })
    }

    else {
      fields[PERSONAL_DATA_ID_FIELD.fieldApiName] = this.recordPersonalSectionId

      const recordInput = { fields }

      updateRecord(recordInput)
        .then(recordInput => {
          this.disabledBtnSave = false
          this.showToast('Sucesso', 'Dados Pessoais atualizado com sucesso!', 'success')
        })
        .catch(error => {
          this.disabledBtnSave = false
          this.showError(error)
        })
    }
  }

  handleChangeCheckbox(event) {
    this.checksOnlyOne(event)
    this.saveObjectValues(event)
  }

  saveObjectValues(event) {
    let nameStatus = event.target.getAttribute('data-status')
    let valueStatus = event.target.checked ? event.target.value : null

    let fieldsCPF             = this.fieldsValidationCPF.map((item) => item.fieldApiName);
    let fieldsPEP             = this.fieldsValidationPEP.map((item) => item.fieldApiName);
    let fieldsRG              = this.fieldsValidationRG.map((item) => item.fieldApiName);
    let fieldsDispatchDateRG  = this.fieldsValidationDispatchDateRG.map((item) => item.fieldApiName);
    let fieldsCNH             = this.fieldsValidationCNH.map((item) => item.fieldApiName);
    let fieldsDispatchDateCNH = this.fieldsValidationDispatchDateCNH.map((item) => item.fieldApiName);
    let fieldsIssuerCNH       = this.fieldsValidationIssuerCNH.map((item) => item.fieldApiName);

    fieldsCPF.indexOf(nameStatus) > -1 ?             this.resetFieldsValidation(fieldsCPF):'';
    fieldsPEP.indexOf(nameStatus) > -1 ?             this.resetFieldsValidation(fieldsPEP):'';
    fieldsRG.indexOf(nameStatus) > -1 ?              this.resetFieldsValidation(fieldsRG):'';
    fieldsDispatchDateRG.indexOf(nameStatus) > -1 ?  this.resetFieldsValidation(fieldsDispatchDateRG):'';
    fieldsCNH.indexOf(nameStatus) > -1 ?             this.resetFieldsValidation(fieldsCNH):'';
    fieldsDispatchDateCNH.indexOf(nameStatus) > -1 ? this.resetFieldsValidation(fieldsDispatchDateCNH):'';
    fieldsIssuerCNH.indexOf(nameStatus) > -1 ?       this.resetFieldsValidation(fieldsIssuerCNH):'';
    
    this.mapSection[nameStatus] = valueStatus
  }

  resetFieldsValidation(fieldsValidationAPI) {
    fieldsValidationAPI.map((item) => this.mapSection[item] = null);
  }

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name
    let currentCheckboxValue = event.currentTarget.value
    let modal = {}

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

        modal['modalReason'] = modalReason
        modal['openModalReason'] = true
        modal['fieldReason'] = event.target.getAttribute('data-field')
        modal['objectReason'] = 'PersonalDataSection__c'
      }
    })

    let info = this.getPercentage()
    info = {...info, modal}

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
    let returnedId = this.template.querySelector("div[data-id='ContainerDadosPessoais']").getAttribute("data-id")
    let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')
    let totalLines = 16

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
    selectedCheckboxes = 0
    
    info.variant = infoVariant
    info.value = infoValue
    info.returnedId = returnedId

    this.controllerSave(info.value);
  
    return info
  }

  controllerSave(percentageSection){
    this.disabledBtnSave = (percentageSection != 100) ? true : false;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  } 

  getAge(dateString) {
    let today = new Date();
    let birthDate = new Date(dateString.toString());
    let age = today.getFullYear() - birthDate.getFullYear();
    let m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
    return age;
  }

  get isRed() {
    return (this.idade > 60 || this.idade < 25) ? true : false
  }

  @api
  getReasonSelected(result) {
    let validationReason = JSON.parse(result);
    if(validationReason.reason == null) {
      this.uncheckReason(validationReason.field);
    }
    else {
      this.setMapReason(validationReason);
    }
  }

  uncheckReason(reason){
    let field = this.template.querySelector('[data-field="' + reason + '"]');
    field.checked = false;
    field.setAttribute('data-value', '');
    let info = this.getPercentage();
    this.sendInfo(info);
  }

  setMapReason(selectedReason) {
    let description = selectedReason.description ? selectedReason.description : '';
    let mapSection = this.mapSection;

    if( ['RGPendingReason__c','RGRejectReason__c'].includes(selectedReason.field)) {
      mapSection[selectedReason.field] = selectedReason.reason ? selectedReason.reason : '';
      mapSection.RGobservation__c = description;
    }

    else if(['CPFPendingReason__c', 'CPFRejectReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]      = selectedReason.reason;
      mapSection.CPFObservation__c          = description;
    }

    else if(['PersonExposedRejectReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]      = selectedReason.reason;
      mapSection.PoliticallyExposedPersonObservation__c = description;
    }
    
    else if(['DateDispatchPendingReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]      = selectedReason.reason;
      mapSection.DispatchDateObservation__c = description;
    }
      
    else if(['CNHnumberPendingReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]   = selectedReason.reason;
      mapSection.CNHnumberObservation__c = description;
    }

    else if(['CNHdispatchDatePendingReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]         = selectedReason.reason;
      mapSection.CNHdispatchDateObservation__c = description;
    }

    else if(['CNHissuingAgencyPendingReason__c'].includes(selectedReason.field)){
      mapSection[selectedReason.field]          = selectedReason.reason;
      mapSection.CNHissuingAgencyObservation__c = description;
    }
  }

  showError(error) {
    this.error = error
    this.showToast('Erro', error.body.message, 'error')
  }

  buildDataSection() {

    this.politicallyExposed = ( this.personalDataSectionRecord.PoliticallyExposed__c ) ? 'Sim' : 'Não';
    this.idade = this.getAge(this.personalDataSectionRecord.BirthDate__c);
    this.showContainer = true;
    
   
    // let info = this.getPercentage()
    // this.sendInfo(info)
  }

  renderedCallback() {

    if ( this.initialRender ) return;

    this.loadCheckedStatusFromRecord();

  }

  loadCheckedStatusFromRecord() {

    for (let indexField in this.personalDataSectionRecord ) {

      this.template.querySelectorAll("[data-status='"+indexField+"']").forEach( item => {

        if (item.value === this.personalDataSectionRecord[indexField]) {
          item.checked = true;
          item.setAttribute('data-value', item.value);
        }

        this.initialRender = true;
      });
    }
  }
}