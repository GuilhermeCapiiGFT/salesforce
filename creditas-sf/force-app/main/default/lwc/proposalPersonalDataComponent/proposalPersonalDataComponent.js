import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo  } from 'lightning/uiObjectInfoApi';

import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import MOTHER_FIELD from '@salesforce/schema/Account.Mother__c';
import FATHER_FIELD from '@salesforce/schema/Account.Father__c';
import BIRTHCITY_FIELD from '@salesforce/schema/Account.BirthCity__c';
import BIRTHCOUNTRY_FIELD from '@salesforce/schema/Account.Birth_Country__c';
import DOCUMENT_NUMBER_FIELD from '@salesforce/schema/Account.DocumentNumber__c';
import CIVIL_STATUS_FIELD from '@salesforce/schema/Account.CivilStatus__c';
import PEP_FIELD from '@salesforce/schema/Account.PoliticallyExposed__c';
import BIRTHDATE_FIELD from '@salesforce/schema/Account.BirthDate__c';
import NATIONALITY_FIELD from '@salesforce/schema/Account.Nationality__c';

import DOCUMENT_OBJECT from '@salesforce/schema/Documents__c';
import DOCUMENT_RECORDTYPEID_FIELD from '@salesforce/schema/Documents__c.RecordTypeId';
import DOCUMENT_ACCOUNT_FIELD from '@salesforce/schema/Documents__c.Account__c';
import RG_DOCUMENT_FIELD from '@salesforce/schema/Documents__c.Id';
import RG_NUMBER_FIELD from '@salesforce/schema/Documents__c.DocumentNumber__c';
import RG_ISSUER_FIELD from '@salesforce/schema/Documents__c.Issuer__c';
import RG_ISSUER_STATE_FIELD from '@salesforce/schema/Documents__c.IssuerState__c';
import RG_ISSUE_DATE_FIELD from '@salesforce/schema/Documents__c.IssueDate__c';
import RG_DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.DocumentType__c';

import CNH_DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.DocumentType__c';
import CNH_DOCUMENT_FIELD from '@salesforce/schema/Documents__c.Id';
import CNH_NUMBER_FIELD from '@salesforce/schema/Documents__c.DocumentNumber__c';
import CNH_ISSUER_FIELD from '@salesforce/schema/Documents__c.Issuer__c';
import CNH_ISSUE_DATE_FIELD from '@salesforce/schema/Documents__c.IssueDate__c';

import PERSONAL_DATA_OBJECT from '@salesforce/schema/PersonalDataSection__c';
import PERSONAL_DATA_ID_FIELD from '@salesforce/schema/PersonalDataSection__c.Id';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/PersonalDataSection__c.Opportunity__c';

import CPFSTATUS from '@salesforce/schema/PersonalDataSection__c.CPFStatus__c';
import CPFPENDING from '@salesforce/schema/PersonalDataSection__c.CPFPendingReason__c';
import CPFREJECT from '@salesforce/schema/PersonalDataSection__c.CPFRejectReason__c';
import CPFOBSERVATION from '@salesforce/schema/PersonalDataSection__c.CPFObservation__c';

import PEPSTATUS from '@salesforce/schema/PersonalDataSection__c.PoliticallyExposedPersonStatus__c';
import PEPREJECT from '@salesforce/schema/PersonalDataSection__c.PersonExposedRejectReason__c';
import PEPOBSERVATION from '@salesforce/schema/PersonalDataSection__c.PoliticallyExposedPersonObservation__c';

import RGSTATUS from '@salesforce/schema/PersonalDataSection__c.RGStatus__c';
import RGPENDING from '@salesforce/schema/PersonalDataSection__c.RGPendingReason__c';
import RGREJECT from '@salesforce/schema/PersonalDataSection__c.RGRejectReason__c';
import RGOBSERVATION from '@salesforce/schema/PersonalDataSection__c.RGobservation__c';

