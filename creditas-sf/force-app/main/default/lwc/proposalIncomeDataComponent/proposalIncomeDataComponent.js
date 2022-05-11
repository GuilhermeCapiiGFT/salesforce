import { LightningElement, api, wire, track } from 'lwc';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import FINANCIAL_RESOURCES_OBJECT from '@salesforce/schema/FinancialResources__c';
import PROFESSIONAL_INFO_OBJECT from '@salesforce/schema/ProfessionalInfo__c';

import SECTION_OBJECT from '@salesforce/schema/IncomeDataSection__c';

import STATUS_FIELD from '@salesforce/schema/ProfessionalInfo__c.Status__c';
import JOB_TITLE_FIELD from '@salesforce/schema/ProfessionalInfo__c.JobTitle__c';

import MONTHLY_INCOME_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';
import PRESUMED_MONTHLY_INCOME_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';
import CONFIRMED_MONTHLY_INCOME_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';

import LOWER_NETWORTH__INCOME_FIELD from '@salesforce/schema/Account.NetWorthLowerLimit__c';
import UPPER_NETWORTH__INCOME_FIELD from '@salesforce/schema/Account.NetWorthUpperLimit__c';

import MINIMAL_INCOME_FIELD from '@salesforce/schema/Opportunity.MinimalRequiredIncome__c';

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

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getRecordIncomeSection from '@salesforce/apex/ProposalIncomeDataController.getIncomeDetails';
import upsertIncomeDetailsSection from '@salesforce/apex/ProposalIncomeDataController.saveIncomeDataSection';

const FIELDSVALIDATIONPROFESSIONALSITUATION = [PROFESSIONALSITUATIONSTATUS, PROFESSIONALSITUATIONPENDINGREASON, PROFESSIONALSITUATIONOBSERVATION]
const FIELDSVALIDATIONPROFESSION = [PROFESSIONSTATUS, PROFESSIONPENDINGREASON, PROFESSIONOBSERVATION]
const FIELDSVALIDATIONNETWORTH = [NETWORTHSTATUS]
const FIELDSVALIDATIONMONTHLYINCOME = [MONTHLYINCOMESTATUS, MONTHLYINCOMEPENDINGREASON, MONTHLYINCOMEOBSERVATION]
const FIELDSVALIDATIONMINIMALREQUIREDINCOME = [MINIMALREQUIREDINCOMESTATUS, MINIMALREQUIREDINCOMEREJECTREASON, MINIMALREQUIREDINCOMEOBSERVATION]
const FIELDSVALIDATIONPRESUMEDINCOME = [PRESUMEDMONTHLYINCOMESTATUS]
const FIELDSVALIDATIONCONFIRMEDINCOME = [CONFIRMEDMONTHLYINCOMESTATUS]

const FIELDSPROFESSIONALINFO = [STATUS_FIELD, JOB_TITLE_FIELD]
const FIELDSFINANCIAL = [MONTHLY_INCOME_FIELD]
const FIELDSOPPORTUNITY = [MINIMAL_INCOME_FIELD]
const FIELDSACCOUNT = [LOWER_NETWORTH__INCOME_FIELD, UPPER_NETWORTH__INCOME_FIELD]

const RECORD_FIELDS = new Map([
  ['inputState', STATUS_FIELD],
  ['inputJobTitle', JOB_TITLE_FIELD],
  ['inputMinimalMonthlyIncome', MINIMAL_INCOME_FIELD],
  ['inputMonthlyIncome', MONTHLY_INCOME_FIELD],
  ['inputPresumedMonthlyIncome', PRESUMED_MONTHLY_INCOME_FIELD],
  ['inputConfirmedMonthlyIncome', CONFIRMED_MONTHLY_INCOME_FIELD]
])

export default class ProposalIncomeDataComponent extends LightningElement {

  @api opportunityid
  @api accountid
  error

  recordFields = RECORD_FIELDS

  professionalInfo
  professionalStateOptions = []

  income
  professionalInfoRecordTypeId
  recordTypeId

  fieldsValidation = [FIELDSVALIDATIONPROFESSIONALSITUATION, FIELDSVALIDATIONPROFESSION, FIELDSVALIDATIONNETWORTH, FIELDSVALIDATIONMONTHLYINCOME, FIELDSVALIDATIONMINIMALREQUIREDINCOME, FIELDSVALIDATIONPRESUMEDINCOME, FIELDSVALIDATIONCONFIRMEDINCOME]
  fieldsStatus = ['ProfessionalSituationStatus__c', 'ProfessionStatus__c', 'NetWorthStatus__c', 'MonthlyIncomeStatus__c', 'MinimalRequiredIncomeStatus__c', 'PresumedMonthlyIncomeStatus__c', 'ConfirmedMonthlyIncomeStatus__c']
  
