import { LightningElement, wire, api, track } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
import getRecordOperationSection from '@salesforce/apex/ProposalOperationController.getOperationDetails';
import upsertOperationDetailsSection from '@salesforce/apex/ProposalOperationController.saveOperationDetails';

import OPERATION_OBJECT from '@salesforce/schema/OperationSection__c';

import QUANTITYSTATUS from '@salesforce/schema/OperationSection__c.QuantityStatus__c';
import QUANTITYREJECTION from '@salesforce/schema/OperationSection__c.QuantityRejectReason__c';
import QUANTITYDESC from '@salesforce/schema/OperationSection__c.QuantityObservation__c';

const FIELDSVALIDATIONQUANTITY = [QUANTITYSTATUS, QUANTITYREJECTION, QUANTITYDESC];
const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT = 'error';

const SUCCESS_OCCURRED = 'Sucesso';
const SUCCESS_MESSAGE = 'Seção de Operação atualizada com sucesso!';
const SUCCESS_VARIANT = 'success';
export default class ProposalOperationComponent extends LightningElement {

  @api accountid;
  @api opportunityid;


  fieldsValidationQuantity = FIELDSVALIDATIONQUANTITY;
  fieldsStatus = ['BranchStatus__c', 'AccountStatus__c', 'ServiceDateStatus__c', 'ServiceLastDateStatus__c', 'OperationPurposeStatus__c', 'UnitPriceStatus__c', 'YearlyInterestStatus__c', 'MonthlyInterestStatus__c', 'AdditionalCostsStatus__c', 'ManufacturingYearStatus__c', 'BankStatus__c', 'YearlyCETstatus__c', 'MonthlyCETstatus__c', 'BeneficiarysCNPJstatus__c', 'ParameterIOFstatus__c', 'BeneficiarysNameStatus__c', 'ContractNumberStatus__c', 'ParameterTACstatus__c', 'CarValueStatus__c', 'NetValueStatus__c', 'PatrimonyStatus__c', 'QuantityStatus__c'];
  error;
  
  // Controller Section
  topContainerSection = 'ContainerOperation';
  statusApprove = 'Aprovar';
  statusReject = 'Rejeitar';
  statusPending = 'Pendenciar';
  statusReturnedPendency = 'Voltou de pendência';
  completionPercentage = 0;
  totalLinesValidation = 22;
  disabledSaveButton = false;
  saveRecord = true;

  // Operation Data Info
  recordOperationSection = {};
  
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
  @track valueNumeroContrato   = {value: '', fieldReadOnly: true};
  
  // Values
  preValue = [];

  // Refresh apex 
  refreshRecordOperation;

  // Get fields permission in OPERATIONSECTION
  @wire(getObjectInfo, { objectApiName: OPERATION_OBJECT  })
  getOperationPermission({ error, data }) {
    if(data) {
      this.valueFinalidadeOp.fieldReadOnly     = !data?.fields?.Description__c.updateable;
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
      this.valuePatrimonio.fieldReadOnly       = !data?.fields?.CollateralAmount__c.updateable;
      this.valueBanco.fieldReadOnly            = !data?.fields?.BankName__c.updateable;
      this.valueAgencia.fieldReadOnly          = !data?.fields?.Agency__c.updateable;
      this.valueContaCorrente.fieldReadOnly    = !data?.fields?.BankAccountNumber__c.updateable;
      this.valueValorCarro.fieldReadOnly       = !data?.fields?.Amount__c.updateable;
      this.valueAnoCarro.fieldReadOnly         = !data?.fields?.ManufacturingYear__c.updateable;
      this.valueNomeBeneficiario.fieldReadOnly = !data?.fields?.PartnerAccount__c.updateable;
      this.valueCNPJBeneficiario.fieldReadOnly = !data?.fields?.DocumentNumber__c.updateable;

      this.error = undefined;
    }
    else if(error){
      this.showError(error);
    }
  }

  @wire(getRecordOperationSection, {opportunityId: '$opportunityid'})
  recordOperationSection(result) {
    this.refreshRecordOperation = result;
    if(result.data) {
        this.recordOperationSection = {...result.data};
        this.setOperationSection();
        this.setOperationValidationSection();
        this.error = undefined;
    }else if(result.error){
      this.showError(result.error);
      console.log(result.error);
    }
  }

  getSObject(object){
    let sObject = {}; 
    Object.values(object).forEach(key => {sObject[key.fieldApiName] = ''});
    return sObject;
  }
  
