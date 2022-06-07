import { api, LightningElement, wire } from 'lwc';
import getReasonValues from '@salesforce/apex/ProposalController.getReason'

const OTHER_REASON = 'OUTROS';
export default class ModalReason extends LightningElement {

    saveDisabled = true;
    optionsReason = [];
    openNote = false;
    recordTypeIdObject;

    @api fieldReason;
    @api objectReason;
    @api typeReason;
    @api mapReason;

    get modalHeader(){
        return this.typeReason == 'reject' ? 'Motivo da reprovação' : 'Motivo do pendenciamento';
    }

    connectedCallback(){
        getReasonValues({objectReason: this.objectReason, fieldReason: this.fieldReason})
        .then(result =>{
            if(result){
                this.optionsReason = JSON.parse(result);
            }
        })
        .catch(error =>{
            console.log(error);
        })
    }

    get fieldCBReason(){
        console.dir(this.mapReason.get(`${this.typeReason}${this.fieldReason}`));
        //this.mapReason.get(`${this.typeReason}${this.fieldReason}`) === undefined ? '' : this.mapReasons.get(`${this.typeReason}${this.fieldReason}`)?.reason;
        return '';
    }

    get fieldDescription(){
        return this.mapReason.get(`${this.typeReason}${this.fieldReason}`) === undefined ? '' : this.mapReasons.get(`${this.typeReason}${this.fieldReason}`).description;
    }

    handlerSelectReason(e){
        if(e.target.value.toUpperCase() != OTHER_REASON){
            this.saveDisabled = false;
            this.openNote = false;
        }else{
            this.openNote = true;
            this.saveDisabled = true;
        }
    }

    handlerChangeNote(e){
        this.saveDisabled = this.validateInput('lightning-textarea');
    }

    handlerSave(event){
        let btnAction = event.target.getAttribute('data-action');
        let objResultReason = {};
        
        if(btnAction === 'close'){
            objResultReason.reason = null;
        }else{
            this.template.querySelectorAll(".form-reason").forEach(elem => {
                objResultReason[elem.name] = (elem.value) ? elem.value : null;
            });
        }

            objResultReason.field = this.fieldReason;
            objResultReason.type = this.typeReason;
            objResultReason.object = this.objectReason;
            let reasonMap = this.mapReason.get(`${this.typeReason}${this.fieldReason}`) === undefined ? new map() : this.mapReason.get(`${this.typeReason}${this.fieldReason}`);
            reasonMap.set(`${this.typeReason}${this.fieldReason}`, {reason: objResultReason.reason, description: objResultReason.description});
            objResultReason.mapReason = reasonMap;
    
            console.log({objResultReason})
            this.selectedReason(objResultReason);
        

        
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