import DISPATCHDATESTATUS from '@salesforce/schema/PersonalDataSection__c.DispatchDateStatus__c';
import DISPATCHDATEPENDING from '@salesforce/schema/PersonalDataSection__c.DateDispatchPendingReason__c';
import DISPATCHDATEOBSERVATION from '@salesforce/schema/PersonalDataSection__c.DispatchDateObservation__c';

import CNHSTATUS from '@salesforce/schema/PersonalDataSection__c.CNHnumberStatus__c';
import CNHPENDING from '@salesforce/schema/PersonalDataSection__c.CNHnumberPendingReason__c';
import CNHOBSERVATION from '@salesforce/schema/PersonalDataSection__c.CNHnumberObservation__c';

import DISPATCHDATESTATUSCNH from '@salesforce/schema/PersonalDataSection__c.CNHdispatchDateStatus__c';
import DISPATCHDATEPENDINGCNH from '@salesforce/schema/PersonalDataSection__c.CNHdispatchDateObservation__c';
import DISPATCHDATEOBSERVATIONCNH from '@salesforce/schema/PersonalDataSection__c.CNHdispatchDatePendingReason__c';

import DISPATCHISSUERSTATUSCNH from '@salesforce/schema/PersonalDataSection__c.CNHissuingAgencyStatus__c';
import DISPATCHISSUERPENDINGCNH from '@salesforce/schema/PersonalDataSection__c.CNHissuingAgencyPendingReason__c';
import DISPATCHISSUEROBSERVATIONCNH from '@salesforce/schema/PersonalDataSection__c.CNHissuingAgencyObservation__c';

import getRecordId from '@salesforce/apex/ProposalPersonalDataController.getInfoRecords';
import getDocuments from '@salesforce/apex/ProposalPersonalDataController.getDocuments';

const ACCOUNT_FIELDS = [NAME_FIELD, MOTHER_FIELD, DOCUMENT_NUMBER_FIELD, CIVIL_STATUS_FIELD, PEP_FIELD, BIRTHDATE_FIELD, FATHER_FIELD, BIRTHCITY_FIELD, BIRTHCOUNTRY_FIELD, NATIONALITY_FIELD]
const RG_DOCUMENTS_FIELDS = [RG_NUMBER_FIELD, RG_ISSUER_FIELD, RG_ISSUER_STATE_FIELD, RG_ISSUE_DATE_FIELD]

const FIELDSVALIDATIONCPF = [CPFSTATUS, CPFPENDING, CPFREJECT, CPFOBSERVATION]
const FIELDSVALIDATIONPEP = [PEPSTATUS, PEPREJECT, PEPOBSERVATION]
const FIELDSVALIDATIONRG = [RGSTATUS, RGPENDING, RGREJECT, RGOBSERVATION]
const FIELDSVALIDATIONDISPATCHDATERG = [DISPATCHDATESTATUS, DISPATCHDATEPENDING, DISPATCHDATEOBSERVATION]
const FIELDSVALIDATIONCNH = [CNHSTATUS, CNHPENDING, CNHOBSERVATION]
const FIELDSVALIDATIONDISPATCHDATECNH = [DISPATCHDATESTATUSCNH, DISPATCHDATEPENDINGCNH, DISPATCHDATEOBSERVATIONCNH]
const FIELDSVALIDATIONISSUERCNH = [DISPATCHISSUERSTATUSCNH, DISPATCHISSUERPENDINGCNH, DISPATCHISSUEROBSERVATIONCNH]


export default class ProposalPersonalDataComponent extends LightningElement {

  // Account Info
  @api accountid
  @api opportunityid
  account
  error
  recordTypeId
  disabledBtnSave = true
  
  // Account Info Fields
  name = ''
  father = ''
  mother = ''
  birthdate = ''
  documentNumber = ''
  birthCity = ''
  birthCountry = ''
  nationality = ''
  politicallyExposed = ''
  civilStatus = ''
  idade = ''