  setOperationSection(){
    let operationRecord =  this.recordOperationSection;
    this.valueValorCarro.value        = operationRecord.Amount__c                   ? operationRecord.Amount__c                   : null;
    this.valueAnoCarro.value          = operationRecord.ManufacturingYear__c        ? operationRecord.ManufacturingYear__c        : null;
    this.valueFinalidadeOp.value      = operationRecord.Description                 ? operationRecord.Description                 : null;
    this.valueDespesasRegistro.value  = operationRecord.ParameterAdditionalCosts__c ? operationRecord.ParameterAdditionalCosts__c : null;
    this.valueTAC.value               = operationRecord.ParameterTac__c             ? operationRecord.ParameterTac__c             : null;
    this.valueIOF.value               = operationRecord.ParameterIOF__c             ? operationRecord.ParameterIOF__c             : null;
    this.valueCETmes.value            = operationRecord.MonthlyCet__c               ? operationRecord.MonthlyCet__c               : null;
    this.valueCETano.value            = operationRecord.YearlyCet__c                ? operationRecord.YearlyCet__c                : null;
    this.valueJurosMes.value          = operationRecord.MonthlyInterest__c          ? operationRecord.MonthlyInterest__c          : null;
    this.valueJurosAno.value          = operationRecord.YearlyInterest__c           ? operationRecord.YearlyInterest__c           : null;
    this.valuePrimeiraParcela.value   = operationRecord.ServiceDate__c              ? operationRecord.ServiceDate__c              : null;
    this.valueUltimaParcela.value     = operationRecord.ServiceLastDate__c          ? operationRecord.ServiceLastDate__c          : null;
    this.valueCreditoLiquido.value    = operationRecord.NetValue__c                 ? operationRecord.NetValue__c                 : null;
    this.valueParcela.value           = operationRecord.UnitPrice__c                ? operationRecord.UnitPrice__c                : null;
    this.valueQtdParcelas.value       = operationRecord.Quantity__c                 ? operationRecord.Quantity__c                 : null;
    this.valuePatrimonio.value        = operationRecord.CollateralAmount__c         ? operationRecord.CollateralAmount__c         : null;
    this.valueBanco.value             = operationRecord.BankName__c                 ? operationRecord.BankName__c                 : null;
    this.valueAgencia.value           = operationRecord.Agency__c                   ? operationRecord.Agency__c                   : null;
    this.valueContaCorrente.value     = operationRecord.BankAccountNumber__c        ? operationRecord.BankAccountNumber__c        : null;
    this.valueFinalidadeOp.value      = operationRecord.Description__c              ? operationRecord.Description__c              : null;
    
    // Nome Beneficiário + CNPJ Beneficiário + Numero do Contrato
    this.valueNomeBeneficiario.value  = operationRecord.PartnerAccount__c           ? operationRecord.PartnerAccount__c           : null;
    this.valueCNPJBeneficiario.value  = operationRecord.DocumentNumber__c           ? operationRecord.DocumentNumber__c           : null;
    // this.valueFinalidadeOp.value      = operationRecord.Description__c              ? operationRecord.Description__c              : null;
  }

  setOperationValidationSection(){
    let resultValidationSection = this.recordOperationSection;
    let listStatus = this.fieldsStatus;
    let returnedPendency = this.statusReturnedPendency;
    for(let index in listStatus){
        let status = listStatus[index];
        this.template.querySelectorAll("[data-status='"+status+"']").forEach(function(item) {
        item.classList.contains('show_icon_pendency') ? item.classList.remove('show_icon_pendency'):'';
        
        let dataValue = item.hasAttribute("data-value") ? item.getAttribute("data-value") : null;
        if(dataValue === returnedPendency && dataValue === resultValidationSection[status]){
          item.classList.add('show_icon_pendency');
        }
        else if (item.value === resultValidationSection[status]) {
            item.checked = true;
            item.setAttribute('data-value', item.value);
        }
        });
    }
    this.sendInfo(this.getInfo());
  }

  handleSaveSection() {
    this.disabledSaveButton = true;

    upsertOperationDetailsSection({record:  this.recordOperationSection})
    .then( result=>{
      refreshApex(this.refreshRecordOperation);
      this.showToast(SUCCESS_OCCURRED, SUCCESS_MESSAGE, SUCCESS_VARIANT);
      this.saveRecord = true;
      this.sendInfo(this.getInfo());
      this.error = undefined;
    })
    .catch(error =>{
      console.log({error});
      this.showToast(ERROR_OCCURRED,ERROR_MESSAGE, ERROR_VARIANT);
      this.error = error;
    })
    .finally( ()=>{
      this.disabledSaveButton = false;
    })
  }

  handleChangeCheckbox(event) {
    // this.sendSaveSection(false);
    this.saveRecord = false;
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
    const currentPercent = (selected / total) * 100;
    this.completionPercentage = (currentPercent == 100 && !this.saveRecord) ? 99 : currentPercent;
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
       
    this.recordOperationSection[nameStatus] = valueStatus;
  }

  resetFieldsValidation(fieldsValidationAPI){
    fieldsValidationAPI.map((item) => this.recordOperationSection[item] = null);
  }

  get controllerSave(){
    return (this.disabledSaveButton || (this.completionPercentage < 99) || this.saveRecord) ? true : false;
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
    let recordOperationSection = this.recordOperationSection;

    if(['QuantityRejectReason__c'].includes(selectedReason.field)){
      recordOperationSection[selectedReason.field] = selectedReason.reason;
      recordOperationSection.QuantityObservation__c = description;
    }
  }

  handleInputChange(event){
    let field = event.target.dataset.id;
    const fieldType = event.target.type;
    // this.sendSaveSection(false);
    this.saveRecord = false;
    const value = (fieldType === 'number') ? parseFloat(event.target.value) : event.target.value;
    this.recordOperationSection = { ...this.recordOperationSection, [field]: value };
    this.sendInfo(this.getInfo());
  }
}