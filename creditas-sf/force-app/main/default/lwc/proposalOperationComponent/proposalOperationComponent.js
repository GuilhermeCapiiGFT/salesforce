import { LightningElement, wire, api, track } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
import getRecordOperationSection from '@salesforce/apex/ProposalOperationController.getOperationDetails';
import upsertOperationDetailsSection from '@salesforce/apex/ProposalOperationController.saveOperationDetails';

import QUOTE_OBJECT from '@salesforce/schema/Quote';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import OPERATION_OBJECT from '@salesforce/schema/OperationSection__c';
import FINANCIALRESOURCES_OBJECT from '@salesforce/schema/FinancialResources__c';

import DESCRIPTION_FIELD from '@salesforce/schema/Quote.Description';
import ADDITIONAL_COSTS_FIELD from '@salesforce/schema/Quote.ParameterAdditionalCosts__c';
import TAC_FIELD from '@salesforce/schema/Quote.ParameterTac__c';
import IOF_FIELD from '@salesforce/schema/Quote.ParameterIOF__c';
import MONTHLY_CET_FIELD from '@salesforce/schema/Quote.MonthlyCet__c';
import YEARLY_CET_FIELD from '@salesforce/schema/Quote.YearlyCet__c';
import MONTHLY_INTEREST_FIELD from '@salesforce/schema/Quote.MonthlyInterest__c';
import YEARLY_INTEREST_FIELD from '@salesforce/schema/Quote.YearlyInterest__c';
import SERVICE_DATE_FIELD from '@salesforce/schema/Quote.ServiceDate__c';
import SERVICE_LAST_DATE_FIELD from '@salesforce/schema/Quote.ServiceLastDate__c';
import NET_FIELD from '@salesforce/schema/Quote.NetValue__c';
import UNIT_PRICE_FIELD from '@salesforce/schema/Quote.UnitPrice__c';
import QUANTITY_FIELD from '@salesforce/schema/Quote.Quantity__c';

import BENEFICIARY_NAME_FIELD from '@salesforce/schema/Account.Name';
import BENEFICIARY_CNPJ_FIELD from '@salesforce/schema/Account.CompanyCNPJ__c';
import BANK_NAME_FIELD from '@salesforce/schema/Account.BankName__c';
import AGENCY_FIELD from '@salesforce/schema/Account.Agency__c';
import BANK_NUMBER_FIELD from '@salesforce/schema/Account.BankAccountNumber__c';
import NET_WORTH_FIELD from '@salesforce/schema/Account.NetWorthLowerLimit__c';

import MANUFACTURING_YEAR_FIELD from '@salesforce/schema/FinancialResources__c.ManufacturingYear__c';
import AMOUNT_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';

import QUANTITYSTATUS from '@salesforce/schema/OperationSection__c.QuantityStatus__c';
import QUANTITYREJECTION from '@salesforce/schema/OperationSection__c.QuantityRejectReason__c';
import QUANTITYDESC from '@salesforce/schema/OperationSection__c.QuantityObservation__c';

const FIELDSVALIDATIONQUANTITY = [QUANTITYSTATUS, QUANTITYREJECTION, QUANTITYDESC];
const FIELDSQUOTE = [DESCRIPTION_FIELD, ADDITIONAL_COSTS_FIELD, TAC_FIELD, IOF_FIELD, MONTHLY_CET_FIELD, YEARLY_CET_FIELD, MONTHLY_INTEREST_FIELD, YEARLY_INTEREST_FIELD, SERVICE_DATE_FIELD, SERVICE_LAST_DATE_FIELD, NET_FIELD, UNIT_PRICE_FIELD, QUANTITY_FIELD];
const FIELDSFINANCIAL = [AMOUNT_FIELD, MANUFACTURING_YEAR_FIELD];
const FIELDSACCOUNT =  [BENEFICIARY_NAME_FIELD, BENEFICIARY_CNPJ_FIELD, BANK_NAME_FIELD, AGENCY_FIELD, BANK_NUMBER_FIELD, NET_WORTH_FIELD];

