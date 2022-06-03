import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getDocuments from '@salesforce/apex/DocumentApiController.getDocuments';
import EXTERNAL_ID_FIELD from '@salesforce/schema/Opportunity.ExternalId__c';
import RT_DEV_NAME from '@salesforce/schema/RecordType.DeveloperName';

const oppFields = [EXTERNAL_ID_FIELD];
const RT_FIELDS = [RT_DEV_NAME];

const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT = 'error';

export default class DocumentsDataTable extends LightningElement {

    @api recordId;
    isLoading = true;

    columns = [
        { label: 'Data', fieldName: 'formattedCreatedAt', type: 'datetime' },
        { label: 'Visualizar', fieldName: 'url', type: 'url', typeAttributes: {label: 'Link'},"cellAttributes":{"iconName":"utility:preview"}}
    ];

    recordTypeId;
    recordTypeDevName;
    oppExternalId;

    data = [];
    @track showTable = true;

    @wire(getRecord, { recordId: '$recordTypeId', fields: RT_FIELDS })
    getRTFields({ error, data }) {
        if (data) {
            this.recordTypeDevName = data.fields.DeveloperName.value;
            this.callDocumentsAPI();
        } else if (error) {
            this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
      }
    }

    @wire(getRecord, { recordId: '$recordId', fields: oppFields})
    getOppFields({ error, data }) {
        if (data) {
            this.oppExternalId = data?.fields?.ExternalId__c?.value;
            this.recordTypeId = data.recordTypeId;
            this.callDocumentsAPI();
        } else if (error) {
            this.showToast(ERROR_OCCURRED, ERROR_MESSAGE, ERROR_VARIANT);
      }
    }

    handleChange(event){
        if(event.detail.value.includes('OTHER')){
            this.showDescription = true;
        } else {
            this.showDescription = false;
        }
        this.selected = event.detail.value.join(';');
    }

    callDocumentsAPI(){
        if(this.oppExternalId && this.recordTypeDevName){
            this.isLoading = true;
            getDocuments({ opportunityExternalId: this.oppExternalId, recordTypeName: this.recordTypeDevName }).then( data => {
                if (data) {
                    this.data = data.items;
                    if(this.data.length > 0){
                        this.showTable = true;
                    } else {
                        this.showTable = false;
                    }
                }
            }).catch( error => {
                console.error(error);
            }).finally( () => {
                this.isLoading = false;
            })
        }
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
      }

}