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
        event.target.classList.add('buttonApproveClicked');
        let hasReject = this.template.querySelector('.buttonRejectIcon');
        console.dir(hasReject);
        if(hasReject){
            hasReject.classList.remove('buttonRejectIcon');
        }
        /*
        setTimeout(() => {
            let approveButton = this.template.querySelector('.buttonApproveRotate');
            //console.dir(approveButton);
            approveButton.classList.remove('buttonApproveRotate');
            approveButton.classList.add('buttonApproveIcon');
        }, 777);
        */
        

    }

    handleReject(event){
        this.isReject = true;
        this.isPendency = false;
        this.sendProgressEvent('reject');
        event.target.classList.add('buttonRejectRotate');
        let hasApprove = this.template.querySelector('.buttonApproveIcon');
        if(hasApprove){
            hasApprove.classList.remove('buttonApproveClicked');
        }

        setTimeout(() => {
            let approveButton = this.template.querySelector('.buttonRejectRotate');
            //console.dir(approveButton);
            approveButton.classList.remove('buttonRejectRotate');
            approveButton.classList.add('buttonRejectIcon');
        }, 777);
        
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