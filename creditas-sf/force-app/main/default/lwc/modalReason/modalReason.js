import { api, LightningElement, wire } from 'lwc';
import getReasonValues from '@salesforce/apex/ProposalController.getReason'


export default class ModalReason extends LightningElement {

    saveDisabled = true;
    optionsReason = [];
    openNote = false;
    recordTypeIdObject;

    @api fieldReason;
    @api objectReason;
    @api typeReason;

    get modalHeader(){
        return this.typeReason == 'reject' ? 'Motivo da reprovação' : 'Motivo do pendenciamento';
    }

    connectedCallback(){
        console.log('Obj Reason: '+this.objectReason);
        console.log('Field Reason: '+this.fieldReason);

        getReasonValues({objectReason: this.objectReason, fieldReason: this.fieldReason})
        .then(result =>{
            if(result){
                this.optionsReason = JSON.parse(result);
            }else{
                console.log('Motivos não encontrados!');
            }
        })
        .catch(error =>{
            console.log(error);
        })
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

    handlerSelectReason(e){
        if(e.target.value.toUpperCase() != 'OUTROS'){
            this.saveDisabled = false;
            this.openNote = false;
        }else{
            this.openNote = true;
            this.saveDisabled = true;
        }
    }

    handlerChangeNote(e){
        this.saveDisabled = (e.target.value != '') ? false : true;
    }

    handlerSave(){
        let objResultReason = {};
        this.template.querySelectorAll(".form-reason").forEach(elem => {
            objResultReason[elem.name] = (elem.value) ? elem.value : null;
        });
        objResultReason.field = this.fieldReason;
        objResultReason.type = this.typeReason;
        objResultReason.object = this.objectReason;
        this.selectedReason(objResultReason);
        this.handlerClose();
    }

    selectedReason(objResult){
        const selectedEvent = new CustomEvent('selectedreason', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: objResult ? objResult : ''
        });
        this.dispatchEvent(selectedEvent);
    }

}