  fieldsProfessionalInfo = FIELDSPROFESSIONALINFO
  fieldsFinancialResources = FIELDSFINANCIAL
  fieldsOpportunity = FIELDSOPPORTUNITY
  fieldsAccount = FIELDSACCOUNT

  // Controller save button
  disabledSaveButton = false
  topContainerSection = 'ContainerDadosRenda'

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

  recordTypeId
  statePicklistValues

  // Checkboxes Values
  value = [];
  preValue = [];
  totalLinesValidation = 7;
  statusApprove = 'Aprovar';
  statusReject = 'Rejeitar';
  statusPending = 'Pendenciar';
  completionPercentage = 0;

  @track recordIncome = new Map()

  // Array converted to payload afterwards
  incomeValue = []

  // Map picklist
  netWorthOptions = [
    {label: 'Até R$ 30.000,00', value: '0-30000'},
    {label: 'Entre R$ 30.000,01 e R$ 50.000,00', value: '30000,01-50000'},
    {label: 'Entre R$ 50.000,01 e R$ 70.000,00', value: '50000,01-70000'},
    {label: 'Entre R$ 70.000,01 e R$ 90.000,00', value: '70000,01-90000'},
    {label: 'Entre R$ 90.000,01 e R$ 150.000,00', value: '90000,01-150000'},
    {label: 'Entre R$ 150.000,01 e R$ 200.000,00', value: '150000,01-200000'},
    {label: 'Entre R$ 200.000,01 e R$ 300.000,00', value: '200000,01-300000'},
    {label: 'Entre R$ 300.000,01 e R$ 500.000,00', value: '300000,01-500000'},
    {label: 'Entre R$ 500.000,01 e R$ 700.000,00', value: '500000,01-700000'},
    {label: 'Entre R$ 700.000,01 e R$ 1.000.000,00', value: '700000,01-1000000'},
    {label: 'Acima de R$ 1.000.000,01', value: '1000000,01-1000000,01'}
  ]

  // refresh apex
  refreshRecordIncome
  
  // validation object for the income section
  objValidationSection = {
    'sobjectType': SECTION_OBJECT.objectApiName
  }

  @wire(getRecordIncomeSection, {accountId: '$accountid', opportunityId: '$opportunityid' })
  recordIncomeSection(result) {
    this.refreshRecordIncome = result

    if (result.data) {

      this.recordIncome.set('ProfessionalInfo', {...this.getSObject(this.fieldsProfessionalInfo), ...result.data.PROFESSIONAL_SECTION})
      this.recordIncome.set('MinimalRequiredIncome', {...this.getSObject(this.fieldsOpportunity), ...result.data.MINIMAL_INCOME})
      this.recordIncome.set('MonthlyIncomeInfo', {...this.getSObject(this.fieldsFinancialResources), ...result.data.MONTHLY_INCOME})
      this.recordIncome.set('PresumedMonthlyIncomeInfo', {...this.getSObject(this.fieldsFinancialResources), ...result.data.PRESUMED_MONTHLY_INCOME})
      this.recordIncome.set('ConfirmedMonthlyIncomeInfo', {...this.getSObject(this.fieldsFinancialResources), ...result.data.CONFIRMED_MONTHLY_INCOME})
      this.recordIncome.set('NetworthIncomeInfo', {...this.getSObject(this.fieldsAccount), ...result.data.NETWORTH_INCOME})

      let validationSection           = result.data?.INCOME_SECTION
      let professionalInfo            = result.data?.PROFESSIONAL_SECTION
      let monthlyIncomeInfo           = result.data?.MONTHLY_INCOME
      let presumedMonthlyIncomeInfo   = result.data?.PRESUMED_MONTHLY_INCOME
      let confirmedMonthlyIncomeInfo  = result.data?.CONFIRMED_MONTHLY_INCOME
      let minimalMonthlyIncomeInfo    = result.data?.MINIMAL_INCOME
      let financialInfo               = {monthlyIncomeInfo, confirmedMonthlyIncomeInfo, presumedMonthlyIncomeInfo, minimalMonthlyIncomeInfo}

      this.setIncomeValidationSection(validationSection)
      this.setProfessionalInfo(professionalInfo)
      this.setFinancialResource(financialInfo)
      this.networth.value = this.getNetworthValue()
      
    } else if (result.error) {
      this.showError(result.error)
    } 
  }

