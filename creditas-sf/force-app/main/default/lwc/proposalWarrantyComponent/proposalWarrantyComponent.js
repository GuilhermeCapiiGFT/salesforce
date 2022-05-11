import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getSObjectValue, refreshApex } from '@salesforce/apex';
import getFinancialResource from '@salesforce/apex/ProposalWarrantyController.getFinancialResource';
import getWarrantyDataSection from '@salesforce/apex/ProposalWarrantyController.getWarrantyDataSection';
import saveMethod from '@salesforce/apex/ProposalWarrantyController.saveMethod';

import WARRANTY_SECTION_OBJECT from '@salesforce/schema/WarrantyDataSection__c';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/WarrantyDataSection__c.Opportunity__c';
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
import CHASSIS_STATUS from '@salesforce/schema/WarrantyDataSection__c.ChassiStatus__c';
import CHASSIS_REJECT from '@salesforce/schema/WarrantyDataSection__c.ChassiRejectReason__c';
import CHASSIS_OBS from '@salesforce/schema/WarrantyDataSection__c.ChassiObservation__c';
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
import CHASSIS_FIELD from '@salesforce/schema/FinancialResources__c.Chassis__c';
import FIPE_CODE_FIELD from '@salesforce/schema/FinancialResources__c.ExternalCodeOrigin__c';

