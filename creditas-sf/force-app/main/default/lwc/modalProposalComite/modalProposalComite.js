import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getMapPickList from '@salesforce/apex/FormalizationAnalysisController.getMapPickList';
import updateOpportunityCommitee from '@salesforce/apex/ModalProposalComiteController.updateOpportunityCommitee';
import getMyOpportunitiesListView from '@salesforce/apex/ModalProposalComiteController.getMyOpportunitiesListView';

export default class ModalProposalComite extends NavigationMixin(LightningElement) {
    @api recordId;
    modalHeader = 'Deseja enviar ao Comitê';
    showDescription = false;
    selected;
    otherReason;
    observation;
    picklistValues;
    loadingPicklist = true;
    myOppsListViewId;
    
    connectedCallback(){
      getMapPickList({objApiName: 'Opportunity', fieldApiName: 'CommiteeReason__c'}).then( result => {
        this.picklistValues = JSON.parse(result);
      }).catch(error => {
          //console.log(JSON.stringify(error));
      }).finally( () => {
        //this.loadingPicklist = false;
      })
      
      getMyOpportunitiesListView().then( result => {
        this.myOppsListViewId = result;
      }).catch(error => {
        
      });
    }
 
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
        this.closeModal();
    }

    closeModal(){
      const closeEvent = new CustomEvent('closemodal');
      this.dispatchEvent(closeEvent);
    }

    handleSendCommitee(event){
        let valid = this.checkRequiredFields();
        console.log(valid);
        console.log(this.selected);
        if(this.selected === undefined || this.selected.length === 0) {
          this.showToast('Aviso','Por favor selecione pelo menos 1 motivo para prosseguir.','warning');
        } else if(valid){
          let opp = {
            Id: this.recordId,
            CommiteeReason__c: this.selected,
            CommiteeOtherReason__c: this.otherReason,
            CommiteeObservation__c: this.observation,
            StageName: 'Aguardando Distribuição para Comitê de Formalização'
          };
  
          
          let updateOpp = updateOpportunityCommitee({newOpp: opp})
          if(updateOpp){
            this.showToast('Sucesso','Oportunidade enviada para comitê','success');
            this.closeModal();
            this.navigateToListView();
          } else {
            this.showToast('Error','Ocorreu um erro inesperado, tente novamente mais tarde','error');
          }
        }
    }

    navigateToListView() {
      this[NavigationMixin.Navigate]({
          type: 'standard__objectPage',
          attributes: {
              objectApiName: 'Opportunity',
              actionName: 'list'
          },
          state: {
              filterName: this.myOppsListViewId
          }
      });
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
        const isTextAreaCorrect = [
          ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
        return isInputsCorrect && isDualListBoxCorrect && isTextAreaCorrect;
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