  getNetworthValue() {
    let networth = this.recordIncome.get('NetworthIncomeInfo')
    let picklistValue = ''

    this.netWorthOptions.map((option, index) => {

      if (parseFloat(option.value.split('-')[0]) < networth.NetWorthUpperLimit__c ||
         (index == 0 && networth.NetWorthUpperLimit__c <= parseFloat(this.netWorthOptions[0].value.split('-')[0])))
      {
        picklistValue = option.value
      } 
    })

    return picklistValue === '' ? this.netWorthOptions[this.netWorthOptions.size - 1] : picklistValue
  }

  @wire(getObjectInfo, { objectApiName: PROFESSIONAL_INFO_OBJECT })
  getProfessionalInfo({ error, data }) {
    if (data) {
      this.professionalInfoRecordTypeId = data.defaultRecordTypeId
    } else if(error) {
      this.showError(error);
    }
  }

  @wire(getPicklistValues, { recordTypeId: '$professionalInfoRecordTypeId', fieldApiName: STATUS_FIELD})
  getProfessionalStateOptions({ error, data }) {
    if (data) {
      this.professionalStateOptions = data.values
    } else if (error) {
      this.showError(error);
    }
  }

  getSObject(object){
    let sObject = {}; 
    Object.values(object).forEach(key => {sObject[key.fieldApiName] = ''});
    return sObject;
  }