const INPUT_OPERATION = new Map([
  ['inputFinalidadeOperacao' , DESCRIPTION_FIELD],
  ['inputValorCarro'         , AMOUNT_FIELD],
  ['inputAnoCarro'           , MANUFACTURING_YEAR_FIELD],
  ['inputDespesasRegistro'   , ADDITIONAL_COSTS_FIELD],
  ['inputTAC'                , TAC_FIELD],
  ['inputIOF'                , IOF_FIELD],
  ['inputCETmes'             , MONTHLY_CET_FIELD],
  ['inputCETano'             , YEARLY_CET_FIELD],
  ['inputJurosMes'           , MONTHLY_INTEREST_FIELD],
  ['inputJurosAno'           , YEARLY_INTEREST_FIELD],
  ['inputPrimeiraParcela'    , SERVICE_DATE_FIELD],
  ['inputUltimaParcela'      , SERVICE_LAST_DATE_FIELD],
  ['inputCreditoLiquido'     , NET_FIELD],
  ['inputParcela'            , UNIT_PRICE_FIELD],
  ['inputQtdParcelas'        , QUANTITY_FIELD],
  ['inputNomeBeneficiario'   , BENEFICIARY_NAME_FIELD],
  ['inputCNPJBeneficiario'   , BENEFICIARY_CNPJ_FIELD],
  ['inputBanco'              , BANK_NAME_FIELD],
  ['inputAgencia'            , AGENCY_FIELD],
  ['inputContaCorrente'      , BANK_NUMBER_FIELD],
  ['inputPatrimonio'         , NET_WORTH_FIELD]
]);

export default class ProposalOperationComponent extends LightningElement {

  @api accountid;
  @api opportunityid;

  fieldsValidationQuantity = FIELDSVALIDATIONQUANTITY;
  fieldsStatus = ['BranchStatus__c', 'AccountStatus__c', 'ServiceDateStatus__c', 'ServiceLastDateStatus__c', 'OperationPurposeStatus__c', 'UnitPriceStatus__c', 'YearlyInterestStatus__c', 'MonthlyInterestStatus__c', 'AdditionalCostsStatus__c', 'ManufacturingYearStatus__c', 'BankStatus__c', 'YearlyCETstatus__c', 'MonthlyCETstatus__c', 'BeneficiarysCNPJstatus__c', 'ParameterIOFstatus__c', 'BeneficiarysNameStatus__c', 'ContractNumberStatus__c', 'ParameterTACstatus__c', 'CarValueStatus__c', 'NetValueStatus__c', 'PatrimonyStatus__c', 'QuantityStatus__c'];
  fieldsQuote = FIELDSQUOTE;
  fieldsFinancial = FIELDSFINANCIAL;
  fieldsProponent = FIELDSACCOUNT;
  // Controller btn save
  disabledSaveButton = false;
  topContainerSection = 'ContainerOperation';
  
  // Operation Data Info
  inputOperation = INPUT_OPERATION;
  
  @track valueFinalidadeOp     = {value: '', fieldReadOnly: true};
  @track valueNomeBeneficiario = {value: '', fieldReadOnly: true};
  @track valueCNPJBeneficiario = {value: '', fieldReadOnly: true};
  @track valueBanco            = {value: '', fieldReadOnly: true};
  @track valueAgencia          = {value: '', fieldReadOnly: true};
  @track valueContaCorrente    = {value: '', fieldReadOnly: true};
  @track valuePatrimonio       = {value: '', fieldReadOnly: true};
  @track valueValorCarro       = {value: '', fieldReadOnly: true};
  @track valueAnoCarro         = {value: '', fieldReadOnly: true};
  @track valueDespesasRegistro = {value: '', fieldReadOnly: true};
  @track valueTAC              = {value: '', fieldReadOnly: true};
  @track valueIOF              = {value: '', fieldReadOnly: true};
  @track valueCETmes           = {value: '', fieldReadOnly: true};
  @track valueCETano           = {value: '', fieldReadOnly: true};
  @track valueJurosMes         = {value: '', fieldReadOnly: true};
  @track valueJurosAno         = {value: '', fieldReadOnly: true};
  @track valuePrimeiraParcela  = {value: '', fieldReadOnly: true};
  @track valueUltimaParcela    = {value: '', fieldReadOnly: true};
  @track valueCreditoLiquido   = {value: '', fieldReadOnly: true};
  @track valueParcela          = {value: '', fieldReadOnly: true};
  @track valueQtdParcelas      = {value: '', fieldReadOnly: true};
  
