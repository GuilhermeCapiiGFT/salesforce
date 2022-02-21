import { LightningElement, api, wire } from 'lwc';

export default class FormalizationAnalysisField extends LightningElement {
    @api input
    inputType;
    inputLabel;
    inputName;
    inputSection;
    inputDisabled;
    inputValue;
    dateStyle = '';
    //Events Variables
    openModalReason = false;
    modalReasonField;
    modalType;

    connectedCallback(){
        console.dir(input);
        this.inputName = this.input.inputName;
        this.inputType = this.input.inputType;
        this.inputLabel = this.input.inputLabel;
        this.inputDisabled = this.input.inputDisabled;
        this.inputValue = this.input.inputValue;
        this.inputSection = this.input.inputSection;       
    }
    
    renderedCallback(){
        this.configureFields();
    }

    configureFields(){
        if(this.inputType === 'Date' || this.inputType === "DateTime"){
            this.dateStyle = 'short';
        }
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