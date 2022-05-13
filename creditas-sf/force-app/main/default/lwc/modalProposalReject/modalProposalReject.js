import { LightningElement } from 'lwc';

export default class ModalProposalReject extends LightningElement {

    modalHeader = 'Rejeição da proposta';
    modalBody = 'Deseja mesmo rejeitar esta proposta?';
    modalBodyReturn = 'Volte a tela de análise e faça uma revisão das rejeições.';
    contentConfirmation = true;
    contentSave = false;
    contentReturn = false;
    

    handlerAgree(){
        this.contentConfirmation = false;
        this.contentReturn = false;  
        this.contentSave = true;
        this.handlerReject();
    }

    handlerDisagrees(){
        this.contentConfirmation = false;
        this.contentSave = false;
        this.contentReturn = true;    
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

    handlerReject(event) {
        const selectedEvent = new CustomEvent('reject', {
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
    
}