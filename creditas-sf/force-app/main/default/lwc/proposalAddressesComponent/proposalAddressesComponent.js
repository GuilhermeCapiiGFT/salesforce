import { LightningElement, api, wire, track } from 'lwc';

import ADDRESSES_OBJECT from '@salesforce/schema/Addresses__c';
import SECTION_OBJECT from '@salesforce/schema/AddressDataSection__c';

import CEPSTATUS from '@salesforce/schema/AddressDataSection__c.CEPStatus__c';
import CEPPENDING from '@salesforce/schema/AddressDataSection__c.CEPPendingReason__c';
import CEPREJECT from '@salesforce/schema/AddressDataSection__c.CEPRejectReason__c';
import CEPOBSERVATION from '@salesforce/schema/AddressDataSection__c.CEPobservation__c';

import STREETSTATUS from '@salesforce/schema/AddressDataSection__c.StreetAddressStatus__c';
import STREETPENDING from '@salesforce/schema/AddressDataSection__c.StreetAddressPendingReason__c';
import STREETREJECT from '@salesforce/schema/AddressDataSection__c.StreetAddressRejectReason__c';
import STREETOBSERVATION from '@salesforce/schema/AddressDataSection__c.StreetAddressObservation__c';

import ADDRESSNUMBERSTATUS from '@salesforce/schema/AddressDataSection__c.AddressNumberStatus__c';
import ADDRESSNUMBERPENDING from '@salesforce/schema/AddressDataSection__c.AddressNumberPendingReason__c';
import ADDRESSNUMBERREJECT from '@salesforce/schema/AddressDataSection__c.AddressNumberRejectReason__c';
import ADDRESSNUMBEROBSERVATION from '@salesforce/schema/AddressDataSection__c.AddressNumberObservation__c';

import COMPLEMENTSTATUS from '@salesforce/schema/AddressDataSection__c.AddOnStatus__c';
import COMPLEMENTPENDING from '@salesforce/schema/AddressDataSection__c.AddOnPendingReason__c';
import COMPLEMENTREJECT from '@salesforce/schema/AddressDataSection__c.AddOnRejectReason__c';
import COMPLEMENTOBSERVATION from '@salesforce/schema/AddressDataSection__c.AddOnObservation__c';

import NEIGHBORHOODSTATUS from '@salesforce/schema/AddressDataSection__c.NeighborhoodStatus__c';
import NEIGHBORHOODPENDING from '@salesforce/schema/AddressDataSection__c.NeighborhoodPendingReason__c';
import NEIGHBORHOODREJECT from '@salesforce/schema/AddressDataSection__c.NeighborhoodRejectReason__c';
import NEIGHBORHOODOBSERVATION from '@salesforce/schema/AddressDataSection__c.NeighborhoodObservation__c';

import CITYSTATUS from '@salesforce/schema/AddressDataSection__c.CityStatus__c';
import CITYPENDING from '@salesforce/schema/AddressDataSection__c.CityPendingReason__c';
import CITYREJECT from '@salesforce/schema/AddressDataSection__c.CityRejectReason__c';
import CITYOBSERVATION from '@salesforce/schema/AddressDataSection__c.CityObservation__c';

import STATESTATUS from '@salesforce/schema/AddressDataSection__c.StateStatus__c';
import STATEPENDING from '@salesforce/schema/AddressDataSection__c.StatePendingReason__c';
import STATEREJECT from '@salesforce/schema/AddressDataSection__c.StateRejectReason__c';
import STATEOBSERVATION from '@salesforce/schema/AddressDataSection__c.StateObservation__c';

import COUNTRYSTATUS from '@salesforce/schema/AddressDataSection__c.CountryStatus__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

//import upsertAddress from '@salesforce/apex/ProposalAddressesController.saveAddress';
import getRecordAddressSection from '@salesforce/apex/ProposalAddressesController.getAddressSectiontDetails';
import upsertAddressSection from '@salesforce/apex/ProposalAddressesController.saveAddressSection';

const FIELDSVALIDATIONCEP = [CEPSTATUS, CEPPENDING, CEPREJECT, CEPOBSERVATION]
const FIELDSVALIDATIONSTREET = [STREETSTATUS, STREETPENDING, STREETREJECT, STREETOBSERVATION]
const FIELDSVALIDATIONADDRESSNUMBER = [ADDRESSNUMBERSTATUS, ADDRESSNUMBERPENDING, ADDRESSNUMBERREJECT, ADDRESSNUMBEROBSERVATION]
const FIELDSVALIDATIONCOMPLEMENTNUMBER = [COMPLEMENTSTATUS, COMPLEMENTPENDING, COMPLEMENTREJECT, COMPLEMENTOBSERVATION]
const FIELDSVALIDATIONNEIGHBORHOOD = [NEIGHBORHOODSTATUS, NEIGHBORHOODPENDING, NEIGHBORHOODREJECT, NEIGHBORHOODOBSERVATION]
const FIELDSVALIDATIONCITY = [CITYSTATUS, CITYPENDING, CITYREJECT, CITYOBSERVATION]
const FIELDSVALIDATIONSTATE = [STATESTATUS, STATEPENDING, STATEREJECT, STATEOBSERVATION]
const FIELDSVALIDATIONCOUNTRY = [COUNTRYSTATUS]

