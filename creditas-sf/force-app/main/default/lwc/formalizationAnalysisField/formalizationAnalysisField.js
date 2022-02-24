import getMapPickList from '@salesforce/apex/formalizationAnalysisController.getMapPickList';
import { LightningElement, api } from 'lwc';

export default class FormalizationAnalysisField extends LightningElement {
    @api input
    inputType;
    inputLabel;
    inputName;
    inputSection;
    inputDisabled;
    inputValue;
    isTextInput = false;
    isPickListInput = false;
    dateStyle = '';
    //Events Variables
    openModalReason = false;
    modalReasonField;
    modalType;
    picklistValues = [];

    connectedCallback(){
        this.inputName = this.input.inputName;
        this.inputType = this.input.inputType;
        this.inputLabel = this.input.inputLabel;
        this.inputDisabled = this.input.inputDisabled;
        this.inputValue = this.input.inputValue;
        this.inputSection = this.input.inputSection;
        if(this.input.inputType === 'Picklist'){
            getMapPickList({objApiName: 'Account', fieldApiName: this.inputName}).then( result => {
                this.picklistValues = JSON.parse(result);
            }).catch(error => {
                console.log(JSON.stringify(error));
            }).finally( () => {
                //console.log(this.picklistValues);
            })
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    renderedCallback(){
        this.configureFields();
    }

    configureFields(){
        if(this.inputType === 'Date' || this.inputType === "DateTime"){
            this.dateStyle = 'short';
            this.isTextInput = true;
        } else if (this.inputType === 'Picklist'){
            this.isPickListInput = true;
        } else {
            this.isTextInput = true;
        }
    }

    get pickListOptions() {
        return this.picklistValues;
    }
    
    handleCheckboxChange(event){
   
        this.template.querySelectorAll('.isCheckBox').forEach(elem => {
            elem.checked = false;
        });
        
        event.target.checked = true;
    }
    
    handleApprove(event){
        this.sendProgressEvent('approve');
    }

    handleReject(event){
        this.sendProgressEvent('reject');
        this.openModalReason = true;
        this.modalReasonField = this.inputLabel;
        this.modalType = 'reject';
                    
    }

    handlePendency(event){   
        this.sendProgressEvent('pendency');
        this.openModalReason = true;
        this.modalReasonField = this.inputLabel;
        this.modalType = 'pendency';
    }

    sendProgressEvent(typeOfVariant){
        const clickEvent = new CustomEvent('changeprogress', { detail: { section: this.inputSection, variant: typeOfVariant, position: this.input.id } } );
        this.dispatchEvent(clickEvent);
    }

    handleCloseModalReason(event){
        this.openModalReason = false;
    }

}