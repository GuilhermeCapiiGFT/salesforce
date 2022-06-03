import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLastIncomeDataSectionInstance from '@salesforce/apex/ProposalIncomeDataController.getLastIncomeDataSectionInstance';
import saveInstance from '@salesforce/apex/ProposalIncomeDataController.saveInstance';
import { observationByStatus, disabledFields } from './proposalIncomeConsts';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import INCOME_DATA_SECTION_OBJECT from '@salesforce/schema/IncomeDataSection__c';
import STATUS_FIELD from '@salesforce/schema/IncomeDataSection__c.Status__c';
import NETWORTH_FIELD from '@salesforce/schema/IncomeDataSection__c.NetWorth__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

const SUCCESS_SAVED = 'Dados de Renda atualizado com sucesso!';
const PENDENCY_STATUS = 'Pendenciar';
const REJECTION_STATUS = 'Rejeitar';
const APPROVED_STATUS = 'Aprovar';
const RETURNED_PENDENCY_STATUS = 'Voltou de pendência';
const VALIDATION_ROWS = 7;
const COMPONENT_ID = 'ContainerDadosRenda';

export default class ProposalIncomeDataComponent extends LightningElement {

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
  incomeDataSectionRecord;
  recordSaved = true;
  disabledFields = disabledFields;
  statusReturnedPendency = RETURNED_PENDENCY_STATUS;
  completionPercentage = 0;
  incomeSectionMetadata = '';
  professionalStateOptions;
  netWorthOptions;
  lastCheckBoxName;

  // Checkboxes Values
  value = [];
  preValue = [];

  getDataSectionInstance(oppId) {

    getLastIncomeDataSectionInstance( {oppId : oppId})
      .then( result => {

        this.incomeDataSectionRecord = ( result != null ) ? result : {} ;
        this.buildDataSection();

        })
      .catch(error => {

        this.showError(error);

      });
    
  }

  handleInputChange(event) {

    this.recordSaved = false;
    this.incomeDataSectionRecord[event.target.dataset.id] = event.target.value;
    this.sendInfo(this.getInfo());
  }

  handleSaveSection() {
    
    this.disabledBtnSave = true;

    let recordToSend = JSON.stringify(this.incomeDataSectionRecord);
  
    saveInstance({serializedIncomeDataSection : recordToSend}).
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
    let lastValueOnCheckbox = this.incomeDataSectionRecord[currentCheckBoxField];

    this.incomeDataSectionRecord[currentCheckBoxField] = ( lastValueOnCheckbox != currentCheckboxValue ) ? currentCheckboxValue : null;
    
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
      modal['objectReason'] = INCOME_DATA_SECTION_OBJECT.objectApiName;

    }

    return modal;
  }

  checkOnlyOne(currentCheckbox, rowCheckboxes) {
    
    let currentCheckboxValue = this.incomeDataSectionRecord[ currentCheckbox.target.dataset.status ];
  
    rowCheckboxes.forEach(checkbox => {
      
      if ( checkbox.value == currentCheckboxValue ) {
        
        checkbox.checked = true;

      } else {

        checkbox.checked = false;
        let fieldToClear = checkbox.getAttribute('data-field');

        if ( !fieldToClear ) return;

        this.incomeDataSectionRecord[fieldToClear] = ( checkbox.value != APPROVED_STATUS ) ? null : this.incomeDataSectionRecord[fieldToClear];

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

  @api
  getReasonSelected(result) {

    let validationReason = JSON.parse(result);

    ( validationReason.reason == null ) ? this.uncheckReason(validationReason) : this.saveReasonOnRecord(validationReason);
  
  }

  uncheckReason(validationReason){

    this.recordSaved = false;
    let field = this.template.querySelector('[data-field="' + validationReason.field + '"]');
    field.checked = false;

    this.incomeDataSectionRecord[validationReason.field] = null;
    let observationField = observationByStatus.get(this.lastCheckBoxName);
    this.incomeDataSectionRecord[observationField] = null;

    this.sendInfo(this.getInfo());
  }

  saveReasonOnRecord(validationReason) {

    this.recordSaved = false;
    this.incomeDataSectionRecord[validationReason.field] = validationReason.reason;
    let observationField = observationByStatus.get(this.lastCheckBoxName);
    this.incomeDataSectionRecord[observationField] = ( validationReason.description != null ) ? validationReason.description : null;
    
    this.sendInfo(this.getInfo());
  }

  showError(error) {

    this.error = error;
    this.showToast('Erro', error.body.message, 'error');

  }

  buildDataSection() {

    
    this.showContainer = true;
    
  }

  renderedCallback() {

    if ( this.initialRender ) return;

    this.loadCheckedStatusFromRecord();

  }

  loadCheckedStatusFromRecord() {

    for (let indexField in this.incomeDataSectionRecord ) {

      this.template.querySelectorAll("[data-status='"+indexField+"']").forEach( item => {

        let dataValue = item.hasAttribute("data-value") ? item.getAttribute("data-value") : null;

        if ( dataValue == this.incomeDataSectionRecord[indexField]
            && dataValue == RETURNED_PENDENCY_STATUS ) {
         
            item.classList.add('show_icon_pendency');
        }

        if (item.value === this.incomeDataSectionRecord[indexField]) {
          item.checked = true;
          item.setAttribute('data-value', item.value);
        }

        this.initialRender = true;

      });
    }

    this.sendInfo(this.getInfo());
  }

  @wire(getObjectInfo, { objectApiName: INCOME_DATA_SECTION_OBJECT })
  getOperationPermission({ error, data }) {
    
    if (data) {
    
      this.incomeSectionMetadata = data;
      this.disabledFields.minimalRequiredIncome = !data.fields.MinimalRequiredIncome__c.updateable;
      this.disabledFields.presumedMonthlyIncome = !data.fields.PresumedMonthlyIncome__c.updateable;
      this.disabledFields.confirmedMonthlyIncome = !data.fields.ConfirmedMonthlyIncome__c.updateable;
      this.disabledFields.monthlyIncome = !data.fields.MonthlyIncome__c.updateable;
      this.disabledFields.status = !data.fields.Status__c.updateable;
      this.disabledFields.jobTitle = !data.fields.JobTitle__c.updateable;
      this.disabledFields.networth = !data.fields.NetWorth__c.updateable;

    }

    else if(error){
      this.showError(error);
    }
  }

  @wire(getPicklistValues,{ recordTypeId: '$incomeSectionMetadata.defaultRecordTypeId', fieldApiName: STATUS_FIELD })
  getPicklistValuesForProfissionalState({ error, data }) {

    if ( data ) {

      this.professionalStateOptions = data.values;
      
    } else if(error){
      this.showError(error);
    }
  }

  @wire(getPicklistValues,{ recordTypeId: '$incomeSectionMetadata.defaultRecordTypeId', fieldApiName: NETWORTH_FIELD })
  getPicklistValuesForNetworth({ error, data }) {

    if ( data ) {

      this.netWorthOptions = data.values;
      
    } else if(error){
      this.showError(error);
    }
  }


}