import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInformation from '@salesforce/apex/FormalizationAnalysisController.getInformation'
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACTS_OBJECT from '@salesforce/schema/CommunicationContacts__c';
import DOCUMENTS_OBJECT from '@salesforce/schema/Documents__c';
import ADDRESS_OBJECT from '@salesforce/schema/Addresses__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { helper } from './formalizationAnalysisComponentHelper.js';

const VARIANT_BASE = 'base';
const VARIANT_BASE_COMPLETE = 'base-autocomplete';
const VARIANT_EXPIRED = 'expired';
const VARIANT_WARNING = 'warning';

export default class FormalizationAnalysis extends LightningElement {
    @api recordId;
    isLoading = true;
    analysisNotStarted = true;
    fullData;
    timeNow;
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
    p0Saved = false;
    p1Saved = false;
    p2Saved = false;
    p3Saved = false;
    p4Saved = false;
    p5Saved = false;
    //Save button Variables
    p0Disabled = true;
    p1Disabled = true;
    p2Disabled = true;
    p3Disabled = true;
    p4Disabled = true;
    p5Disabled = true;
    //final buttons Variables
    approveDisabled = true;
    rejectDisabled = true;
    pendencyDisabled = true;
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
    dataContact = [];
    dataAddress = [];
    dataBank = [];
    dataCompany = [];

    //Wired functions to get object fields
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accInfo({ data, error }) {
        if (data){
            this.accountFields = data.fields;
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACTS_OBJECT })
    conInfo({ data, error }) {
        if (data){
            this.contactsFields = { SMS: data.fields, EMAIL: data.fields };
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: ADDRESS_OBJECT })
    adrInfo({ data, error }) {
        if (data){
            this.addressFields = data.fields;
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');

        }
    }

    @wire(getObjectInfo, { objectApiName: DOCUMENTS_OBJECT })
    docInfo({ data, error }) {
        if (data){
            this.documentFields = { RG: data.fields, CPF: data.fields, PIS: data.fields };
        } else if (error)    {
            this.showToast('Error', JSON.stringify(error), 'error');
        }  
    }
    
