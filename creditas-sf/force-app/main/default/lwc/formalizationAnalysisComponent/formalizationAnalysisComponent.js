import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInformation from '@salesforce/apex/formalizationAnalysisController.getInformation';
//import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import ACCOUNT_RECORD from '@salesforce/schema/PersonalDataSection__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACTS_OBJECT from '@salesforce/schema/CommunicationContacts__c';
import DOCUMENTS_OBJECT from '@salesforce/schema/Documents__c';
import ADDRESS_OBJECT from '@salesforce/schema/Addresses__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

//CONSTANTS
const VARIANT_BASE = 'base-autocomplete';
const VARIANT_EXPIRED = 'expired';
const VARIANT_WARNING = 'warning';
export default class FormalizationAnalysis extends LightningElement {
    @api recordId;
    isLoading = true;
    fullData;
    error;
    //ProgressRing Variables
    p0Progress = 0;
    p1Progress = 0;
    p2Progress = 0;
    p3Progress = 0;
    p4Progress = 0;
    p5Progress = 0;
    p6Progress = 0;
    p0Variant = VARIANT_BASE;
    p1Variant = VARIANT_BASE;
    p2Variant = VARIANT_BASE;
    p3Variant = VARIANT_BASE;
    p4Variant = VARIANT_BASE;
    p5Variant = VARIANT_BASE;
    p6Variant = VARIANT_BASE;
    //Save button Variables
    p0Disabled = true;
    p1Disabled = true;
    p2Disabled = true;
    p3Disabled = true;
    p4Disabled = true;
    p5Disabled = true;
    //eventResponses
    eventResponsesGeneral = new Map();
    eventResponsesPersonalData = new Map();
    eventResponsesContact = new Map();
    eventResponsesAddress = new Map();
    eventResponsesBank = new Map();
    eventResponsesCompany = new Map();
    //ObjectFieldsInfo
    accountFields = undefined;
    contactsFields = undefined;
    addressFields = undefined;
    documentFields = undefined;
    //SectionDatas
    dataGeneral = [ {id: 0, inputName: "PlaceHolder", inputValue: "PlaceHolder", inputLabel: "PlaceHolder", inputDisabled: true, inputType: 'text', inputSection: 'General'} ];
    dataPersonal = [];
    dataContact = [ {id: 0, inputName: "PlaceHolder", inputValue: "Placeholder", inputLabel: "PlaceHolder", inputDisabled: true, inputType: 'text', inputSection: 'Contact'} ];
    dataAddress = [];
    dataBank = [];
    dataCompany = [];