  // Get fields permission in Account
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT  })
  recordTypeAccount({ error, data }) {
    if(data) {

      if (!data?.fields?.NetWorthUpperLimit__c.updateable && !data?.fields?.NetWorthLowerLimit__c.updateable) {
        this.networth.fieldReadOnly = !data?.fields?.NetWorthUpperLimit__c.updateable
      }
    }
    else if(error){
      this.showError(error);
    }
  }

  //Get fields permission in FINANCIAL RESOURCES
  @wire(getObjectInfo, { objectApiName: FINANCIAL_RESOURCES_OBJECT  })
  recordTypeFinancial({ error, data }) {
    if (data) {
      this.minimalRequiredIncome.fieldReadOnly  = !data?.fields?.Amount__c.updateable
      this.presumedMonthlyIncome.fieldReadOnly  = !data?.fields?.Amount__c.updateable 
      this.confirmedMonthlyIncome.fieldReadOnly = !data?.fields?.Amount__c.updateable
    }
    else if(error){
      this.showError(error);
    }
  }

  // Get fields permission in Opportunity
  @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT  })
  recordTypeOpp({ error, data }) {
    if(data) {
      this.monthlyIncome.fieldReadOnly = !data?.fields?.MinimalRequiredIncome__c.updateable;
    }
    else if(error){
      this.showError(error);
    }
  }

  // Get fields permission in ProfessionalInfo
  @wire(getObjectInfo, { objectApiName: PROFESSIONAL_INFO_OBJECT  })
  recordTypeOpp({ error, data }) {
    if(data) {
      this.status.fieldReadOnly   = !data?.fields?.Status__c.updateable;
      this.jobTitle.fieldReadOnly = !data?.fields?.JobTitle__c.updateable;
    }
    else if(error){
      this.showError(error);
    }
  }

  setIncomeValidationSection(validationSection) {
    let resultValidationSection = { ...this.objValidationSection, ...validationSection };
    
    this.objValidationSection = resultValidationSection;
    let listStatus = this.fieldsStatus;
    for(let index in listStatus){
        let status = listStatus[index];
        this.template.querySelectorAll("[data-status='"+status+"']").forEach(function(item) {
        if (item.value === resultValidationSection[status]) {
            item.checked = true;
            item.setAttribute('data-value', item.value);
        }
        });
    }

    this.sendInfo(this.getInfo());
  }

  setProfessionalInfo(professionalInfo) {
    this.status.value   = professionalInfo.Status__c   ? professionalInfo.Status__c   : null
    this.jobTitle.value = professionalInfo.JobTitle__c ? professionalInfo.JobTitle__c : null
  }

  setFinancialResource(financialInfo) {
    this.monthlyIncome.value          = financialInfo.monthlyIncomeInfo           ? financialInfo.monthlyIncomeInfo?.Amount__c : null
    this.minimalRequiredIncome.value  = financialInfo.minimalMonthlyIncomeInfo    ? financialInfo.minimalMonthlyIncomeInfo?.MinimalRequiredIncome__c : null
    this.presumedMonthlyIncome.value  = financialInfo.presumedMonthlyIncomeInfo   ? financialInfo.presumedMonthlyIncomeInfo?.Amount__c : null
    this.confirmedMonthlyIncome.value = financialInfo.confirmedMonthlyIncomeInfo  ? financialInfo.confirmedMonthlyIncomeInfo?.Amount__c : null
  }

  
  handleSaveSection() {
    this.disabledSaveButton = true;
    this.objValidationSection.Opportunity__c = this.opportunityid;

    upsertIncomeDetailsSection({records: {
      "IncomeSection": this.objValidationSection,
      'ProfessionalInfo': this.recordIncome.get('ProfessionalInfo'),
      'MinimalRequiredIncome': this.recordIncome.get('MinimalRequiredIncome'),
      'MonthlyIncomeInfo': this.recordIncome.get('MonthlyIncomeInfo'),
      'PresumedMonthlyIncomeInfo': this.recordIncome.get('PresumedMonthlyIncomeInfo'),
      'ConfirmedMonthlyIncomeInfo': this.recordIncome.get('ConfirmedMonthlyIncomeInfo'),
      'NetworthIncomeInfo': this.recordIncome.get('NetworthIncomeInfo')
      }
    })
    .then( result=>{
      refreshApex(this.refreshRecordOperation);
      this.showToast('', 'Registro atualizado com sucesso!', 'success')
      this.disabledSaveButton = false;
    })
    .catch(error =>{
      this.disabledSaveButton = false;
      this.showError(error);
    })
  }

  saveFieldsValidation() {
    this.objValidationSection.Opportunity__c = this.opportunityid;
    let payload = this.objValidationSection
    
    upsertIncomeSection({incomeDataSection : payload})
    .then(result => {
      refreshApex(this.recordIncome);
      this.showToast('', 'Registro atualizado com sucesso!', 'success')
      this.disabledSaveButton = false;
    })
    .catch(error =>{
      this.disabledSaveButton = false;
      this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error')
    })
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

  get controllerSave(){
    return (this.disabledSaveButton || (this.completionPercentage === 100 ? false : true));
  }

  handleChangeCheckbox(event) {
    const currentCheckbox = event.target;
    const currentRowCheckboxes = this.template.querySelectorAll(
      `input[name=${currentCheckbox.name}]`
    );

    this.checkOnlyOne(currentCheckbox, currentRowCheckboxes);

    const info = this.getInfo();
    const modal = this.getModal(currentCheckbox);

    this.sendInfo({ ...info, modal });
    this.saveObjectValues(event);
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
      returnedId: this.topContainerSection
    };
  }

  getVariant(selectedCheckboxes) {
    let isApproved = false;
    let isPending = false;
    let isRejected = false;
    let variant = '';

    selectedCheckboxes.forEach(element => {
      if (element.value === this.statusApprove) {
        isApproved = true;
      } else if (element.value === this.statusPending) {
        isPending = true;
      } else if (element.value === this.statusReject) {
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
    const total = this.totalLinesValidation;
    this.completionPercentage = (selected / total) * 100;
  }

  getModal(checkbox) {
    const modal = {};

    if (checkbox.checked && (checkbox.value == this.statusReject || checkbox.value == this.statusPending)) {
      modal['modalReason'] = checkbox.value == this.statusReject ? 'reject' : 'pendency';
      modal['openModalReason'] = true;
      modal['fieldReason'] = checkbox.getAttribute('data-field');
      modal['objectReason'] = SECTION_OBJECT.objectApiName;
    }

    return modal;
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

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event)
  }

  showError(error) {
    this.error = error;
    this.showToast('Erro', error.body.message, 'error');
  }

  @api
  getReasonSelected(result){
    let validationReason = JSON.parse(result)
    if (validationReason.reason == null) {
      this.uncheckReason(validationReason.field)
    } else{
      this.setMapReason(validationReason)
    }
  }

  uncheckReason(reason){
    let field = this.template.querySelector('[data-field="'+reason+'"]');
    field.checked = false;
    field.setAttribute('data-value', '');
    this.sendInfo(this.getInfo());
  }

  setMapReason(selectedReason){

    let observation = selectedReason.description ? selectedReason.description : ''
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

  handleInputChange(event){
    const fieldType = event.target.type;
    const value = (fieldType === 'number') ? parseFloat(event.target.value) : event.target.value;
    const elementId = event.target.getAttribute('data-id');
    const fieldDefinition = this.recordFields.get(elementId);
    const fieldApiName = fieldDefinition.fieldApiName;
    let records = this.recordIncome;
    for (let [key, item] of records.entries()) {
      
      if (item.hasOwnProperty(fieldApiName)) {
        this.recordIncome.set(
          key,
          {...this.recordIncome.get(key), [fieldApiName]: value},
        );
      }
    }
  }

  handleNetworthChange(event) {
    const value = event.target.value.split('-');

    this.recordIncome.set(
      'NetworthIncomeInfo',
      {
        ...this.recordIncome.get('NetworthIncomeInfo'),
        [LOWER_NETWORTH__INCOME_FIELD.fieldApiName]: value[0],
        [UPPER_NETWORTH__INCOME_FIELD.fieldApiName]: value[1]
      },
    );
  }
}