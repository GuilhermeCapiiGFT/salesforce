import { LightningElement,api } from 'lwc';
 
export default class FormalizationAnalysisField extends LightningElement {
    @api input
    inputType;
    inputLabel;
    inputName;
    inputSection;
    inputDisabled;
    inputValue;
    isReject = false;
    isPendency = false;

    connectedCallback(){
        this.inputName = this.input.inputName;
        this.inputType = this.input.inputType;
        this.inputLabel = this.input.inputLabel;
        this.inputDisabled = this.input.inputDisabled;
        this.inputValue = this.input.inputValue;
        this.inputSection = this.input.inputSection;

    }
    handleApprove(event){
        this.isReject = false;
        this.isPendency = false;
        this.sendProgressEvent('approve');

    }

    handleReject(event){
        this.isReject = true;
        this.isPendency = false;
        this.sendProgressEvent('reject');
        
    }

    handlePendency(event){
        this.isPendency = true;
        this.isReject = false;
        this.sendProgressEvent('pendency');
    }

    sendProgressEvent(typeOfVariant){
        const clickEvent = new CustomEvent('changeprogress', { detail: { section: this.inputSection, variant: typeOfVariant, position: this.input.id } } );
        this.dispatchEvent(clickEvent);
    }

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}