export default class ProposalAddressesComponent extends LightningElement {

  //@api accountid
  @api opportunityid;
  error
  
  address
  recordTypeId
  
  fieldsValidation = [FIELDSVALIDATIONCEP, FIELDSVALIDATIONSTREET, FIELDSVALIDATIONADDRESSNUMBER, FIELDSVALIDATIONCOMPLEMENTNUMBER, FIELDSVALIDATIONNEIGHBORHOOD, FIELDSVALIDATIONCITY, FIELDSVALIDATIONSTATE, FIELDSVALIDATIONCOUNTRY]
  fieldsStatus = ['CEPStatus__c', 'StreetAddressStatus__c', 'AddressNumberStatus__c', 'AddOnStatus__c', 'NeighborhoodStatus__c', 'CityStatus__c', 'StateStatus__c', 'CountryStatus__c']
  
  // Controller save button
  disabledBtnSave = true

  recordAddressId = ''
  addressData

  // Addresses Info Fields
  @track cepNumber     = {value: '', fieldReadOnly: true}
  @track street        = {value: '', fieldReadOnly: true}
  @track streetNumber  = {value: '', fieldReadOnly: true}
  @track complement    = {value: '', fieldReadOnly: true}
  @track neighborhood  = {value: '', fieldReadOnly: true}
  @track city          = {value: '', fieldReadOnly: true}
  @track state         = {value: '', fieldReadOnly: true}
  @track country       = {value: '', fieldReadOnly: true}
  
  // Checkboxes Values
  value = [];
  preValue = [];

  // Array converted to payload afterwards
  addressValue = []

  // refresh apex
  recordAddress
  
  // validation object for the address section
  objValidationSection = {
    'sobjectType': SECTION_OBJECT.objectApiName
  }

  resultRecordAddressFunction(result) {

    if (result.data) {

      let data = result.data;

      this.addressValue.push(data ? Object.assign({}, data) : {'sobjectType': SECTION_OBJECT.objectApiName, Opportunity__c: this.opportunityid})

      this.cepNumber.value          = data?.PostalCode__c    ? data.PostalCode__c   : null
      this.street.value             = data?.Street__c        ? data.Street__c       : null
      this.streetNumber.value       = data?.StreetNumber__c  ? data.StreetNumber__c : null
      this.complement.value         = data?.Complement__c    ? data.Complement__c   : null
      this.neighborhood.value       = data?.Neighborhood__c  ? data.Neighborhood__c : null
      this.city.value               = data?.AreaLevel2__c    ? data.AreaLevel2__c   : null
      this.state.value              = data?.AreaLevel1__c    ? data.AreaLevel1__c   : null
      this.country.value            = data?.Country__c       ? data.Country__c      : null
            
    }else if (result.error) {
      console.log('Error getting Address values: '+ result.error);
    }
  }

  // Get fields permission in AddressDataSection object
  @wire(getObjectInfo, { objectApiName: SECTION_OBJECT  })
  recordTypeAddress({ error, data }) {
    if(data) {
      this.cepNumber.fieldReadOnly     = !data?.fields?.PostalCode__c?.updateable     
      this.street.fieldReadOnly        = !data?.fields?.Street__c?.updateable  
      this.streetNumber.fieldReadOnly  = !data?.fields?.StreetNumber__c?.updateable        
      this.complement.fieldReadOnly    = !data?.fields?.Complement__c?.updateable      
      this.neighborhood.fieldReadOnly  = !data?.fields?.Neighborhood__c?.updateable        
      this.city.fieldReadOnly          = !data?.fields?.AreaLevel2__c?.updateable
      this.state.fieldReadOnly         = !data?.fields?.AreaLevel1__c?.updateable 
      this.country.fieldReadOnly       = !data?.fields?.Country__c?.updateable 
    }
    else if(error){
      console.log(error);
    }
  }

  @wire(getRecordAddressSection, { opportunityId: '$opportunityid' })
  recordAddressSection(result) {

    this.recordAddress = result
    
    this.resultRecordAddressFunction(result);

    if (result.data) {
      let resultValidationSection = { ...this.objValidationSection, ...result.data }
      this.objValidationSection = resultValidationSection

      console.log(this.objValidationSection)

      let listStatus = this.fieldsStatus

      for (let index in listStatus) {
        let status = listStatus[index]
        this.template.querySelectorAll("[data-status='" + status + "']").forEach(function (item) {
          if (item.value === resultValidationSection[status]) {
            item.checked = true
            item.setAttribute('data-value', item.value)
          }
        })
      }
      let info = this.getPercentage()
      this.sendInfo(info)
    } else if (result.error) {
      console.log('Error on getting checkboxes values')
    }
  }

