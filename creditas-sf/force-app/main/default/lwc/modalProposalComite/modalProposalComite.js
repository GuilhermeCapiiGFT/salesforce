import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalProposalComite extends LightningElement {

    modalHeader = 'Deseja enviar ao Comitê';
    modalBody = 'A proposta será enviada para análise do Comitê';
    showDescription = false;
    options = [
        { value: 'Comprovante de Residência', label: 'Comprovante de Residência' },
        { value: 'Documentação de Consignação', label: 'Documentação de Consignação' },
        { value: 'Renda', label: 'Renda' },
        { value: 'Possível Fraudador', label: 'Possível Fraudador' },
        { value: 'Adulteração de Documento', label: 'Adulteração de Documento' },
        { value: 'Biometria Pendente', label: 'Biometria Pendente' },
        { value: 'Outros', label: 'Outros' }
    ];

    handleChange(event){
        const selectedOptionsList = event.detail.value;
        if(selectedOptionsList.contains('Outros')){
            this.showDescription = true;
        } else {
            this.showDescription = false;
        }
        console.dir(selectedOptionsList);
    }

    handleClose() {
        const selectedEvent = new CustomEvent('closemodal', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {}
        });
        this.dispatchEvent(selectedEvent);
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