  // Checkboxes Values
  value = [];
  preValue = [];
  totalLinesValidation = 21;
  @track recordOperation = new Map();
  statusApprove = 'Aprovar';
  statusReject = 'Rejeitar';
  statusPending = 'Pendenciar';
  completionPercentage = 0;
  
  // refresh apex 
  refreshRecordOperation;

  // object of validation Section OperationSection__c
  objValidationSection = {
    'sobjectType': 'OperationSection__c',
    'Opportunity__c': '',
    'BranchStatus__c': '',
    'AccountStatus__c': '',
    'ServiceDateStatus__c': '',
    'ServiceLastDateStatus__c': '',
    'OperationPurposeStatus__c': '',
    'UnitPriceStatus__c': '',
    'YearlyInterestStatus__c': '',
    'MonthlyInterestStatus__c': '',
    'AdditionalCostsStatus__c': '',
    'ManufacturingYearStatus__c': '',
    'BankStatus__c': '',
    'YearlyCETstatus__c': '',
    'MonthlyCETstatus__c': '',
    'BeneficiarysCNPJstatus__c': '',
    'ParameterIOFstatus__c': '',
    'BeneficiarysNameStatus__c': '',
    'ContractNumberStatus__c': '',
    'ParameterTACstatus__c': '',
    'CarValueStatus__c': '',
    'NetValueStatus__c': '',
    'PatrimonyStatus__c': '',
    'QuantityStatus__c': '',
    'QuantityRejectReason__c': '',
    'QuantityObservation__c': ''
  }
  
