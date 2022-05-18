import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getMapPickList from '@salesforce/apex/FormalizationAnalysisController.getMapPickList';
import updateOpportunityCommitee from '@salesforce/apex/ModalProposalCommitteeController.updateOpportunityCommittee';
import getMyOpportunitiesListView from '@salesforce/apex/ModalProposalCommitteeController.getMyOpportunitiesListView';
import OWNER_NAME_FIELD from '@salesforce/schema/Account.Owner.Name';

const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT = 'error';

const WARNING_OCCURED = 'Aviso!';
const WARNING_MESSAGE = 'Por favor selecione pelo menos 1 motivo para prosseguir.';
const WARNING_VARIANT = 'warning';

const SUCCESS_OCCURRED = 'Sucesso';
const SUCCESS_MESSAGE = 'Oportunidade enviada para comitê';
const SUCCESS_VARIANT = 'success';

export default class ModalProposalCommittee extends NavigationMixin(LightningElement) {
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
      getMapPickList({objApiName: 'Opportunity', fieldApiName: 'CommitteeReason__c'}).then( result => {
        this.picklistValues = JSON.parse(result);
      }).catch(error => {
          this.showToast(ERROR_OCCURRED,ERROR_MESSAGE,ERROR_VARIANT);
      }).finally( () => {
        this.loadingPicklist = false;
      })
      
      getMyOpportunitiesListView().then( result => {
        this.myOppsListViewId = result;
      }).catch(error => {
        this.showToast(ERROR_OCCURRED,ERROR_MESSAGE,ERROR_VARIANT);
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
        if(this.selected === undefined || this.selected.length === 0) {
          this.showToast(WARNING_OCCURED,WARNING_MESSAGE,WARNING_VARIANT);
        } else if(valid){
          let opp = {
            Id: this.recordId,
            CommiteeReason__c: this.selected,
            CommiteeOtherReason__c: this.otherReason,
            CommiteeObservation__c: this.observation,
            Owner_Task_Anterior__c: OWNER_NAME_FIELD,
           
            StageName: 'Aguardando Distribuição para Comitê de Formalização'
          };
  
          
          let updateOpp = updateOpportunityCommitee({newOpp: opp})
          if(updateOpp){
            this.showToast(SUCCESS_OCCURRED,SUCCESS_MESSAGE,SUCCESS_VARIANT);
            this.closeModal();
            this.navigateToListView();
          } else {
            this.showToast(ERROR_OCCURRED,'Ocorreu um erro inesperado, tente novamente mais tarde',ERROR_VARIANT);
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