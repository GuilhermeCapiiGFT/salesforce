import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getMapPickList from '@salesforce/apex/FormalizationAnalysisController.getMapPickList';
import updateOpportunityCommittee from '@salesforce/apex/ModalProposalCommitteeController.updateOpportunityCommittee';
import getMyOpportunitiesListView from '@salesforce/apex/ModalProposalCommitteeController.getMyOpportunitiesListView';

const ERROR_OCCURRED = 'Ocorreu um Erro';
const ERROR_MESSAGE = 'Por favor entre em contato com um administrador.';
const ERROR_VARIANT = 'error';
const ERROR_UPDATE = 'Ocorreu um erro inesperado, verifique os valores digitados';

const WARNING_OCCURED = 'Aviso!';
const WARNING_MESSAGE = 'Por favor selecione pelo menos 1 motivo para prosseguir.';
const WARNING_VARIANT = 'warning';

const SUCCESS_OCCURRED = 'Sucesso';
const SUCCESS_MESSAGE = 'Oportunidade enviada para comitê';
const SUCCESS_VARIANT = 'success';

const TEXT_FIELD_WARNING = 'Por favor, verifique o campo digitado.';
const TEXT_FIELD_MESSAGE = 'O número de caractéres não pode ultrapassar';

const OPP_STAGENAME = 'Aguardando Distribuição para Comitê de Formalização';

export default class ModalProposalCommittee extends NavigationMixin(LightningElement) {
    @api recordId;
    @api lastAnalysId;
    modalHeader = 'Deseja enviar ao Comitê';
    showDescription = false;
    selected;
    otherReason;
    observation;
    picklistValues;
    loadingPicklist = true;
    myOppsListViewId;

    otherReasonMaxLength = 100;
    observationMaxLength = 2000;
    
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

    handleSendCommittee(event){
        let valid = this.checkRequiredFields();
        if(this.selected === undefined || this.selected.length === 0) {
          this.showToast(WARNING_OCCURED,WARNING_MESSAGE,WARNING_VARIANT);
        } else if(valid){
          let opp = {
            Id: this.recordId,
            CommitteeReason__c: this.selected,
            CommitteeOtherReason__c: this.otherReason,
            CommitteeObservation__c: this.observation,
            LastAnalyst__c: this.lastAnalysId,
            StageName: OPP_STAGENAME
          };

          updateOpportunityCommittee({newOpp: opp}).then( result => {
            if(result){
              this.showToast(SUCCESS_OCCURRED,SUCCESS_MESSAGE,SUCCESS_VARIANT);
              this.closeModal();
              this.navigateToListView();
            } else {
              this.showToast(ERROR_OCCURRED,ERROR_UPDATE,ERROR_VARIANT);
            }
          }).catch(error =>{
            console.log(JSON.stringify(error));
          });
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

    otherReasonBlur(event){
      this.queryAndSetValidity("lightning-input[data-id='otherReason']",event);
    }

    observationBlur(event){
      this.queryAndSetValidity("lightning-textarea[data-id='observation']",event);
    }

    queryAndSetValidity(fieldDataId, event){
      let queryField = this.template.querySelector(fieldDataId);
      let fieldMaxLength = this[`${event.target.name}MaxLength`];
      if(event.target.value.length > fieldMaxLength){
        queryField.setCustomValidity(`${TEXT_FIELD_MESSAGE} ${fieldMaxLength} caractéres.`);
        this.showToast(WARNING_OCCURED,TEXT_FIELD_WARNING,WARNING_VARIANT);
      } else {
        queryField.setCustomValidity('');
      }

    }

    checkRequiredFields() {
        const isInputsCorrect = this.validateInput("lightning-input");
        const isDualListBoxCorrect = this.validateInput("lightning-dual-listbox");
        const isTextAreaCorrect = this.validateInput("lightning-textarea");
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

    validateInput(queryName){
      const allValid = [
      ...this.template.querySelectorAll(queryName)
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    return allValid;
    }
}