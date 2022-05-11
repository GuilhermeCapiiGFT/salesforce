import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMapPickList from '@salesforce/apex/FormalizationAnalysisController.getMapPickList';

export default class ModalProposalComite extends LightningElement {

    modalHeader = 'Deseja enviar ao Comitê';
    showDescription = false;
    selected;
    otherReason;
    picklistValues;
    
    connectedCallback(){
      getMapPickList({objApiName: 'Opportunity', fieldApiName: 'CommiteeReason__c'}).then( result => {
        this.picklistValues = JSON.parse(result);
    }).catch(error => {
        console.log(JSON.stringify(error));
    }).finally( () => {
        
    })
    }
    /*
    options = [
        { value: 'PROOF_OF_ADDRESS_FRAUD', label: 'Possivel fraude do comprovante de residência' },
        { value: 'CONSIGNATION_DOCUMENT', label: 'Documentação de Consignação' },
        { value: 'INCOME_DIVERGENCY', label: 'Divergência de Renda' },
        { value: 'FRAUDSTER', label: 'Possível Fraudador' },
        { value: 'DOCUMENT_ADULTERATION', label: 'Suspeita de adulteração de documento' },
        { value: 'BIOMETRY_PENDING', label: 'Biometria pendente' },
        { value: 'OTHER', label: 'Outros' }
    ];
    */
    get options(){
      return this.picklistValues;
    }

    handleChange(event){
        //let selectedOptionsList = event.detail.value;
        //let selectArray = Array.from(selectedOptionsList);
        if(event.detail.value.includes('OTHER')){
            this.showDescription = true;
        } else {
            this.showDescription = false;
        }
        this.selected = event.detail.value.join(';');
    }

    handleCloseModal() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }
    handleSendCommitee(event){
        let valid = this.checkRequiredFields();
        console.log(valid);
    }

    genericOnChange(event) {
      this[event.target.name] = event.target.value;
    }

    checkRequiredFields() {
        const isInputsCorrect = [
          ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
        const isDualListBoxCorrect = [
          ...this.template.querySelectorAll("lightning-dual-listbox")
        ].reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
        return isInputsCorrect && isDualListBoxCorrect;
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