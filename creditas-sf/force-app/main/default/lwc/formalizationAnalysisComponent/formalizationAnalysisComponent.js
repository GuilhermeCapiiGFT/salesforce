import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class FormalizationAnalysis extends LightningElement {

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

    handleChange(event){
        this.valor = event.detail.value;
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