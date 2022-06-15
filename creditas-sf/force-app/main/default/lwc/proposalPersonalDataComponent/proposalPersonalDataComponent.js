import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLastPersonalDataSectionInstance from '@salesforce/apex/ProposalPersonalDataController.getLastPersonalDataSectionInstance';
import saveInstance from '@salesforce/apex/ProposalPersonalDataController.saveInstance';
import { politicallyExposedOptions, observationByStatus, disabledFields } from './personalData';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PERSONAL_DATA_SECTION_OBJECT from '@salesforce/schema/PersonalDataSection__c';

const SUCCESS_SAVED = 'Dados Pessoais atualizado com sucesso!';
const PENDENCY_STATUS = 'PENDING';
const REJECTION_STATUS = 'REJECTED';
const APPROVED_STATUS = 'APPROVED';
const RETURNED_PENDENCY_STATUS = 'RETURNED_PENDENCY';
const VALIDATION_ROWS = 16;
const COMPONENT_ID = 'ContainerDadosPessoais';

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
  disabledBtnSave = true;
  showContainer = false;
  initialRender = false;
  personalDataSectionRecord;
  recordSaved = true;
  disabledFields = disabledFields;
  statusReturnedPendency = RETURNED_PENDENCY_STATUS;
  completionPercentage = 0;
  lastCheckBoxName;
  age;
  
  // Picklist options
  politicallyExposedOptions = politicallyExposedOptions;
  
  // Checkboxes Values
  value = [];
  preValue = [];

  getDataSectionInstance(oppId) {

    getLastPersonalDataSectionInstance( {oppId : oppId})
      .then( result => {

        this.personalDataSectionRecord = ( result != null ) ? result : {} ;
        this.buildDataSection();

        })
      .catch(error => {

        this.showError(error);

      });
    
  }

  handleInputChange(event) {

    this.recordSaved = false;
    this.personalDataSectionRecord[event.target.dataset.id] = event.target.value;
    this.updateAge();

    this.sendInfo(this.getInfo());
  }

  handleSaveSection() {
    
    this.disabledBtnSave = true;

    let recordToSend = JSON.stringify(this.personalDataSectionRecord);

    saveInstance({ serializedPersonalDataSection : recordToSend}).
      then( result => { 

        this.recordSaved = true;
        this.showToast('Sucesso', SUCCESS_SAVED, 'success');
        this.sendInfo(this.getInfo());
      })
      .catch(error => {
        this.disabledBtnSave = false;
        this.showError(error);
      });

  }

  handleChangeCheckbox(event) {

    this.recordSaved = false;
    this.lastCheckBoxName = event.target.dataset.status;

    let currentCheckboxValue = event.currentTarget.value;
    let currentCheckBoxField = event.target.dataset.status;
    let lastValueOnCheckbox = this.personalDataSectionRecord[currentCheckBoxField];

    this.personalDataSectionRecord[currentCheckBoxField] = ( lastValueOnCheckbox != currentCheckboxValue ) ? currentCheckboxValue : null;

    const currentCheckbox = event.target;
    const currentRowCheckboxes = this.template.querySelectorAll(
      `input[name=${currentCheckbox.name}]`
    );

    this.checkOnlyOne(event, currentRowCheckboxes);

    const info = this.getInfo();
    const modal = this.getModal(currentCheckbox);

    this.sendInfo({ ...info, modal });

  }

  getModal(checkbox) {
    const modal = {};

    if (checkbox.checked && ( checkbox.value == REJECTION_STATUS || checkbox.value == PENDENCY_STATUS ) ) {

      modal['modalReason'] = checkbox.value == REJECTION_STATUS ? 'reject' : 'pendency';
      modal['openModalReason'] = true;
      modal['fieldReason'] = checkbox.getAttribute('data-field');
      modal['objectReason'] = PERSONAL_DATA_SECTION_OBJECT.objectApiName;

    }

    return modal;
  }

  checkOnlyOne(currentCheckbox, rowCheckboxes) {
    
    let currentCheckboxValue = this.personalDataSectionRecord[ currentCheckbox.target.dataset.status ];

    
    rowCheckboxes.forEach(checkbox => {

      if ( checkbox.value == currentCheckboxValue ) {
        
        checkbox.checked = true;

      } else {

        
        checkbox.checked = false;
        let fieldToClear = checkbox.getAttribute('data-field');

        if ( !fieldToClear ) return;

        this.personalDataSectionRecord[fieldToClear] = ( checkbox.value != APPROVED_STATUS ) ? null : this.personalDataSectionRecord[fieldToClear];

      }
    });
  }

  getInfo() {
    const selectedCheckboxes = this.template.querySelectorAll(`input[type='checkbox']:checked`);
    this.updateCompletionPercentage(selectedCheckboxes);

    const variant = this.getVariant(selectedCheckboxes);
    return {
      variant,
      value: this.completionPercentage,
      returnedId: COMPONENT_ID
    };
  }

  getVariant(selectedCheckboxes) {
    let isApproved = false;
    let isPending = false;
    let isRejected = false;
    let variant = '';

    selectedCheckboxes.forEach(element => {

      if (element.value ===  APPROVED_STATUS) {
        isApproved = true;
      } else if (element.value === PENDENCY_STATUS ) {
        isPending = true;
      } else if (element.value === REJECTION_STATUS ) {
        isRejected = true;
      }
    });

    if (isRejected) {
      variant = 'expired';
    } else if (isPending) {
      variant = 'warning';
    } else if (isApproved) {
      variant = 'base-autocomplete';
    }

    return variant;
  }

  updateCompletionPercentage(checkboxes) {

    const selected = checkboxes.length;
    const total = VALIDATION_ROWS;
    this.completionPercentage = (selected / total) * 100;
    
    this.completionPercentage = ( this.completionPercentage == 100 && !this.recordSaved ) ? 99 : this.completionPercentage;
    this.controllerSave(this.completionPercentage);

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

  controllerSave(percentageSection) {
    this.disabledBtnSave = ( percentageSection == 99 && !this.recordSaved ) ? false : true;
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

    if ( !dateString ) return;

    let today = new Date();
    let birthDate = new Date(dateString.toString());
    let age = today.getFullYear() - birthDate.getFullYear();
    let m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
    return age;
  }

  get isRed() {
    return (this.age > 60 || this.age < 25) ? true : false;
  }

  @api
  getReasonSelected(result) {

    let validationReason = JSON.parse(result);

    ( validationReason.reason == null ) ? this.uncheckReason(validationReason) : this.saveReasonOnRecord(validationReason);
  
  }

  uncheckReason(validationReason){

    this.recordSaved = false;
    let field = this.template.querySelector('[data-field="' + validationReason.field + '"]');
    field.checked = false;
    field.setAttribute('data-value', '');

    this.personalDataSectionRecord[validationReason.field] = null;
    let observationField = observationByStatus.get(this.lastCheckBoxName);
    this.personalDataSectionRecord[observationField] = null;

    this.sendInfo(this.getInfo());
  }

  saveReasonOnRecord(validationReason) {

    this.recordSaved = false;
    this.personalDataSectionRecord[validationReason.field] = validationReason.reason;
    let observationField = observationByStatus.get(this.lastCheckBoxName);

    this.personalDataSectionRecord[observationField] = ( validationReason.description != null ) ? validationReason.description : null;
    
    this.sendInfo(this.getInfo());
  }

  showError(error) {
    this.error = error
    this.showToast('Erro', error.body.message, 'error')
  }

  buildDataSection() {

    this.personalDataSectionRecord.PoliticallyExposed__c = ( this.personalDataSectionRecord.PoliticallyExposed__c ) ? 'true' : 'false';
    this.updateAge();

    this.showContainer = true;
  }

  updateAge() {

    this.age = this.getAge( this.personalDataSectionRecord.BirthDate__c );

  }

  renderedCallback() {

    if ( this.initialRender ) return;

    this.loadCheckedStatusFromRecord();

  }

  loadCheckedStatusFromRecord() {

    for (let indexField in this.personalDataSectionRecord ) {

      this.template.querySelectorAll("[data-status='"+indexField+"']").forEach( item => {

        let dataValue = item.hasAttribute("data-value") ? item.getAttribute("data-value") : null;

        if ( dataValue == this.personalDataSectionRecord[indexField]
            && dataValue == RETURNED_PENDENCY_STATUS ) {
         
            item.classList.add('show_icon_pendency');
        }

        if (item.value === this.personalDataSectionRecord[indexField]) {
          item.checked = true;
          item.setAttribute('data-value', item.value);
        }

        this.initialRender = true;

      });
    }

    this.sendInfo(this.getInfo());
  }

  @wire(getObjectInfo, { objectApiName: PERSONAL_DATA_SECTION_OBJECT  })
  getOperationPermission({ error, data }) {
    
    if (data) {
    
      this.disabledFields.name = !data.fields.Name__c.updateable;
      this.disabledFields.father = !data.fields.Father__c.updateable;
      this.disabledFields.mother = !data.fields.Mother__c.updateable;
      this.disabledFields.birthdate = !data.fields.BirthDate__c.updateable;
      this.disabledFields.cpf = !data.fields.CPF__c.updateable;
      this.disabledFields.birthCity = !data.fields.BirthCity__c.updateable;
      this.disabledFields.birthCountry = !data.fields.BirthCountry__c.updateable;
      this.disabledFields.nationality = !data.fields.Nationality__c.updateable;
      this.disabledFields.politicallyExposed = !data.fields.PoliticallyExposed__c.updateable;
      this.disabledFields.rg = !data.fields.RG__c.updateable;
      this.disabledFields.issuer = !data.fields.Issuer__c.updateable;
      this.disabledFields.issueDate = !data.fields.IssueDate__c.updateable;
      this.disabledFields.issuerState = !data.fields.IssuerState__c.updateable;
      this.disabledFields.cnhNumber = !data.fields.CNHnumber__c.updateable;
      this.disabledFields.cnhIssueDate = !data.fields.CNHIssueDate__c.updateable;
      this.disabledFields.cnhIssuer = !data.fields.CNHIssuer__c.updateable;

    }
    else if(error){
      this.showError(error);
    }
  }
}