  // Documents Info Fields
  rgRecordTypeId = ''
  cnhRecordTypeId = ''
  rgDocumentId = ''
  rgDocumentNumber = ''
  rgIssuer = ''
  rgIssueDate = ''
  rgIssuerState = ''
  cnhDocumentId = ''
  cnhDocumentNumber = ''
  cnhIssuer = ''
  cnhIssueDate = ''

  fields = {}

  fieldsValidationCPF = FIELDSVALIDATIONCPF
  fieldsValidationPEP = FIELDSVALIDATIONPEP
  fieldsValidationRG = FIELDSVALIDATIONRG
  fieldsValidationDispatchDateRG = FIELDSVALIDATIONDISPATCHDATERG
  fieldsValidationCNH = FIELDSVALIDATIONCNH
  fieldsValidationDispatchDateCNH = FIELDSVALIDATIONDISPATCHDATECNH
  fieldsValidationIssuerCNH = FIELDSVALIDATIONISSUERCNH

  // Personal Data Info
  recordPersonalSectionId = ''
  personalData
 
  // Picklist options
  civilStatusOptions = []
  politicallyExposedOptions = [{ label: 'Sim', value: 'SIM' }, { label: 'Não', value: 'NÃO' }]
  
  // Checkboxes Values
  value = [];
  preValue = [];

  // Map for personal data
  mapSection = 
    {
      'NameStatus__c': '',
      'MothersNameStatus__c': '',
      'FathersNameStatus__c': '',
      'CPFStatus__c' : '',
      'CPFPendingReason__c' : '',
      'CPFRejectReason__c' : '',
      'CPFObservation__c': '',
      'BirthCityStatus__c': '',
      'BirthCountryStatus__c': '',
      'BirthDateStatus__c': '',
      'NationalityStatus__c': '',
      'PoliticallyExposedPersonStatus__c': '',
      'PersonExposedRejectReason__c': '',
      'PoliticallyExposedPersonObservation__c': '',
      'RGStatus__c': '',
      'RGPendingReason__c': '',
      'RGobservation__c': '',
      'RGRejectReason__c': '',
      'IssuingAgencyStatus__c': '',
      'DispatchDateStatus__c': '',
      'DispatchDateObservation__c': '',
      'DateDispatchPendingReason__c': '',
      'UFIssuingAgencyStatus__c': '', 
      'CNHnumberStatus__c': '',
      'CNHnumberPendingReason__c': '',
      'CNHnumberObservation__c': '',
      'CNHdispatchDateStatus__c': '', 
      'CNHdispatchDateObservation__c': '', 
      'CNHdispatchDatePendingReason__c': '', 
      'CNHissuingAgencyStatus__c': '',
      'CNHissuingAgencyObservation__c': '',
      'CNHissuingAgencyPendingReason__c': ''
    }

  @wire(getRecord, { recordId: '$accountid', fields: ACCOUNT_FIELDS })
  getAccountInfo({ error, data }) {
    if (data) {
      this.account = data
      this.error = undefined
      console.log(this.account)

      let fields = this.account.fields
      this.name = fields.Name.value
      this.mother = fields.Mother__c.value
      this.father = fields.Father__c.value
      this.documentNumber = fields.DocumentNumber__c.value
      this.birthCity = fields.BirthCity__c.value
      this.birthCountry = fields.Birth_Country__c.value
      this.nationality = fields.Nationality__c.value
      this.civilStatus = fields.CivilStatus__c.value
      this.politicallyExposed = fields.PoliticallyExposed__c.value ? 'SIM' : 'NÃO'
      this.birthdate = fields.BirthDate__c.value
      this.idade = this.getAge(fields.BirthDate__c.value)

    } else if (error) this.showError(error)
  }