  // Get fields permission in QUOTE
  @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT  })
  recordTypeQuote({ error, data }) {
    if(data) {
      this.valueFinalidadeOp.fieldReadOnly     = !data?.fields?.Description.updateable;
      this.valueDespesasRegistro.fieldReadOnly = !data?.fields?.ParameterAdditionalCosts__c.updateable;
      this.valueTAC.fieldReadOnly              = !data?.fields?.ParameterTac__c.updateable;
      this.valueIOF.fieldReadOnly              = !data?.fields?.ParameterIOF__c.updateable;
      this.valueCETmes.fieldReadOnly           = !data?.fields?.MonthlyCet__c.updateable;
      this.valueCETano.fieldReadOnly           = !data?.fields?.YearlyCet__c.updateable;
      this.valueJurosMes.fieldReadOnly         = !data?.fields?.MonthlyInterest__c.updateable;
      this.valueJurosAno.fieldReadOnly         = !data?.fields?.YearlyInterest__c.updateable;
      this.valuePrimeiraParcela.fieldReadOnly  = !data?.fields?.ServiceDate__c.updateable;
      this.valueUltimaParcela.fieldReadOnly    = !data?.fields?.ServiceLastDate__c.updateable;
      this.valueCreditoLiquido.fieldReadOnly   = !data?.fields?.NetValue__c.updateable;
      this.valueParcela.fieldReadOnly          = !data?.fields?.UnitPrice__c.updateable;
      this.valueQtdParcelas.fieldReadOnly      = !data?.fields?.Quantity__c.updateable;
    }
    else if(error){
      this.showError(error);
    }
  }  

  // Get fields permission in ACCOUNT
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT  })
  recordTypeAccount({ error, data }) {
    if(data) {
      this.valueNomeBeneficiario.fieldReadOnly  = !data?.fields?.Name.updateable;
      this.valueCNPJBeneficiario.fieldReadOnly  = !data?.fields?.CompanyCNPJ__c.updateable;
      this.valueBanco.fieldReadOnly             = !data?.fields?.BankName__c.updateable;
      this.valueAgencia.fieldReadOnly           = !data?.fields?.Agency__c.updateable;
      this.valueContaCorrente.fieldReadOnly     = !data?.fields?.BankAccountNumber__c.updateable;
      this.valuePatrimonio.fieldReadOnly        = !data?.fields?.NetWorthLowerLimit__c.updateable; //Validar
    }
    else if(error){
      this.showError(error);
    }
  }
  
  // Get fields permission in FINANCIAL RESOURCES
  @wire(getObjectInfo, { objectApiName: FINANCIALRESOURCES_OBJECT  })
  recordTypeFinancial({ error, data }) {
    if(data) {
      this.valueValorCarro.fieldReadOnly   = !data?.fields?.Amount__c.updateable;
      this.valueAnoCarro.fieldReadOnly     = !data?.fields?.ManufacturingYear__c.updateable;
    }
    else if(error){
      this.showError(error);
    }
  }

  @wire(getRecordOperationSection, {opportunityId: '$opportunityid'})
  recordOperationSection(result) {
    this.refreshRecordOperation = result;
    if(result.data) {
        // this.recordOperation.set('Quote'    , {...Object.values(this.fieldsQuote.map((item) => item.fieldApiName))      , ...result.data.Quote });
        this.recordOperation.set('Quote'    , {...this.getSObject(this.fieldsQuote)      , ...result.data.Quote });
        this.recordOperation.set('Financial', {...this.getSObject(this.fieldsFinancial)  , ...result.data.Financial});
        this.recordOperation.set('Proponent', {...this.getSObject(this.fieldsProponent)  , ...result.data.Proponent});

        let validationSection    = result.data.OperationSection;
        let quoteInfo            = result.data.Quote;
        let FinancialInfo        = result.data.Financial;
        let proponentInfo        = result.data.Proponent;

        this.setOperationValidationSection(validationSection);
        this.setQuoteInfo(quoteInfo);
        this.setFinancialInfo(FinancialInfo);
        this.setProponentInfo(proponentInfo);
    }else if(result.error){
      this.showError(error);
    }
  }

  getSObject(object){
    let SObject = {}; 
    Object.values(object).forEach(key => {SObject[key.fieldApiName] = ''});
    return SObject;
  }

  setFinancialInfo(FinancialInfo){
    this.valueValorCarro.value  = FinancialInfo.Amount__c ? FinancialInfo.Amount__c : null;
    this.valueAnoCarro.value    = FinancialInfo.ManufacturingYear__c ? FinancialInfo.ManufacturingYear__c : null;
 }

  setQuoteInfo(quoteInfo){
    this.valueFinalidadeOp.value      = quoteInfo.Description                 ? quoteInfo.Description                 : null;
    this.valueDespesasRegistro.value  = quoteInfo.ParameterAdditionalCosts__c ? quoteInfo.ParameterAdditionalCosts__c : null;
    this.valueTAC.value               = quoteInfo.ParameterTac__c             ? quoteInfo.ParameterTac__c             : null;
    this.valueIOF.value               = quoteInfo.ParameterIOF__c             ? quoteInfo.ParameterIOF__c             : null;
    this.valueCETmes.value            = quoteInfo.MonthlyCet__c               ? quoteInfo.MonthlyCet__c               : null;
    this.valueCETano.value            = quoteInfo.YearlyCet__c                ? quoteInfo.YearlyCet__c                : null;
    this.valueJurosMes.value          = quoteInfo.MonthlyInterest__c          ? quoteInfo.MonthlyInterest__c          : null;
    this.valueJurosAno.value          = quoteInfo.YearlyInterest__c           ? quoteInfo.YearlyInterest__c           : null;
    this.valuePrimeiraParcela.value   = quoteInfo.ServiceDate__c              ? quoteInfo.ServiceDate__c              : null;
    this.valueUltimaParcela.value     = quoteInfo.ServiceLastDate__c          ? quoteInfo.ServiceLastDate__c          : null;
    this.valueCreditoLiquido.value    = quoteInfo.NetValue__c                 ? quoteInfo.NetValue__c                 : null;
    this.valueParcela.value           = quoteInfo.UnitPrice__c                ? quoteInfo.UnitPrice__c                : null;
    this.valueQtdParcelas.value       = quoteInfo.Quantity__c                 ? quoteInfo.Quantity__c                 : null;
  }

  setProponentInfo(proponentInfo){
    this.valueNomeBeneficiario.value  = proponentInfo.Name                  ? proponentInfo.Name                  : null;
    this.valueCNPJBeneficiario.value  = proponentInfo.CompanyCNPJ__c        ? proponentInfo.CompanyCNPJ__c        : null;
    this.valueBanco.value             = proponentInfo.BankName__c           ? proponentInfo.BankName__c           : null;
    this.valueAgencia.value           = proponentInfo.Agency__c             ? proponentInfo.Agency__c             : null;
    this.valueContaCorrente.value     = proponentInfo.BankAccountNumber__c  ? proponentInfo.BankAccountNumber__c  : null;
    this.valuePatrimonio.value        = proponentInfo.NetWorthLowerLimit__c ? proponentInfo.NetWorthLowerLimit__c : null;
  }

  setOperationValidationSection(validationSection){
    let resultValidationSection = {...this.objValidationSection, ...validationSection};
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

  handleSaveSection() {
    this.disabledSaveButton = true;
    this.objValidationSection.Opportunity__c = this.opportunityid;

    upsertOperationDetailsSection({records: {
      "OperationSection": this.objValidationSection,
      "Quote": this.recordOperation.get('Quote'),
      "Financial": this.recordOperation.get('Financial'),
      "Proponent": this.recordOperation.get('Proponent')
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

  handleChangeCheckbox(event) {
    const currentCheckbox = event.target;
    const currentRowCheckboxes = this.template.querySelectorAll(
      `input[name=${currentCheckbox.name}]`
    );

    this.checkOnlyOne(currentCheckbox, currentRowCheckboxes);

    const info = this.getInfo();
    const modal = this.getModal(currentCheckbox);

    this.sendInfo({ ...info, modal });
    this.saveTransactionValue(event);
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
      modal['objectReason'] = OPERATION_OBJECT.objectApiName;
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

  saveTransactionValue(event) {
    let nameStatus = event.target.getAttribute('data-status');
    let valueStatus = event.target.checked ? event.target.value : null;
    let fieldsValidationAPI = this.fieldsValidationQuantity.map((item) => item.fieldApiName);
    fieldsValidationAPI.indexOf(nameStatus) > -1 ? this.resetFieldsValidation(fieldsValidationAPI):'';
       
    this.objValidationSection[nameStatus] = valueStatus;
  }

  resetFieldsValidation(fieldsValidationAPI){
    fieldsValidationAPI.map((item) => this.objValidationSection[item] = null);
  }

  get controllerSave(){
    return (this.disabledSaveButton || (this.completionPercentage === 100 ? false : true));
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

  showError(error) {
    this.error = error;
    this.showToast('Erro', error.body.message, 'error');
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
    this.sendInfo(this.getInfo());
  }

  setMapReason(selectedReason){

    let description = selectedReason.description ? selectedReason.description : '';
    let objValidationSection = this.objValidationSection;

    if(['QuantityRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason;
      objValidationSection.QuantityObservation__c = description;
    }
  }

  handleInputChange(event){
    const fieldType = event.target.type;
    const value = (fieldType === 'number') ? parseFloat(event.target.value) : event.target.value;
    const elementId = event.target.getAttribute('data-id');
    const fieldDefinition = this.inputOperation.get(elementId);
    const fieldApiName = fieldDefinition.fieldApiName;
    let records = this.recordOperation;
    for (let [key, item] of  records.entries()) {
      if(item.hasOwnProperty(fieldApiName)){
        this.recordOperation.set(
          key,
          {...this.recordOperation.get(key), [fieldApiName]: value},
        );
      }
    }
  }
}