  handleSaveSection() {

    this.disabledBtnSave = true;
    this.saveFieldsValidation();
  }

  // saveFields() {
  //   this.disabledBtnSave = true;
  //   let payload = this.addressValue;
    
  //   upsertAddress({addresses : payload})
  //   .then(result => {
  //     refreshApex(this.resultRecordCommunication);
  //     console.log({ result }) 
      
  //   })
  //   .catch(error =>{
  //     console.log(error);
  //     this.disabledBtnSave = false;
  //     this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error')
  //   })
  // }

  saveFieldsValidation() {

    this.objValidationSection.Opportunity__c = this.opportunityid;
    let payload = this.objValidationSection;
    console.log('Vai salvar: '+ JSON.stringify(payload));
    console.log({ payload });
    
    upsertAddressSection({addressSection : payload})
    .then(result => {
      refreshApex(this.recordAddress);
      this.showToast('', 'Registro atualizado com sucesso!', 'success');
      this.disabledBtnSave = false;
    })
    .catch(error =>{
      console.log(error);
      this.disabledBtnSave = false;
      this.showToast('', 'Ocorreu um erro ao salvar o registro!', 'error');
    })
  }

  handleChangeCheckbox(event) {
    this.checksOnlyOne(event)
    this.saveObjectValues(event)
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

  checksOnlyOne(event) {
    let currentCheckbox = event.currentTarget.name;
    let currentCheckboxValue = event.currentTarget.value;
    let modal = {};

    this.template.querySelectorAll('input[name='+currentCheckbox+']').forEach(elem => {
      let oldValue = elem.getAttribute('data-value');
      let newValue = currentCheckboxValue;

      if(oldValue !== null && elem.value === oldValue) {
        elem.checked = false;
        newValue = '';
        
      } else if(elem.value === currentCheckboxValue) {
        newValue = currentCheckboxValue;
        elem.checked = true;
      }
      elem.setAttribute('data-value', newValue);

      if (event.target.checked && (currentCheckboxValue == 'Rejeitar' || currentCheckboxValue == 'Pendenciar'))
      {
        let modalReason = (currentCheckboxValue == 'Rejeitar') ? 'reject' : 'pendency'
        modal['modalReason'] = modalReason
        modal['openModalReason'] = true
        modal['fieldReason'] = event.target.getAttribute('data-field')
        modal['objectReason'] = SECTION_OBJECT.objectApiName
      }
    });

    let info = this.getPercentage();
    info = {...info, modal};

    this.sendInfo(info);
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
    let returnedId = this.template.querySelector("div[data-id='ContainerDadosEndereco']").getAttribute("data-id")
    let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
    
    let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')
    let totalLines = 8;

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
    selectedCheckboxes = 0;
    
    info.variant = infoVariant
    info.value = infoValue
    info.returnedId = returnedId
  
    this.controllerSave(info.value)

    return info
  }

  controllerSave(percentageSection){
    this.disabledBtnSave = (percentageSection != 100) ? true : false
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event)
  }

  @api
  getReasonSelected(result){
    let validationReason = JSON.parse(result)
    if(validationReason.reason == null){
      this.uncheckReason(validationReason.field)
    }else{
      this.setMapReason(validationReason)
    }
  }

  uncheckReason(reason){
    let field = this.template.querySelector('[data-field="'+reason+'"]')
    field.checked = false
    field.setAttribute('data-value', '')
    let info = this.getPercentage()
    this.sendInfo(info)
  }

  setMapReason(selectedReason){

    let observation = selectedReason.observation ? selectedReason.observation : ''
    let objValidationSection = this.objValidationSection

    if( ['CEPPendingReason__c','CEPRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.CEPobservation__c = observation
    }
    else if(['StreetAddressPendingReason__c','StreetAddressRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.StreetAddressObservation__c = observation
    }
    else if(['AddressNumberPendingReason__c','AddressNumberRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.AddressNumberObservation__c = observation
    }
    else if(['AddOnPendingReason__c','AddOnRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.AddOnObservation__c = observation
    }
    else if(['NeighborhoodPendingReason__c','NeighborhoodRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.NeighborhoodObservation__c = observation
    }
    else if(['CityPendingReason__c','CityRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.CityObservation__c = observation
    }
    else if(['StatePendingReason__c','StateRejectReason__c'].includes(selectedReason.field)){
      objValidationSection[selectedReason.field] = selectedReason.reason
      objValidationSection.StateObservation__c = observation
    }
  }

  handleInputChange(event) {
    let objectAddress = this.addressValue[0]
    let field = event.target.getAttribute('data-id')
    let currentValue = event.target.value
    console.log('objectAddress: '+ JSON.stringify(objectAddress));
    console.log('field: '+ field);
    console.log('currentValue: '+ currentValue);
    objectAddress[field] = currentValue

    this.objValidationSection = objectAddress;
    
    console.log('objectAddress After: '+ JSON.stringify(objectAddress));
  }
}