  @wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT })
  getDocumentRecordIds({ error, data }) {
    if (data) {
      const rtis = Object.entries(data.recordTypeInfos)
      rtis.forEach(key => {
        if (key[1].name === 'RG') this.rgRecordTypeId = key[1].recordTypeId
        if (key[1].name === 'CNH') this.cnhRecordTypeId = key[1].recordTypeId
      })
    } else if (error)this.showError(error)
  }

  @wire(getDocuments, { recordId: '$accountid' })
  getDocumentsInfo({ error, data }) {
    if (data) {
      
      if (data.RG && Object.keys(data.RG).length !== 0) {
        let rgDoc = data.RG
        this.rgDocumentId     = rgDoc.Id ? rgDoc.Id : ''
        this.rgDocumentNumber = rgDoc.DocumentNumber__c ? rgDoc.DocumentNumber__c : ''
        this.rgIssuer         = rgDoc.Issuer__c ? rgDoc.Issuer__c : '' 
        this.rgIssueDate      = rgDoc.IssueDate__c ? rgDoc.IssueDate__c : ''
        this.rgIssuerState    = rgDoc.IssuerState__c ? rgDoc.IssuerState__c : ''
      }
      
      if (data.CNH && Object.keys(data.CNH).length !== 0) {
        let cnhDoc             = data.CNH
        this.cnhDocumentId     = cnhDoc.Id ? cnhDoc.Id : ''
        this.cnhDocumentNumber = cnhDoc.DocumentNumber__c ? cnhDoc.DocumentNumber__c : ''
        this.cnhIssuer         = cnhDoc.Issuer__c ? cnhDoc.Issuer__c : '' 
        this.cnhIssueDate      = cnhDoc.IssueDate__c ? cnhDoc.IssueDate__c : ''
      }
    } else if (error) this.showError(error)
  }

  @wire(getRecordId, {recordId: '$opportunityid'})
  getDataSectionId({ error, data }) {
    if (data) {
      this.error = undefined

      this.recordPersonalSectionId = Object.keys(data).length === 0 ? '' : data.dadosPessoais.Id
    
      if (this.recordPersonalSectionId !== '') {
        
        this.personalData = data.dadosPessoais
        let { Id, Name, Opportunity__c, ...filteredData } = this.personalData

        for (let item in filteredData) {
          this.mapSection[item] = filteredData[item]         
        }

        for (let indexField in filteredData) {
          this.template.querySelectorAll("[data-status='"+indexField+"']").forEach(function(item) {
            if (item.value === filteredData[indexField]) {
              item.checked = true
              item.setAttribute('data-value', item.value)
            }
          })
        }
        let info = this.getPercentage()
        this.sendInfo(info)
      } 
    } else if (error) this.showError(error)
  }

  @wire(getPicklistValues, { recordTypeId: '$account.recordTypeId', fieldApiName: CIVIL_STATUS_FIELD })
  getCivilStatusPicklist({ error, data }) {
    if (data) {
      this.civilStatusOptions = data.values
    } else if (error) this.showError(error)
  }

  handleInputChange(event) {
    let dataid = event.target.dataset.id
    let value = event.target.value

    if (dataid === 'Name')                       this.name = value
    else if (dataid === 'Father__c')             this.father = value
    else if (dataid === 'Mother__c')             this.mother = value
    else if (dataid === 'DocumentNumber__c')     this.documentNumber = value
    else if (dataid === 'BirthDate__c')          this.birthdate = value
    else if (dataid === 'BirthCity__c')          this.birthCity = value
    else if (dataid === 'Birth_Country__c')      this.birthCountry = value
    else if (dataid === 'Nationality__c')        this.nationality = value
    else if (dataid === 'PoliticallyExposed__c') this.politicallyExposed = value
    else if (dataid === 'RG_DocumentNumber__c')  this.rgDocumentNumber = value
    else if (dataid === 'RG_Issuer__c')          this.rgIssuer = value
    else if (dataid === 'RG_IssueDate__c')       this.rgIssueDate = value
    else if (dataid === 'RG_IssuerState__c')     this.rgIssuerState = value
    else if (dataid === 'CNH_DocumentNumber__c') this.cnhDocumentNumber = value
    else if (dataid === 'CNH_IssueDate__c')      this.cnhIssueDate = value
    else if (dataid === 'CNH_Issuer__c')         this.cnhIssuer = value
    
  }

  handleSaveSection() {
    this.disabledBtnSave = true

    const fields = {}
    fields[ACCOUNTID_FIELD.fieldApiName]       = this.accountid
    fields[NAME_FIELD.fieldApiName]            = this.name 
    fields[FATHER_FIELD.fieldApiName]          = this.father
    fields[MOTHER_FIELD.fieldApiName]          = this.mother
    fields[BIRTHDATE_FIELD.fieldApiName]       = this.birthdate
    fields[DOCUMENT_NUMBER_FIELD.fieldApiName] = this.documentNumber
    fields[BIRTHCITY_FIELD.fieldApiName]       = this.birthCity
    fields[BIRTHCOUNTRY_FIELD.fieldApiName]    = this.birthCountry
    fields[NATIONALITY_FIELD.fieldApiName]     = this.nationality
    fields[PEP_FIELD.fieldApiName]             = (this.politicallyExposed === 'SIM') ? true : false

    const recordInput = { fields }

    updateRecord(recordInput)
      .then(() => {
        this.saveDocumentRG()
      })
      .catch(error => {
        this.disabledBtnSave = false
        this.showError(error)
      });
  }

  saveDocumentRG() {
    const fields = {}
    fields[RG_NUMBER_FIELD.fieldApiName]       = this.rgDocumentNumber
    fields[RG_ISSUER_FIELD.fieldApiName]       = this.rgIssuer
    fields[RG_ISSUER_STATE_FIELD.fieldApiName] = this.rgIssuerState
    fields[RG_ISSUE_DATE_FIELD.fieldApiName]   = this.rgIssueDate

    if (this.rgDocumentId === '')
    {
      fields[DOCUMENT_ACCOUNT_FIELD.fieldApiName]       = this.accountid
      fields[RG_DOCUMENT_TYPE_FIELD.fieldApiName]       = 'RG'
      fields[DOCUMENT_RECORDTYPEID_FIELD.fieldApiName]  = this.rgRecordTypeId
      
      const recordInput = { apiName: DOCUMENT_OBJECT.objectApiName, fields }

      createRecord(recordInput)
        .then(() => {
        this.saveDocumentCNH()
      })
        .catch(error => {
          this.disabledBtnSave = false
          this.showError(error)
        });
    }

    else {
      fields[RG_DOCUMENT_FIELD.fieldApiName] = this.rgDocumentId
      const recordInput = { fields }

      updateRecord(recordInput)
        .then(() => {
          this.saveDocumentCNH()
        })
        .catch(error => {
          this.disabledBtnSave = false
          this.showError(error)
        });
    }
  }

  saveDocumentCNH() {
    const fields = {}

    fields[CNH_NUMBER_FIELD.fieldApiName]      = this.cnhDocumentNumber
    fields[CNH_ISSUER_FIELD.fieldApiName]      = this.cnhIssuer
    fields[CNH_ISSUE_DATE_FIELD.fieldApiName]  = this.cnhIssueDate
    
    if (this.cnhDocumentId === '')
    {
      fields[DOCUMENT_ACCOUNT_FIELD.fieldApiName]      = this.accountid
      fields[CNH_DOCUMENT_TYPE_FIELD.fieldApiName]     = 'CNH'
      fields[DOCUMENT_RECORDTYPEID_FIELD.fieldApiName] = this.cnhRecordTypeId
      const recordInput = { apiName: DOCUMENT_OBJECT.objectApiName, fields }

      createRecord(recordInput)
        .then(() => {
        this.saveCheckboxes()
      })
      .catch(error => {
        this.disabledBtnSave = false
        this.showError(error)
      });
    }

    else {
      fields[CNH_DOCUMENT_FIELD.fieldApiName]  = this.cnhDocumentId
      const recordInput = { fields }

      updateRecord(recordInput)
        .then(() => {
          this.saveCheckboxes()
        })
        .catch(error => {
          this.disabledBtnSave = false
          this.showError(error)
        });
    }
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
}