    //getFields and build the dataForms to generate fields dynamically
    @wire (getInformation, {aOpportunityId : '$recordId'} )
    wiredOpportunity( wiredResult ){
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
            let contactDataFields = ['SMS.Code__c','EMAIL.Code__c'];
            let resultedArrayContactsData = [];
            //Address Section Variables
            let addressDataFields = ['PostalCode__c', 'Street__c', 'StreetNumber__c', 'Complement__c', 'Neighborhood__c', 'AreaLevel2__c', 'AreaLevel1__c'];
            let resultedArrayAddressData = [];
            //Bank Information Section Variables
            let bankDataFields = ['BankName__c', 'Agency__c', 'BankAccountNumber__c'];
            let resultedArrayBankData = [];
            //Company Section Variables
            let companyDataFields = ['CompanyName__c', 'CompanyCNPJ__c', 'CompanyStatus__c', 'Margin__c'];
            let resultedArrayCompanyData = [];
            
            //Account fields logic to generate array PersonalData + Bank + CompanyData
            Object.getOwnPropertyNames(this.accountFields).forEach( propertyName => {

                if( personalDataFields.includes(propertyName) ){
                    
                    resultedArrayPersonalData.push( this.returnNewObject(personalDataFields.indexOf(propertyName),this.accountFields,this.fullData,propertyName,'PersonalData'));

                } else if( bankDataFields.includes(propertyName) ){
                    
                    resultedArrayBankData.push( this.returnNewObject(bankDataFields.indexOf(propertyName),this.accountFields,this.fullData,propertyName,'Bank'));

                } else if( companyDataFields.includes(propertyName) ){
                   
                    resultedArrayCompanyData.push( this.returnNewObject(companyDataFields.indexOf(propertyName),this.accountFields,this.fullData,propertyName,'Company'));
                }

            });
        
            //PersonalData complementary Array
            Object.getOwnPropertyNames(this.documentFields).forEach( typeOfDocument => {
                Object.getOwnPropertyNames(this.documentFields[typeOfDocument]).forEach( propertyName => {
                    if(personalDataFields.includes(`${typeOfDocument}.${propertyName}`)){
                        let indexNumber = personalDataFields.indexOf(`${dataDocuments[typeOfDocument].DocumentType__c}.${propertyName}`);
                        resultedArrayPersonalData.push( this.returnNewObject( indexNumber, this.documentFields[typeOfDocument], dataDocuments[typeOfDocument], propertyName, 'PersonalData') );
                    }
                })
            });

            //Contacts Array
            Object.getOwnPropertyNames(this.contactsFields).forEach( typeOfContact => {
                Object.getOwnPropertyNames(this.contactsFields[typeOfContact]).forEach( propertyName => {
                    if(contactDataFields.includes(`${typeOfContact}.${propertyName}`)){
                        let fieldLabel = contactDataFields.indexOf(`${typeOfContact}.${propertyName}`) === 0 ? 'Telefone': 'E-mail';
                        resultedArrayContactsData.push( this.returnNewObject(contactDataFields.indexOf(`${typeOfContact}.${propertyName}`),this.contactsFields[typeOfContact],dataContacts[typeOfContact],propertyName,'Contact',fieldLabel) );
                    }
                })
            });

            //Address Array
            Object.getOwnPropertyNames(this.addressFields).forEach( propertyName => {

                if(addressDataFields.includes(propertyName)){
                    resultedArrayAddressData.push( this.returnNewObject(addressDataFields.indexOf(propertyName),this.addressFields,dataAddress,propertyName,'Address'));
                }
            });

            //this.dataGeneral = this.sortArray([...resultedArrayGeneral]);
            this.dataPersonal = this.sortArray([...resultedArrayPersonalData]);
            this.dataContact = this.sortArray([...resultedArrayContactsData]);
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
            });
        } else {
            return [];
        }
        
    }

    returnNewObject(id,objInput,dataInput,propertyName,inputSection,inputLabel){
        let label;
        if(inputLabel){
            label = inputLabel;
        } else {
            label = objInput[propertyName].label === 'Número do documento' ? dataInput.DocumentType__c : objInput[propertyName].label
        }

        return {    id: id, 
                    inputName: objInput[propertyName].apiName,
                    inputType: objInput[propertyName].dataType,
                    inputDisabled: !objInput[propertyName].updateable, 
                    inputLabel: label, 
                    inputValue: dataInput[propertyName],
                    inputSection: inputSection 
                };
    }

    handleProgress(event){
        //console.log(this.recordId);
        if(event.detail.variant === 'reject'){
            
            this.showToast('Aviso!','Ao rejeitar o campo, a proposta inteira será rejeitada.','warning');
        }

        if(event.detail.section === 'General'){
            this.eventResponsesGeneral.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataGeneral','eventResponsesGeneral','p0');
            
        }else if(event.detail.section === 'PersonalData'){
            this.eventResponsesPersonalData.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataPersonal','eventResponsesPersonalData','p1');

        }else if(event.detail.section === 'Contact'){
            this.eventResponsesContact.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataContact','eventResponsesContact','p2');

        }else if(event.detail.section === 'Address'){
            this.eventResponsesAddress.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataAddress','eventResponsesAddress','p3');

        }else if(event.detail.section === 'Bank'){
            this.eventResponsesBank.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataBank','eventResponsesBank','p4');

        }else if(event.detail.section === 'Company'){
            this.eventResponsesCompany.set(event.detail.position, event.detail.variant );
            this.readEventResponses('dataCompany','eventResponsesCompany','p5');

        }
    }

    readEventResponses(dataType, eventResponse, button){
        let value = 100/this[dataType].length;
        
        this[`${button}Progress`] = this[eventResponse].size * value;
        
        let values = Array.from(this[eventResponse].values()) ;
       
        if(values.includes('reject')) { 
            this[`${button}Variant`] = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this[`${button}Variant`] = VARIANT_WARNING;
        } else {
            this[`${button}Variant`] = VARIANT_BASE;
        }
        this[`${button}Saved`] = false;
        this.rejectDisabled = true;
        this.pendencyDisabled = true;
        this.approveDisabled = true;
        if(this[`${button}Progress`] >= 99.99){
            this[`${button}Disabled`] = false;
        }
    }

    checkButtonAvaliability(buttonVariant){
        let allProgress = ['p0','p1','p2','p3','p4','p5'];
        const isAllSectionsFinished = allProgress.reduce( (validSoFar, actualvalue) => {
            return validSoFar && this[`${actualvalue}Progress`] === 100 && this[`${actualvalue}Saved`]
        },this.p0Progress === 100 && this.p0Saved);

        
        if(isAllSectionsFinished){
            let variantArray = [];
            allProgress.forEach(item => {
                variantArray.push(this[`${item}Variant`]);
            });

            if(variantArray.includes('expired')){
                this.rejectDisabled = false;
                this.pendencyDisabled = true;
                this.approveDisabled = true;
            } else if (variantArray.includes('warning')){
                this.rejectDisabled = true;
                this.pendencyDisabled = false;
                this.approveDisabled = true;
            } else {
                this.rejectDisabled = true;
                this.pendencyDisabled = true;
                this.approveDisabled = false;
            }
        }
    }

    handleStartAnalysis(event){
        this.analysisNotStarted = false;
        this.timeNow = helper.formatDate();
    }

    handleSave(event){
        this[`p${event.target.value}Saved`] = true;
        if(this[`p${event.target.value}Variant`] === VARIANT_BASE){
            this[`p${event.target.value}Variant`] = VARIANT_BASE_COMPLETE;
        }

        this.checkButtonAvaliability(this[`p${event.target.value}Variant`]);
    }

    handleAccordeon(event){
        if(this.analysisNotStarted) { return; }
        
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