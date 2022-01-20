import { LightningElement, api, track } from 'lwc';
import search from '@salesforce/apex/SearchController.search';
import getRelatedRecord from '@salesforce/apex/SearchController.getRelatedRecord';

const DELAY = 300;

export default class SearchComponent extends LightningElement {

    @api valueId;
    @api valueName;
    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api mappedField;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields;
    @api fieldRequired;
    @api fieldReadonly;

    @track error;

    delayTimeout;
    searchRecords;
    selectedRecord = false;
    isLoading = false;

    connectedCallback(){

        let listFields = this.fields ? JSON.parse(JSON.stringify(this.fields)) : null;

        if(listFields && listFields.relatedObject && listFields.value){
            let relatedObject = listFields.relatedObject;
            let relatedRecord = listFields.value;

            getRelatedRecord({ 
                aRelatedObject: relatedObject, 
                aRelatedRecordId: relatedRecord
            })
            .then(result=>{
                this.selectedRecord = result;
            })
            .catch(error=>{
                console.log(error);
            });
        }        
    }

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;

        //valida se o valor informado não é composto apenas por espaço.
        if(!/^ *$/.test(searchKey)){
            this.delayTimeout = setTimeout(() => {
                if(searchKey.length >= 2){
                    search({ 
                        objectName : this.objName,
                        searchTerm : searchKey 
                    })
                    .then(result => {
                        this.searchRecords = JSON.parse(JSON.stringify(result));
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    })
                    .finally( ()=>{
                        //this.isLoading = false;
                    });
                }
            }, DELAY);
        }
    }

    handleSelect(event){
        
        let recordId = event.currentTarget.dataset.recordId;     
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        
        this.selectedRecord = selectRecord;

        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    recordId : recordId,
                    mappedId: this.mappedField
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose(){
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: { 
                data : {
                    recordId: '',
                    mappedId: this.mappedField
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    @api
    getValidityRelationship(){

        let isValid = true;
        this.template.querySelectorAll(".form-fields-search").forEach(elem => {
            console.log(elem.tagName);
            if(!elem.checkValidity()){
                isValid = false;
                elem.reportValidity();
            }
        });
        return isValid;
    }
}