const RECORD_FIELDS = new Map([
  ['inputRenavan', RENAVAN_FIELD],
  ['inputPlate', PLATE_FIELD],
  ['inputManufacturingYear', MANUFACTURING_YEAR_FIELD],
  ['inputModelYear', MODEL_YEAR_FIELD],
  ['inputBrand', BRAND_FIELD],
  ['inputModel', MODEL_FIELD],
  ['inputColor', COLOR_FIELD],
  ['inputState', STATE_FIELD],
  ['inputLicensingState', LICENSING_STATE_FIELD],
  ['inputChassis', CHASSIS_FIELD],
  ['inputFipeCode', FIPE_CODE_FIELD]
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
  CHASSIS_STATUS,
  FIPE_CODE_STATUS
];

const SECTION_FIELDS = [
  [RENAVAN_STATUS, RENAVAN_PENDING, RENAVAN_REJECT, RENAVAN_OBS],
  [PLATE_STATUS],
  [MANUFACTURING_YEAR_STATUS],
  [MODEL_YEAR_STATUS, MODEL_YEAR_REJECT, MODEL_YEAR_OBS],
  [BRAND_STATUS],
  [MODEL_STATUS, MODEL_REJECT, MODEL_OBS],
  [COLOR_STATUS],
  [STATE_STATUS],
  [LICENSING_STATE_STATUS, LICENSING_STATE_REJECT, LICENSING_STATE_OBS],
  [CHASSIS_STATUS, CHASSIS_REJECT, CHASSIS_OBS],
  [FIPE_CODE_STATUS]
];

export default class ProposalWarrantyComponent extends LightningElement {
  @api opportunityid;

  recordFields = RECORD_FIELDS;
  statusFields = STATUS_FIELDS;
  sectionFields = SECTION_FIELDS;

  financialResource;
  financialResourceTransaction;
  @track financialResourceInfo;
  recordTypeId;
  licensingStatePicklistValues;

  warrantyDataSection;
  warrantyDataSectionTransaction;

  completionPercentage = 0;

  disabledSaveButton = false;

  @wire(getFinancialResource, { opportunityId: '$opportunityid' })
  setFinancialResource({ data, error }) {
    if (data) {
      this.financialResource = data;
      this.financialResourceTransaction = { ...this.financialResource };
      refreshApex(this.financialResource);
    } else if (error) {
      this.showError(error);
    }
  }

  @wire(getWarrantyDataSection, { opportunityId: '$opportunityid' })
  setWarrantyDataSection({ data, error }) {
    if (data) {
      this.warrantyDataSection = data;
      this.warrantyDataSectionTransaction = {
        ...this.warrantyDataSection
      };
      this.warrantyDataSectionTransaction[OPPORTUNITY_ID_FIELD.fieldApiName] = this.opportunityid;
      refreshApex(this.warrantyDataSection);
      this.setFieldsInitialState();
    } else if (error) {
      this.showError(error);
    }
  }

  @wire(getObjectInfo, { objectApiName: FINANCIAL_RESOURCE_OBJECT })
  setFinancialResourceInfo({ data, error }) {
    if (data) {
      this.financialResourceInfo = data;
    } else if (error) {
      this.showError(error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$financialResource.RecordTypeId',
    fieldApiName: LICENSING_STATE_FIELD
  })
  setLicensingStatePicklistValues({ data, error }) {
    if (data) {
      this.licensingStatePicklistValues = data.values;
    } else if (error) {
      this.showError(error);
    }
  }

  @api
  getReasonSelected(result) {
    const resonWrapper = JSON.parse(result);
    if (resonWrapper.reason == null) {
      this.uncheckReason(resonWrapper.field);
    } else {
      this.setReason(resonWrapper);
    }
  }

  setFieldsInitialState() {
    for (const fieldDefinition of this.statusFields) {
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

  uncheckReason(reason) {
    const field = this.template.querySelector(`[data-field=${reason}]`);
    field.checked = false;
    field.setAttribute('data-value', '');
    this.sendInfo(this.getInfo());
  }

  setReason(reasonWrapper) {
    const observation = reasonWrapper.description ? reasonWrapper.description : '';
    const reason = reasonWrapper.reason;
    const reasonApiName = reasonWrapper.field;
    let observationApiName;

    switch (reasonApiName) {
      case RENAVAN_PENDING.fieldApiName:
      case RENAVAN_REJECT.fieldApiName:
        observationApiName = RENAVAN_OBS.fieldApiName;
        break;
      case MODEL_YEAR_REJECT.fieldApiName:
        observationApiName = MODEL_YEAR_OBS.fieldApiName;
        break;
      case MODEL_REJECT.fieldApiName:
        observationApiName = MODEL_OBS.fieldApiName;
        break;
      case CHASSIS_REJECT.fieldApiName:
        observationApiName = CHASSIS_OBS.fieldApiName;
        break;
      case LICENSING_STATE_REJECT.fieldApiName:
        observationApiName = LICENSING_STATE_OBS.fieldApiName;
    }

    this.warrantyDataSectionTransaction[reasonApiName] = reason;
    this.warrantyDataSectionTransaction[observationApiName] = observation;
  }

  handleCheckboxChange(event) {
    const currentCheckbox = event.target;
    const currentRowCheckboxes = this.template.querySelectorAll(
      `input[name=${currentCheckbox.name}]`
    );

    this.checkOnlyOne(currentCheckbox, currentRowCheckboxes);

    const info = this.getInfo();
    const modal = this.getModal(currentCheckbox);

    this.sendInfo({ ...info, modal });
    this.saveTransactionValue(currentCheckbox);
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

  saveTransactionValue(checkbox) {
    const fieldName = checkbox.getAttribute('data-status');
    const value = checkbox.checked ? checkbox.value : null;
    this.resetSectionFields(fieldName);
    this.warrantyDataSectionTransaction[fieldName] = value;
  }

  resetSectionFields(fieldName) {
    for (const fieldDefinitions of this.sectionFields) {
      const fieldNames = fieldDefinitions.map(field => field.fieldApiName);
      if (fieldNames.indexOf(fieldName) > -1) {
        fieldNames.forEach(name => (this.warrantyDataSectionTransaction[name] = null));
      }
    }
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
    return {
      variant,
      value: this.completionPercentage,
      returnedId: 'ContainerDadosGarantia'
    };
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

  updateCompletionPercentage(checkboxes) {
    const selected = checkboxes.length;
    const total = this.recordFields.size;
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

  handleInputChange(event) {
    const value = event.target.value;
    const elementId = event.target.getAttribute('data-id');
    const fieldDefinition = this.recordFields.get(elementId);
    const fieldApiName = fieldDefinition.fieldApiName;
    this.financialResourceTransaction[fieldApiName] = value;
  }

  async handleSaveSection() {
    this.disabledSaveButton = true;

    const records = {
      warrantyObject: this.warrantyDataSectionTransaction,
      financialResource: this.financialResourceTransaction
    };

    try {
      await saveMethod(records);
      getRecordNotifyChange([
        { recordId: this.financialResource.Id },
        { recordId: this.warrantyDataSection.Id }
      ]);
      this.showToast('Registro atualizado com sucesso!', '', 'success');
      this.disabledSaveButton = false;
    } catch (error) {
      const message = error?.body?.message ? error.body.message : '';
      this.showToast('Erro ao atualizar registro!', message, 'error');
      this.disabledSaveButton = false;
    }
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

  get licensingStateOptions() {
    const options = [];

    if (this.licensingStatePicklistValues) {
      for (const item of this.licensingStatePicklistValues) {
        const { label, value } = item;
        const option = { label, value };
        options.push(option);
      }
    }

    return options;
  }

  get licensingStateDisabled() {
    return this.isFieldDisabled(LICENSING_STATE_FIELD);
  }

  get chassis() {
    return this.getFinancialResourceValue(CHASSIS_FIELD);
  }

  get chassisDisabled() {
    return this.isFieldDisabled(CHASSIS_FIELD);
  }

  get fipeCode() {
    return this.getFinancialResourceValue(FIPE_CODE_FIELD);
  }

  get fipeCodeDisabled() {
    return this.isFieldDisabled(FIPE_CODE_FIELD);
  }

  get saveButtonDisabled() {
    return this.disabledSaveButton || (this.completionPercentage === 100 ? false : true);
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