    //Wired functions to get object fields
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accInfo({ data, error }) {
        if (data){
            this.accountFields = data.fields;
            console.log('accountFields');
            //console.dir(this.accountFields);
            this.loadData();
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACTS_OBJECT })
    conInfo({ data, error }) {
        if (data){
            this.contactsFields = data.fields;
            console.log('conFields');
            //this.loadData();
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: ADDRESS_OBJECT })
    adrInfo({ data, error }) {
        if (data){
            console.log('addressFields');
            this.addressFields = data.fields;
            //this.loadData();
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: DOCUMENTS_OBJECT })
    docInfo({ data, error }) {
        console.log('documentFields');
        if (data){
            this.documentFields = data.fields;
            //this.loadData();
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');
        }  
    }

    
    //getFields and build the dataForms to generate fields dynamically
    @wire (getInformation, {aOpportunityId : '$recordId'} )
    wiredOpportunity( wiredResult ){
        console.log('getOpps');
        if(wiredResult.data === undefined){
            this.isLoading = true;
        } else if (wiredResult.data && this.documentFields !== undefined && this.accountFields !== undefined && this.addressFields !== undefined && this.contactsFields !== undefined) {
            this.fullData = wiredResult.data;
            let dataAddress = [...wiredResult.data.Enderecos__r].reduce((data, obj) => ({ ...data, Address: obj }), {})['Address'];
            let dataDocuments = [...wiredResult.data.Documentos__r].reduce((data, obj) => ({ ...data, [obj.DocumentType__c]: obj }), {});
            let dataContacts = [...wiredResult.data.CommunicationContacts__r].reduce((data, obj) => ({ ...data, [obj.Channel__c]: obj }), {});
            //General Section Variables
            let generalDataFields = [];
            let resultedArrayGeneral = [];
            //Personal Data Section Variables
            let personalDataFields = ['FirstName__c', 'Mother__c', 'BirthDate__c', 'Gender__c','CPF.DocumentNumber__c','RG.DocumentNumber__c', 'RG.Issuer__c', 'RG.IssueDate__c', 'RG.IssuerState__c', 'CivilStatus__c','PIS.DocumentNumber__c', 'ExternalCreationDate__c', 'AdmissionDate__c', 'ExternalUpdatedDate__c'];
            let resultedArrayPersonalData = [];
            //Contacts Data Section Variables
            let contactDataFields = [];
            let resultedArrayGeneralData = [];
            //Address Section Variables
            let addressDataFields = ['PostalCode__c', 'Street__c', 'StreetNumber__c', 'Complement__c', 'Neighborhood__c', 'AreaLevel2__c', 'AreaLevel1__c'];
            let resultedArrayAddressData = [];
            //Bank Information Section Variables
            let bankDataFields = ['BankName__c', 'Agency__c', 'BankAccountNumber__c'];
            let resultedArrayBankData = [];
            //Company Section Variables
            let companyDataFields = ['CompanyName__c', 'CompanyCNPJ__c', 'CompanyStatus__c', 'Margin__c'];
            let resultedArrayCompanyData = [];
            
            Object.getOwnPropertyNames(this.accountFields).forEach( propertyName => {
                if( personalDataFields.includes(propertyName) ){
                    resultedArrayPersonalData.push( {   id: personalDataFields.indexOf(propertyName), 
                                                        inputName: this.accountFields[propertyName].apiName,
                                                        inputType: this.accountFields[propertyName].dataType,
                                                        inputDisabled: !this.accountFields[propertyName].updateable, 
                                                        inputLabel: this.accountFields[propertyName].label, 
                                                        inputValue: this.fullData[propertyName], 
                                                        inputSection: 'PersonalData' }
                                                    );
                } else if( bankDataFields.includes(propertyName) ){
                    resultedArrayBankData.push( {   id: bankDataFields.indexOf(propertyName),
                                                    inputName: this.accountFields[propertyName].apiName,
                                                    inputType: this.accountFields[propertyName].dataType,
                                                    inputDisabled: !this.accountFields[propertyName].updateable,
                                                    inputLabel: this.accountFields[propertyName].label, 
                                                    inputValue: this.fullData[propertyName], 
                                                    inputSection: 'Bank'}
                                                );
                    
                } else if( companyDataFields.includes(propertyName) ){
                    resultedArrayCompanyData.push( {    id: companyDataFields.indexOf(propertyName),
                                                        inputName: this.accountFields[propertyName].apiName, 
                                                        inputType: this.accountFields[propertyName].dataType,
                                                        inputDisabled: !this.accountFields[propertyName].updateable, 
                                                        inputLabel: this.accountFields[propertyName].label, 
                                                        inputValue: this.fullData[propertyName], 
                                                        inputSection: 'Company'}
                                                );
                }

            });

            Object.getOwnPropertyNames(dataDocuments).forEach( typeOfDocument => {
                Object.getOwnPropertyNames(dataDocuments[typeOfDocument]).forEach( propertyName => {
                   
                    if(personalDataFields.includes(`${dataDocuments[typeOfDocument].DocumentType__c}.${propertyName}`)){
                        resultedArrayPersonalData.push( {   id: personalDataFields.indexOf(`${dataDocuments[typeOfDocument].DocumentType__c}.${propertyName}`), 
                                                            inputName: this.documentFields[propertyName].apiName,
                                                            inputType: this.documentFields[propertyName].dataType,
                                                            inputDisabled: !this.documentFields[propertyName].updateable, 
                                                            inputLabel: this.documentFields[propertyName].label === 'Número do documento' ? dataDocuments[typeOfDocument].DocumentType__c : this.documentFields[propertyName].label, 
                                                            inputValue: dataDocuments[typeOfDocument][propertyName],
                                                            inputSection: 'PersonalData' }
                                                            );
                    }

                })

            });

            Object.getOwnPropertyNames(dataAddress).forEach( propertyName => {

                if(addressDataFields.includes(propertyName)){
                    resultedArrayAddressData.push( {   id: addressDataFields.indexOf(propertyName), 
                                                        inputName: this.addressFields[propertyName].apiName,
                                                        inputType: this.addressFields[propertyName].dataType,
                                                        inputDisabled: !this.addressFields[propertyName].updateable, 
                                                        inputLabel: this.addressFields[propertyName].label, 
                                                        inputValue: dataAddress[propertyName],
                                                        inputSection: 'Address' }
                                                        );
                }

            });
            //this.dataGeneral = this.sortArray([...resultedArrayGeneral]);
            this.dataPersonal = this.sortArray([...resultedArrayPersonalData]);
            //this.dataContact = this.sortArray([...resultedArrayGeneralData]);
            this.dataAddress = this.sortArray([...resultedArrayAddressData]);
            this.dataBank = this.sortArray([...resultedArrayBankData]);
            this.dataCompany = this.sortArray([...resultedArrayCompanyData]);
            this.isLoading = false;          
        } else if (wiredResult.error) {
            
            this.showToast('Error', JSON.stringify(wiredResult.error), 'error');

        }
    }
    
