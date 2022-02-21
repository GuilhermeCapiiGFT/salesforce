import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalProposalApprove extends LightningElement {

    modalHeader = 'Deseja aprovar a proposta?';
    modalBody = 'Ao aprovar a proposta não será possível editar os campos.';
    contentConfirmation = true;
  
    handlerAgree() {
      this.contentConfirmation = false;
      this.handlerApprove()
      this.handlerClose();
      this.showToast('Sucesso', 'Análise Concluída com sucesso!', 'success')
    }

    handlerDisagrees() {
        this.contentConfirmation = false;
        this.handlerClose();
    }
    
    handlerApprove(event) {
      const selectedEvent = new CustomEvent('approve', {
        bubbles    : true,
        composed   : true,
        cancelable : true,
        detail: {}
      });
      this.dispatchEvent(selectedEvent);
    }
    
    handlerClose() {
      const selectedEvent = new CustomEvent('closemodal', {
          bubbles    : true,
          composed   : true,
          cancelable : true,
          detail: {}
      });
      this.dispatchEvent(selectedEvent);
    }

    handlerSave() {
        this.handlerClose();
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