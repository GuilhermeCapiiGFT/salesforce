import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalProposalComite extends LightningElement {

    modalHeader = 'Deseja enviar ao Comitê';
    modalBody = 'A proposta será enviada para análise do Comitê';
    
    contentConfirmation = true;
    
    handlerAgree() {
      this.contentConfirmation = false;
      this.handleClose()
    }

    handlerDisagrees() {
        this.contentConfirmation = false;
        this.handleClose()
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

    handleSave() {
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