    sortArray(array){
        if(array){
            return array.sort( (a,b) => {
                return a.id - b.id;
            })
        } else {
            return [];
        }
        
    }
    
    loadData(){
        //console.log(this.recordId);
        if(this.accountFields && this.addressFields && this.documentFields){
            getInformation( {aOpportunityId : this.recordId })
            .then( result => {
                this.fullData = result;
                let dataAddress = [...this.fullData.Enderecos__r].reduce((data, obj) => ({ ...data, Address: obj }), {})['Address'];
                let dataDocuments = [...this.fullData.Documentos__r].reduce((data, obj) => ({ ...data, [obj.DocumentType__c]: obj }), {});
                //General Section Variables
                let generalDataFields = [];
                let resultedArrayGeneral = [];
                //Personal Data Section Variables
                let personalDataFields = ['FirstName__c', 'Mother__c', 'BirthDate__c', 'Gender__c','CPF.DocumentNumber__c','RG.DocumentNumber__c', 'RG.Issuer__c', 'RG.IssueDate__c', 'RG.IssuerState__c', 'CivilStatus__c','PIS.DocumentNumber__c', 'ExternalCreationDate__c', 'AdmissionDate__c', 'ExternalUpdatedDate__c'];
                let resultedArrayPersonalData = [];
                //Contacts Data Section Variables
                let contactDataFields = [];
                let resultedArrayGeneralData = [];
                //Address Section Variables
                let addressDataFields = ['PostalCode__c', 'Street__c', 'StreetNumber__c', 'Complement__c', 'Neighborhood__c', 'AreaLevel2__c', 'AreaLevel1__c'];
                let resultedArrayAddressData = [];
                //Bank Information Section Variables
                let bankDataFields = ['BankName__c', 'Agency__c', 'BankAccountNumber__c'];
                let resultedArrayBankData = [];
                //Company Section Variables
                let companyDataFields = ['CompanyName__c', 'CompanyCNPJ__c', 'CompanyStatus__c', 'Margin__c'];
                let resultedArrayCompanyData = [];
                
                Object.getOwnPropertyNames(this.accountFields).forEach( propertyName => {
                    if( personalDataFields.includes(propertyName) ){
                        resultedArrayPersonalData.push( {   id: personalDataFields.indexOf(propertyName), 
                                                            inputName: this.accountFields[propertyName].apiName,
                                                            inputType: this.accountFields[propertyName].dataType,
                                                            inputDisabled: !this.accountFields[propertyName].updateable, 
                                                            inputLabel: this.accountFields[propertyName].label, 
                                                            inputValue: this.fullData[propertyName], 
                                                            inputSection: 'PersonalData' }
                                                        );
                    } else if( bankDataFields.includes(propertyName) ){
                        resultedArrayBankData.push( {   id: bankDataFields.indexOf(propertyName),
                                                        inputName: this.accountFields[propertyName].apiName,
                                                        inputType: this.accountFields[propertyName].dataType,
                                                        inputDisabled: !this.accountFields[propertyName].updateable,
                                                        inputLabel: this.accountFields[propertyName].label, 
                                                        inputValue: this.fullData[propertyName], 
                                                        inputSection: 'Bank'}
                                                    );
                        
                    } else if( companyDataFields.includes(propertyName) ){
                        resultedArrayCompanyData.push( {    id: companyDataFields.indexOf(propertyName),
                                                            inputName: this.accountFields[propertyName].apiName, 
                                                            inputType: this.accountFields[propertyName].dataType,
                                                            inputDisabled: !this.accountFields[propertyName].updateable, 
                                                            inputLabel: this.accountFields[propertyName].label, 
                                                            inputValue: this.fullData[propertyName], 
                                                            inputSection: 'Company'}
                                                    );
                    }

                });

                Object.getOwnPropertyNames(dataDocuments).forEach( typeOfDocument => {
                    Object.getOwnPropertyNames(dataDocuments[typeOfDocument]).forEach( propertyName => {
                    
                        if(personalDataFields.includes(`${dataDocuments[typeOfDocument].DocumentType__c}.${propertyName}`)){
                            resultedArrayPersonalData.push( {   id: personalDataFields.indexOf(`${dataDocuments[typeOfDocument].DocumentType__c}.${propertyName}`), 
                                                                inputName: this.documentFields[propertyName].apiName,
                                                                inputType: this.documentFields[propertyName].dataType,
                                                                inputDisabled: !this.documentFields[propertyName].updateable, 
                                                                inputLabel: this.documentFields[propertyName].label === 'Número do documento' ? dataDocuments[typeOfDocument].DocumentType__c : this.documentFields[propertyName].label, 
                                                                inputValue: dataDocuments[typeOfDocument][propertyName],
                                                                inputSection: 'PersonalData' }
                                                                );
                        }

                    })

                });

                Object.getOwnPropertyNames(dataAddress).forEach( propertyName => {

                    if(addressDataFields.includes(propertyName)){
                        resultedArrayAddressData.push( {   id: addressDataFields.indexOf(propertyName), 
                                                            inputName: this.addressFields[propertyName].apiName,
                                                            inputType: this.addressFields[propertyName].dataType,
                                                            inputDisabled: !this.addressFields[propertyName].updateable, 
                                                            inputLabel: this.addressFields[propertyName].label, 
                                                            inputValue: dataAddress[propertyName],
                                                            inputSection: 'Address' }
                                                            );
                    }

                });
                //this.dataGeneral = this.sortArray([...resultedArrayGeneral]);
                this.dataPersonal = this.sortArray([...resultedArrayPersonalData]);
                //this.dataContact = this.sortArray([...resultedArrayGeneralData]);
                this.dataAddress = this.sortArray([...resultedArrayAddressData]);
                this.dataBank = this.sortArray([...resultedArrayBankData]);
                this.dataCompany = this.sortArray([...resultedArrayCompanyData]);
                
            })
            .catch( error => {
                console.dir(error);
                this.showToast('Erro', JSON.stringify(error),'error');
            })
            .finally( () => {
                this.isLoading = false;
            });
        }
    }
    handleProgress(event){
        //console.log(this.recordId);
        if(event.detail.variant === 'reject'){
            
            this.showToast('Aviso!','Ao rejeitar o campo, a proposta inteira será rejeitada.','warning');
        }

        if(event.detail.section === 'General'){
            this.eventResponsesGeneral.set(event.detail.position, event.detail.variant );
            this.readEventResponsesGeneral();
            
        }else if(event.detail.section === 'PersonalData'){
            this.eventResponsesPersonalData.set(event.detail.position, event.detail.variant );
            this.readEventResponsesPersonalData();

        }else if(event.detail.section === 'Contact'){
            this.eventResponsesContact.set(event.detail.position, event.detail.variant );
            this.readEventResponsesContact();

        }else if(event.detail.section === 'Address'){
            this.eventResponsesAddress.set(event.detail.position, event.detail.variant );
            this.readEventResponsesAddress();

        }else if(event.detail.section === 'Bank'){
            this.eventResponsesBank.set(event.detail.position, event.detail.variant );
            this.readEventResponsesBank();

        }else if(event.detail.section === 'Company'){
            this.eventResponsesCompany.set(event.detail.position, event.detail.variant );
            this.readEventResponsesCompany();

        }
    }
    
