import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMapPickList from '@salesforce/apex/FormalizationAnalysisController.getMapPickList';

export default class ModalProposalComite extends LightningElement {
    @api recordId
    modalHeader = 'Deseja enviar ao Comitê';
    showDescription = false;
    selected;
    otherReason;
    observation;
    picklistValues;
    loadingPicklist = true;
    
    connectedCallback(){
      getMapPickList({objApiName: 'Opportunity', fieldApiName: 'CommiteeReason__c'}).then( result => {
        this.picklistValues = JSON.parse(result);
    }).catch(error => {
        console.log(JSON.stringify(error));
    }).finally( () => {
      this.loadingPicklist = false;
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
        if(event.detail.value.includes('OTHER')){
            this.showDescription = true;
        } else {
            this.showDescription = false;
        }
        this.selected = event.detail.value.join(';');
    }

    handleCloseModal(event) {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    handleSendCommitee(event){
        //let valid = this.checkRequiredFields();
        //console.log(valid);
        console.log(this.selected);
        if(this.selected === undefined || this.selected.size() === 0) {
          this.showToast('Aviso','Por favor selecione pelo menos 1 motivo para prosseguir.','warning');
        }
        let opp = {
          Id: recordId,
          CommiteeReason__c: this.selected,
          CommiteeOtherReason__c: this.otherReason,
          CommiteeObservation__c: this.observation,
          StageName: 'Aguardando Análise de Comitê'
        };

        console.dir(opp);
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