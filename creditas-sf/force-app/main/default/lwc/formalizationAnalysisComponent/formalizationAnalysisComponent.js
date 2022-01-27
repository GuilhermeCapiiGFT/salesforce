import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityInfo from '@salesforce/apex/formalizationAnalysisController.getOpportunnityInfo';

 
export default class FormalizationAnalysis extends LightningElement {
    @api recordId;
    opportunity;
    error;
    value = '';
    valor;
    isPendenciar = false;

    get options() {
        return [
            { label: 'Aprovar', value: 'aprovar' },
            { label: 'Rejeitar', value: 'rejeitar' },
            { label: 'Pendenciar', value: 'pendenciar' },
        ];
    }
    items = [ {id: 1, name: "Joao",label: "Nome do Pai",showField: false}, {id:2, name: "Maria",label: "Nome da Mãe",showField: false}, {id: 3, name: "111.222.333-44", label: "CPF",showField: false}, {id:4, name: "33.452.132-12",label: "RG",showField: false}];

    @wire (getOpportunityInfo, {aOpportunityId : '$recordId'} )
    opportunity({error,data}){
        if(data){
            this.opportunity = data;
            this.error = undefined
        } else if (error){
            this.opportunity = undefined;
            this.error = error;
        }
    }

    handleChange(event){
        this.valor = event.detail.value;
        console.dir(event.detail);
        this.isPendenciar = event.detail.value === 'pendenciar' ? true : false;
        if(event.detail.value === 'rejeitar'){
            this.showToast('Aviso!','Ao rejeitar o campo a proposta toda será rejeitada!','warning');
          }
    }

    showToast(title, message, variant){
        const event = new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    
}