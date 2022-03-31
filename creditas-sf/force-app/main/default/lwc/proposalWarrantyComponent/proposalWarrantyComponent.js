import { LightningElement, api, wire, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { refreshApex, getSObjectValue } from '@salesforce/apex';
import getFinancialResource from '@salesforce/apex/ProposalWarrantyController.getFinancialResource';
import getWarrantyDataSection from '@salesforce/apex/ProposalWarrantyController.getWarrantyDataSection';

import WARRANTY_SECTION_OBJECT from '@salesforce/schema/WarrantyDataSection__c';
import RENAVAN_STATUS from '@salesforce/schema/WarrantyDataSection__c.RenavamStatus__c';
import RENAVAN_PENDING from '@salesforce/schema/WarrantyDataSection__c.RenavamPendingReason__c';
import RENAVAN_REJECT from '@salesforce/schema/WarrantyDataSection__c.RenavamRejectReason__c';
import RENAVAN_OBS from '@salesforce/schema/WarrantyDataSection__c.RenavamObservation__c';
import PLATE_STATUS from '@salesforce/schema/WarrantyDataSection__c.PlateStatus__c';
import MANUFACTURING_YEAR_STATUS from '@salesforce/schema/WarrantyDataSection__c.ManufacturingYearStatus__c';
import MODEL_YEAR_STATUS from '@salesforce/schema/WarrantyDataSection__c.ModelYearStatus__c';
import MODEL_YEAR_REJECT from '@salesforce/schema/WarrantyDataSection__c.ModelYearRejectReason__c';
import MODEL_YEAR_OBS from '@salesforce/schema/WarrantyDataSection__c.ModelYearObservation__c';
import BRAND_STATUS from '@salesforce/schema/WarrantyDataSection__c.BrandStatus__c';
import MODEL_STATUS from '@salesforce/schema/WarrantyDataSection__c.ModelStatus__c';
import MODEL_REJECT from '@salesforce/schema/WarrantyDataSection__c.ModelRejectReason__c';
import MODEL_OBS from '@salesforce/schema/WarrantyDataSection__c.ModelObservation__c';
import COLOR_STATUS from '@salesforce/schema/WarrantyDataSection__c.ColorStatus__c';
import STATE_STATUS from '@salesforce/schema/WarrantyDataSection__c.UFplateStatus__c';
import LICENSING_STATE_STATUS from '@salesforce/schema/WarrantyDataSection__c.LicensingStateStatus__c';
import LICENSING_STATE_REJECT from '@salesforce/schema/WarrantyDataSection__c.LicensingStateRejectReason__c';
import LICENSING_STATE_OBS from '@salesforce/schema/WarrantyDataSection__c.LicensingStateObservation__c';
import FIPE_CODE_STATUS from '@salesforce/schema/WarrantyDataSection__c.FIPEtableCodeStatus__c';

import FINANCIAL_RESOURCE_OBJECT from '@salesforce/schema/FinancialResources__c';
import RENAVAN_FIELD from '@salesforce/schema/FinancialResources__c.ResourceKey__c';
import PLATE_FIELD from '@salesforce/schema/FinancialResources__c.Plate__c';
import MANUFACTURING_YEAR_FIELD from '@salesforce/schema/FinancialResources__c.ManufacturingYear__c';
import MODEL_YEAR_FIELD from '@salesforce/schema/FinancialResources__c.ModelYear__c';
import BRAND_FIELD from '@salesforce/schema/FinancialResources__c.Brand__c';
import MODEL_FIELD from '@salesforce/schema/FinancialResources__c.Model__c';
import COLOR_FIELD from '@salesforce/schema/FinancialResources__c.Color__c';
import STATE_FIELD from '@salesforce/schema/FinancialResources__c.State__c';
import LICENSING_STATE_FIELD from '@salesforce/schema/FinancialResources__c.LicensingState__c';
import FIPE_CODE_FIELD from '@salesforce/schema/FinancialResources__c.ExternalCodeOrigin__c';
// import CHASSI_FIELD from '@salesforce/schema/FinancialResources__c.ResourceKey__c';

const RECORD_FIELDS = new Map([
  [RENAVAN_FIELD, { elementId: 'inputRenavan', updateable: false }],
  [PLATE_FIELD, { elementId: 'inputPlate', updateable: false }],
  [MANUFACTURING_YEAR_FIELD, { elementId: 'inputManufacturingYear', updateable: false }],
  [MODEL_YEAR_FIELD, { elementId: 'inputModelYear', updateable: false }],
  [BRAND_FIELD, { elementId: 'inputBrand', updateable: false }],
  [MODEL_FIELD, { elementId: 'inputModel', updateable: false }],
  [COLOR_FIELD, { elementId: 'inputColor', updateable: false }],
  [STATE_FIELD, { elementId: 'inputState', updateable: false }],
  [LICENSING_STATE_FIELD, { elementId: 'inputLicensingState', updateable: false }],
  [FIPE_CODE_FIELD, { elementId: 'inputFipeCode', updateable: false }]
  // [CHASSI_FIELD, { elementId: 'inputChassi', updateable: false }],
]);

const STATUS_FIELDS = [
  RENAVAN_STATUS,
  PLATE_STATUS,
  MANUFACTURING_YEAR_STATUS,
  MODEL_YEAR_STATUS,
  BRAND_STATUS,
  MODEL_STATUS,
  COLOR_STATUS,
  STATE_STATUS,
  LICENSING_STATE_STATUS,
  FIPE_CODE_STATUS
];

export default class ProposalWarrantyComponent extends LightningElement {
  @api opportunityid;

  fieldConfig = RECORD_FIELDS;
  financialResource;
  @track financialResourceInfo;
  warrantyDataSection;
  completionPercentage = 0;

  @wire(getFinancialResource, { opportunityId: '$opportunityid' })
  setFinancialResource({ data, error }) {
    if (data) {
      this.financialResource = data;
      console.log('financialResource=>',this.financialResource);
    } else if (error) {
      this.showError(error);
    }
  }

  @wire(getWarrantyDataSection, { opportunityId: '$opportunityid' })
  setWarrantyDataSection({ data, error }) {
    if (data) {
      this.warrantyDataSection = data;
      this.setFieldsInitialState();
    } else if (error) {
      this.showError(error);
    }
  }

  @wire(getObjectInfo, { objectApiName: FINANCIAL_RESOURCE_OBJECT })
  setFinancialResourceInfo({ data, error }) {
    if (data) {
      this.financialResourceInfo = data;
      console.log('financialResourceInfo=>',data);
    } else if (error) {
      this.showError(error);
    }
  }

  @api
  getReasonSelected(result) {
    const validationReason = JSON.parse(result);
    if (validationReason.reason == null) {
      this.uncheckReason(validationReason.field);
    } else {
      // this.setMapReason(validationReason);
    }
  }

  // connectedCallback() {
  //   getRecordNotifyChange({ recordId: this.opportunityid });
  // }

  uncheckReason(reason) {
    const field = this.template.querySelector(`[data-field=${reason}]`);
    field.checked = false;
    field.setAttribute('data-value', '');
    this.sendInfo(this.getInfo());
  }

  setFieldsInitialState() {
    for (const fieldDefinition of STATUS_FIELDS) {
      const fieldApiName = fieldDefinition.fieldApiName;
      const elements = this.template.querySelectorAll([`[data-status=${fieldApiName}]`]);
      elements.forEach(element => {
        if (element.value === this.warrantyDataSection[fieldApiName]) {
          element.checked = true;
          element.setAttribute('data-value', element.value);
        }
      });
    }

    this.sendInfo(this.getInfo());
  }

  handleCheckboxChange(event) {
    const currentCheckbox = event.currentTarget;
    const currentRowCheckboxes = this.template.querySelectorAll(`input[name=${currentCheckbox.name}]`);
    this.checkOnlyOne(currentCheckbox, currentRowCheckboxes);

    const info = this.getInfo();
    const modal = this.getModal(currentCheckbox);

    this.sendInfo({ ...info, modal });
  }

  checkOnlyOne(checkbox, rowCheckboxes) {
    const value = checkbox.value;

    rowCheckboxes.forEach(elem => {
      const oldValue = elem.getAttribute('data-value');
      let newValue = value;

      if (oldValue !== null && elem.value === oldValue) {
        elem.checked = false;
        newValue = '';
      } else if (elem.value === value) {
        newValue = value;
        elem.checked = true;
      }

      elem.setAttribute('data-value', newValue);
    });
  }

  getInfo() {
    const selectedCheckboxes = this.template.querySelectorAll(`input[type='checkbox']:checked`);
    this.updateCompletionPercentage(selectedCheckboxes);

    const variant = this.getVariant(selectedCheckboxes);
    return { variant, value: this.completionPercentage, returnedId: 'ContainerDadosGarantia' };
  }

  updateCompletionPercentage(checkboxes) {
    const selected = checkboxes.length;
    const total = this.fieldConfig.size;
    this.completionPercentage = (selected / total) * 100;
  }

  getVariant(selectedCheckboxes) {
    let isApproved = false;
    let isPending = false;
    let isRejected = false;
    let variant = '';

    selectedCheckboxes.forEach(element => {
      if (element.value === 'Aprovado') {
        isApproved = true;
      } else if (element.value === 'Pendenciado') {
        isPending = true;
      } else if (element.value === 'Rejeitado') {
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

  getModal(checkbox) {
    const modal = {};

    if (checkbox.checked && (checkbox.value == 'Rejeitado' || checkbox.value == 'Pendenciado')) {
      modal['modalReason'] = checkbox.value == 'Rejeitado' ? 'reject' : 'pendency';
      modal['openModalReason'] = true;
      modal['fieldReason'] = checkbox.getAttribute('data-field');
      modal['objectReason'] = WARRANTY_SECTION_OBJECT.objectApiName;
    }

    return modal;
  }

  sendInfo(detail) {
    const event = new CustomEvent('sendinfo', {
      bubbles: true,
      composed: true,
      cancelable: true,
      detail
    });

    this.dispatchEvent(event);
  }

  showError(error) {
    this.error = error;
    this.showToast('Erro', error.body.message, 'error');
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  get renavan() {
    return this.getFinancialResourceValue(RENAVAN_FIELD);
  }

  get renavanDisabled() {
    return this.isFieldDisabled(RENAVAN_FIELD);
  }

  get plate() {
    return this.getFinancialResourceValue(PLATE_FIELD);
  }

  get plateDisabled() {
    return this.isFieldDisabled(PLATE_FIELD);
  }

  get manufacturingYear() {
    return this.getFinancialResourceValue(MANUFACTURING_YEAR_FIELD);
  }

  get manufacturingYearDisabled() {
    return this.isFieldDisabled(MANUFACTURING_YEAR_FIELD);
  }

  get modelYear() {
    return this.getFinancialResourceValue(MODEL_YEAR_FIELD);
  }

  get modelYearDisabled() {
    return this.isFieldDisabled(MODEL_YEAR_FIELD);
  }

  get brand() {
    return this.getFinancialResourceValue(BRAND_FIELD);
  }

  get brandDisabled() {
    return this.isFieldDisabled(BRAND_FIELD);
  }

  get model() {
    return this.getFinancialResourceValue(MODEL_FIELD);
  }

  get modelDisabled() {
    return this.isFieldDisabled(MODEL_FIELD);
  }

  get color() {
    return this.getFinancialResourceValue(COLOR_FIELD);
  }

  get colorDisabled() {
    return this.isFieldDisabled(COLOR_FIELD);
  }

  get state() {
    return this.getFinancialResourceValue(STATE_FIELD);
  }

  get stateDisabled() {
    return this.isFieldDisabled(STATE_FIELD);
  }

  get licensingState() {
    return this.getFinancialResourceValue(LICENSING_STATE_FIELD);
  }

  get licensingStateDisabled() {
    return this.isFieldDisabled(LICENSING_STATE_FIELD);
  }

  get chassi() {
    return this.getFinancialResourceValue(CHASSI_FIELD);
  }

  get chassiDisabled() {
    return this.isFieldDisabled(CHASSI_FIELD);
  }

  get fipeCode() {
    return this.getFinancialResourceValue(FIPE_CODE_FIELD);
  }

  get fipeCodeDisabled() {
    return this.isFieldDisabled(FIPE_CODE_FIELD);
  }

  get saveButtonDisabled() {
    return this.completionPercentage === 100 ? false : true;
  }

  getFinancialResourceValue(fieldDefinition) {
    return this.financialResource ? getSObjectValue(this.financialResource, fieldDefinition) : '';
  }

  isFieldDisabled(fieldDefinition) {
    return this.financialResourceInfo
      ? !this.financialResourceInfo.fields[fieldDefinition.fieldApiName].updateable
      : true;
  }
}