    readEventResponsesGeneral(){
        let value = 100/this.dataGeneral.length;
        
        this.p0Progress = this.eventResponsesGeneral.size * value;
        
        let values = Array.from(this.eventResponsesGeneral.values()) ;
       
        if(values.includes('reject')) { 
            this.p0Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p0Variant = VARIANT_WARNING;
        } else {
            this.p0Variant = VARIANT_BASE;
        }
        
        if(this.p0Progress >= 99.99){
      
            this.p0Disabled = false;
        }
    }

    readEventResponsesPersonalData(){
        let value = 100/this.dataPersonal.length;
        
        this.p1Progress = this.eventResponsesPersonalData.size * value;
        
        let values = Array.from(this.eventResponsesPersonalData.values()) ;
       
        if(values.includes('reject')) { 
            this.p1Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p1Variant = VARIANT_WARNING;
        } else {
            this.p1Variant = VARIANT_BASE;
        }
        
        if(this.p1Progress >= 99.99){
            this.p1Disabled = false;
        }
    }

    readEventResponsesContact(){
        let value = 100/this.dataContact.length;
        
        this.p2Progress = this.eventResponsesContact.size * value;
        
        let values = Array.from(this.eventResponsesContact.values()) ;
       
        if(values.includes('reject')) { 
            this.p2Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p2Variant = VARIANT_WARNING;
        } else {
            this.p2Variant = VARIANT_BASE;
        }
        
        if(this.p2Progress >= 99.99){
            this.p2Disabled = false;
        }
    }
    
