import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalProposalPendency extends LightningElement {

    modalHeader = 'Pendenciar Proposta';
    modalBody = 'Ao pendenciar a proposta não será possível editar os campos';
    
    contentConfirmation = true;
    
    handlerAgree(){
      this.contentConfirmation = false;
      this.handlerPendency()
      this.handlerClose()
    }

    handlerDisagrees(){
        this.contentConfirmation = false;
        this.handlerClose()
    }
  
    handlerPendency(event) {
      const selectedEvent = new CustomEvent('pendency', {
        bubbles    : true,
        composed   : true,
        cancelable : true,
        detail: {}
      });
      this.dispatchEvent(selectedEvent);
    }

    handlerClose(){
        const selectedEvent = new CustomEvent('closemodal', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {}
        });
        this.dispatchEvent(selectedEvent);
    }

    handlerSave(){
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