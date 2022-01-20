import { LightningElement, wire, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELD from '@salesforce/schema/Account.Name'
import BIRTHDAY_FIELD from '@salesforce/schema/Account.BirthDate__c';
import DOCUMENTO_FIELD from '@salesforce/schema/Account.DocumentNumber__c';
import POLITICALLY_EXPOSED_FIELD from '@salesforce/schema/Account.PoliticallyExposed__c';
import BIRTH_CITY_FIELD from '@salesforce/schema/Account.Birth_City__c';
import CIVIL_STATUS_FIELD from '@salesforce/schema/Account.CivilStatus__c';
import BIRTH_COUNTRY_FIELD from '@salesforce/schema/Account.Birth_Country__c';
import NACIONALITY_FIELD from '@salesforce/schema/Account.Nationality__c';
import FATHER_FIELD from '@salesforce/schema/Account.Father__c';
import MOTHER_FIELD from '@salesforce/schema/Account.Mother__c';

import CNH_NUMBER_FIELD from '@salesforce/schema/Documents__c.DocumentNumber__c';
import CNH_DATA_EXPEDICAO_FIELD from '@salesforce/schema/Documents__c.IssueDate__c';
import CNH_ORGAO_EXPEDIDOR_FIELD from '@salesforce/schema/Documents__c.Issuer__c';

import RG_NUMBER_FIELD from '@salesforce/schema/Documents__c.DocumentNumber__c';
import RG_DATA_EXPEDICAO_FIELD from '@salesforce/schema/Documents__c.IssueDate__c';
import RG_ORGAO_EXPEDIDOR_FIELD from '@salesforce/schema/Documents__c.Issuer__c';
import RG_UF_ORGAO_EXPEDIDOR_FIELD from '@salesforce/schema/Documents__c.IssuerState__c';

import JOB_TITLE_FIELD from '@salesforce/schema/ProfessionalInfo__c.JobTitle__c';
import STATUS_FIELD from '@salesforce/schema/ProfessionalInfo__c.Status__c';

import CELULAR_FIELD from '@salesforce/schema/CommunicationContacts__c.Code__c';
import EMAIL_FIELD from '@salesforce/schema/CommunicationContacts__c.Code__c';

import STREET_FIELD from '@salesforce/schema/Addresses__c.Street__c';
import ENDERECO_FIELD from '@salesforce/schema/Addresses__c.Endereco__c';
import STREET_NUMBER_FIELD from '@salesforce/schema/Addresses__c.StreetNumber__c';
import COMPLEMENT_FIELD from '@salesforce/schema/Addresses__c.Complement__c';
import POSTALCODE_FIELD from '@salesforce/schema/Addresses__c.PostalCode__c';
import NEIGHBORHOOD_FIELD from '@salesforce/schema/Addresses__c.Neighborhood__c';
import CITY_FIELD from '@salesforce/schema/Addresses__c.AreaLevel2__c';
import STATE_FIELD from '@salesforce/schema/Addresses__c.AreaLevel1__c';
import COUNTRY_FIELD from '@salesforce/schema/Addresses__c.Country__c';

import RENDA_INFORMADA_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';
import RENDA_CONSIDERADA_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';
import RENDA_CONFIRMADA_FIELD from '@salesforce/schema/FinancialResources__c.Amount__c';
import RENDA_MINIMA_FIELD from '@salesforce/schema/Opportunity.MinimalRequiredIncome__c';
import PATRIMONIO_MAX_FIELD from '@salesforce/schema/Account.NetWorthUpperLimit__c';
import PATRIMONIO_MIN_FIELD from '@salesforce/schema/Account.NetWorthLowerLimit__c';

import ACCOUNT_FIELD from '@salesforce/schema/AccountFinancialRelationship__c.Account__c';
import FINANCIAL_RESOURCE_FIELD from '@salesforce/schema/AccountFinancialRelationship__c.Recurso_Financeiro__c';

import ACC_FIN_REL_OBJECT from '@salesforce/schema/AccountFinancialRelationship__c';
import DOCUMENTS_OBJECT from '@salesforce/schema/Documents__c';
import getRecords from '@salesforce/apex/FichaFormalizacaoController.getRecords';
export default class FichaDadosPessoais extends LightningElement {

  // Dados Pessoais
  nameField = NAME_FIELD;
  birthDateField = BIRTHDAY_FIELD
  documentoField = DOCUMENTO_FIELD
  politicallyExposedField = POLITICALLY_EXPOSED_FIELD
  birthCityField = BIRTH_CITY_FIELD
  civilStatusField = CIVIL_STATUS_FIELD
  birthCountryField = BIRTH_COUNTRY_FIELD
  nationalityField = NACIONALITY_FIELD
  fatherField = FATHER_FIELD
  motherField = MOTHER_FIELD
 
  // Documentos CNH
  cnhNumberField = CNH_NUMBER_FIELD
  cnhDataExpedicaoField = CNH_DATA_EXPEDICAO_FIELD
  cnhOrgaoExpedidorField = CNH_ORGAO_EXPEDIDOR_FIELD

  // Documentos RG
  rgNumberField = RG_NUMBER_FIELD
  rgDataExpedicaoField = RG_DATA_EXPEDICAO_FIELD
  rgOrgaoExpedidorField = RG_ORGAO_EXPEDIDOR_FIELD
  rgUFOrgaoExpedidorField = RG_UF_ORGAO_EXPEDIDOR_FIELD

  // Professional Info
  jobTitleField = JOB_TITLE_FIELD
  statusField = STATUS_FIELD

  // Communication Contacts
  celularField = CELULAR_FIELD
  emailField = EMAIL_FIELD

  // Addresses
  streetField = STREET_FIELD
  enderecoField = ENDERECO_FIELD
  streetNumberField = STREET_NUMBER_FIELD
  complementField = COMPLEMENT_FIELD
  postalCodeField = POSTALCODE_FIELD
  neighborhoodField = NEIGHBORHOOD_FIELD
  cityField = CITY_FIELD
  stateField = STATE_FIELD
  countryField = COUNTRY_FIELD

  // Renda
  rendaInformadaField  = RENDA_INFORMADA_FIELD
  rendaConsideradaField = RENDA_CONSIDERADA_FIELD
  rendaConfirmadaField = RENDA_CONFIRMADA_FIELD
  rendaMinimaField = RENDA_MINIMA_FIELD
  patrimonioMaxField = PATRIMONIO_MAX_FIELD
  patrimonioMinField = PATRIMONIO_MIN_FIELD
 
  @api accountid
  @api opportunityid
  
  documentIdCNH
  documentIdRG
  professionalInfoId
  celularId
  emailId
  addressId
  monthlyIncomeId
  presumedMonthlyIncomeId
  confirmedMonthlyIncomeId

  @track documentsInfo

  @track objects = {
    documents: [],
    professionalInfo: [],
    communicationContacts: [],
    addresses: [],
    financialResources: []
  }

  openSections = ['dadosContato', 'dadosPessoais', 'dadosEndereco', 'dadosRenda']

  @wire(getRecords, { accountId: '$accountid' })
  getRecordsInfo({ error, data }) {
    if (data) {
      this.objects.documents = (data && data.documents) ? data.documents : null
      this.objects.professionalInfo = (data && data.professionalInfo) ? data.professionalInfo : null
      this.objects.communicationContacts = (data && data.communicationContacts) ? data.communicationContacts : null
      this.objects.addresses = (data && data.addresses) ? data.addresses : null
      this.objects.financialResources = (data && data.financialResources) ? data.financialResources : null

      if (this.objects.documents !== null) {
        this.objects.documents.map(doc => {
          
          if (doc.DocumentType__c === 'CNH') {
            this.documentIdCNH = doc.Id
          }
  
          else if (doc.DocumentType__c === 'RG') {
            this.documentIdRG = doc.Id
          }
        })
        
        console.log(this.objects)
        
      }

      if (Array.isArray(this.objects.professionalInfo) && this.objects.professionalInfo.length) {
        this.professionalInfoId = this.objects.professionalInfo[0].Id
      }

      if (Array.isArray(this.objects.communicationContacts) && this.objects.communicationContacts.length) {
        this.objects.communicationContacts.forEach(doc => {
          
          console.log(JSON.stringify(doc))

          if (doc.Channel__c === 'SMS') {
            this.celularId = doc.Id
          }

          else if (doc.Channel__c === 'EMAIL') {
            this.emailId = doc.Id
          }
        })
      }

      if (Array.isArray(this.objects.addresses) && this.objects.addresses.length) {
        this.addressId = this.objects.addresses[0].Id
      }

      if (Array.isArray(this.objects.financialResources) && this.objects.financialResources.length) {
        this.objects.financialResources.forEach(doc => {
            
          if (doc.Type__c === 'MONTHLY_INCOME') {
            this.monthlyIncomeId = doc.Id
          }

          else if (doc.Type__c === 'PRESUMED_MONTHLY_INCOME') {
            this.presumedMonthlyIncomeId = doc.Id
          }

          else if (doc.Type__c === 'CONFIRMED_MONTHLY_INCOME') {
            this.confirmedMonthlyIncomeId = doc.Id
          }
        })
      }

      console.log({ data })

    } else if (error) {
      let message = 'Unknown Error'
      if (Array.isArray(error.body)) {
        message = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error loading contact',
            message,
            variant: 'error',
        }),
      );
    }
  }

  @wire(getObjectInfo, { objectApiName: DOCUMENTS_OBJECT })
  documentsInfo

  getRecordTypeId(rtName) {
    const rtis = this.documentsInfo.data.recordTypeInfos
    return Object.keys(rtis).find(rti => rtis[rti].name === rtName)
  }
  
  handleSave(event) {
    let accountForm = this.template.querySelector('lightning-record-edit-form[data-id="accountForm"]')

    accountForm.submit()
  }


  // método para verificar se determinado campo foi corretamente preenchido. Caso não tenha sido, gera um erro
  isInputValid() {
    this.template.querySelectorAll(".validate").forEach(inputField => {
      if (inputField.value.trim() !== '') {
        console.log('input field value: ', inputField.value)
        inputField.reportValidity()
      }
    })
  }

  handleAccountSuccess(event) {
    let cnhForm = this.template.querySelector('lightning-record-edit-form[data-id="cnhForm"]')
    let rgForm = this.template.querySelector('lightning-record-edit-form[data-id="rgForm"]')
    let professionalInfoForm = this.template.querySelector('lightning-record-edit-form[data-id="professionalInfoForm"]')
    let phoneForm = this.template.querySelector('lightning-record-edit-form[data-id="phoneForm"]')
    let emailForm = this.template.querySelector('lightning-record-edit-form[data-id="emailForm"]')
    let addressForm = this.template.querySelector('lightning-record-edit-form[data-id="addressForm"]')
    let rendaInformadaForm = this.template.querySelector('lightning-record-edit-form[data-id="rendaInformadaForm"]')
    let rendaConsideradaForm = this.template.querySelector('lightning-record-edit-form[data-id="rendaConsideradaForm"]')
    let rendaConfirmadaForm = this.template.querySelector('lightning-record-edit-form[data-id="rendaConfirmadaForm"]')
    let accountPatrimonioForm = this.template.querySelector('lightning-record-edit-form[data-id="accountPatrimonioForm"]')
    let rendaMinimaOppForm = this.template.querySelector('lightning-record-edit-form[data-id="rendaMinimaOppForm"]')

    this.template.querySelectorAll('lightning-input-field[data-id="objectAccountId"]').forEach(field => {
      field.value = this.accountid
    })

    // CNH
    this.template.querySelector('lightning-input-field[data-id="cnhRecordTypeId"]').value = this.getRecordTypeId('CNH')
    
    // RG
    this.template.querySelector('lightning-input-field[data-id="rgRecordTypeId"]').value = this.getRecordTypeId('RG')

    // Phone
    this.template.querySelector('lightning-input-field[data-id="phoneChannel"]').value = 'SMS'
    
    // Email
    this.template.querySelector('lightning-input-field[data-id="emailChannel"]').value = 'EMAIL'
      
    if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="phoneInput"]').value)) {
      phoneForm.submit()
    }

    if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="emailInput"]').value)) {
      emailForm.submit()
    }

    // if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="rendaInformadaInput"]').value)) {
    //   this.template.querySelector('lightning-input-field[data-id="rendaInformadaTypeInput"]').value = 'MONTHLY_INCOME'
    // }

    // if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="rendaConsideradaInput"]').value)) {
    //   this.template.querySelector('lightning-input-field[data-id="rendaConsideradaTypeInput"]').value = 'PRESUMED_MONTHLY_INCOME'
    // }

    // if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="rendaConfirmadaInput"]').value)) {
    //   this.template.querySelector('lightning-input-field[data-id="rendaConfirmadaTypeInput"]').value = 'CONFIRMED_MONTHLY_INCOME'
    // }

    // if (!this.isBlank(this.template.querySelector('lightning-input-field[data-id="rgInput"]').value)) {
    //   rgForm.submit()
    // }

    cnhForm.submit()
    rgForm.submit()
    professionalInfoForm.submit()
    addressForm.submit()
    // rendaInformadaForm.submit()
    // rendaConsideradaForm.submit()
    // rendaConfirmadaForm.submit()
    accountPatrimonioForm.submit()
    rendaMinimaOppForm.submit()

    const eventToast = new ShowToastEvent({
      title: 'Sucesso!',
      message: 'Registro salvo com sucesso!',
      variant: 'success'
    });

    const payload = event.detail
    // console.log(JSON.stringify(payload))

    this.dispatchEvent(eventToast);
    
  }

  isBlank(value) {
    return (value === null || value === undefined || '') ? true : false
  }

  // handleInformedIncomeSuccess(event) {
  //   const fields = {}

  //   fields[ACCOUNT_FIELD.fieldApiName] = this.accountid
  //   fields[FINANCIAL_RESOURCE_FIELD.fieldApiName] = event.detail.id

  //   const recordInput = { apiName: ACC_FIN_REL_OBJECT.objectApiName, fields }
  //   createRecord(recordInput)
  //     .then(record => {
  //       console.log('registro de junção criado')
  //       console.log(JSON.stringify(recordInput))
  //     })
  //     .catch(error => {
  //     console.log('erro aconteceu')
  //   })
  // }

  // handlePresumedIncomeSuccess(event) {
  //   const fields = {}

  //   fields[ACCOUNT_FIELD.fieldApiName] = this.accountid
  //   fields[FINANCIAL_RESOURCE_FIELD.fieldApiName] = event.detail.id

  //   const recordInput = { apiName: ACC_FIN_REL_OBJECT.objectApiName, fields }
  //   createRecord(recordInput)
  //     .then(record => {
  //       console.log('registro de junção criado')
  //       console.log(JSON.stringify(recordInput))
  //     })
  //     .catch(error => {
  //     console.log('erro aconteceu')
  //   })
  // } 

  // handleConfirmedIncomeSuccess(event) {
  //   console.log(JSON.parse(JSON.stringify(event.detail)))
  //   console.log('Financial Resource Id: ', event.detail.id)

  //   const fields = {}

  //   fields[ACCOUNT_FIELD.fieldApiName] = this.accountid
  //   fields[FINANCIAL_RESOURCE_FIELD.fieldApiName] = event.detail.id

  //   const recordInput = { apiName: ACC_FIN_REL_OBJECT.objectApiName, fields }
  //   createRecord(recordInput)
  //     .then(record => {
  //       console.log('registro de junção criado')
  //       console.log(JSON.stringify(recordInput))
  //     })
  //     .catch(error => {
  //     console.log('erro aconteceu')
  //   })
  // }
}