    readEventResponsesAddress(){
        let value = 100/this.dataAddress.length;
        
        this.p3Progress = this.eventResponsesAddress.size * value;
       
        let values = Array.from(this.eventResponsesAddress.values()) ;
        
        if(values.includes('reject')) { 
            this.p3Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p3Variant = VARIANT_WARNING;
        } else {
            this.p3Variant = VARIANT_BASE;
        }
        
        if(this.p3Progress >= 99.99){
            this.p3Disabled = false;
        } 
    }

    readEventResponsesBank(){
        let value = 100/this.dataBank.length;
        
        this.p4Progress = this.eventResponsesBank.size * value;
       
        let values = Array.from(this.eventResponsesBank.values()) ;
        
        if(values.includes('reject')) { 
            this.p4Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p4Variant = VARIANT_WARNING;
        } else {
            this.p4Variant = VARIANT_BASE;
        }
        
        if(this.p4Progress >= 99.99){
            this.p4Disabled = false;
        } 
    }

    readEventResponsesCompany(){
        let value = 100/this.dataCompany.length;
        
        this.p5Progress = this.eventResponsesCompany.size * value;
       
        let values = Array.from(this.eventResponsesCompany.values()) ;
        
        if(values.includes('reject')) { 
            this.p5Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p5Variant = VARIANT_WARNING;
        } else {
            this.p5Variant = VARIANT_BASE;
        }
        
        if(this.p5Progress >= 99.99){
            this.p5Disabled = false;
        } 
    }

    handleAccordeon(event){
        //event.target.parentElement.parentElement.parentElement.parentElement.classList.toggle('slds-is-open');
        
        let elementValue = event.target.parentElement.value;        
        let elemControls = this.template.querySelectorAll('.slds-accordion__section');
        if(Array.from(elemControls[elementValue].classList).includes('slds-is-open')){
            elemControls[elementValue].classList.toggle('slds-is-open');
            return;
        }
        
        let i;     
        for(i = 0;  i < elemControls.length; i++){
            elemControls[i].classList.remove('slds-is-open');
           
        }
        elemControls[elementValue].classList.add('slds-is-open');
        

    }

    closeModal(event){
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    showToast(title, message, variant){
        const event = new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
    }
    
}