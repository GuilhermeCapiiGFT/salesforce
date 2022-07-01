import { api, LightningElement, wire, track } from 'lwc';
import getReasonValues from '@salesforce/apex/ProposalController.getReason'

const OTHER_REASON = 'OTHER';
const REJECTED_REASON = 'rejected';
export default class ModalReason extends LightningElement {

    saveDisabled = true;
    optionsReason = [];
    openNote = false;
    recordTypeIdObject;
    reason;
    description;
    actualReason;
    _checkedField;
    loadingPicklist = true;
    @api uniqueName;
    @api fieldReason;
    @api objectReason;
    @api typeReason;
    @api mapReason;
    @track open = false;
    @api internalControl = false;
    @api modalHeader;

    @api
    get checkedField() {
        return this._checkedField;
    }
    set checkedField( value ) {

        if ( value == null ) {
            this.reason = '';
            this.description = '';
            this._checkedField = null;
            return;
        }

        this.reason = ( value.value.toLowerCase() == REJECTED_REASON ) ? value?.rejectValue : value?.pendingValue;
        this.isOtherSelected(this.reason);
        this.description = value?.observationValue;
        this._checkedField = value;
    }

    @api
    setModalHeader(header) {
        this.modalHeader = header;
    }
    @api
    openModal(){
        this.open = true;
        this.getReasonOptions();
    }
    @api
    closeModal(){
        this.open = false;
    }
    connectedCallback(){
        this.modalHeader = this.typeReason && this.typeReason.toLowerCase() == 'reject' ? 'Motivo da reprovação' : 'Motivo do pendenciamento';
        if(!this.internalControl){
            this.open = true;
        }
        this.getReasonOptions();
    }
    get fieldCBReason(){
        console.dir(this.mapReason.get(`${this.typeReason}${this.fieldReason}`));
        //this.mapReason.get(`${this.typeReason}${this.fieldReason}`) === undefined ? '' : this.mapReasons.get(`${this.typeReason}${this.fieldReason}`)?.reason;
        return '';
    }

    get fieldDescription(){
        return this.mapReason.get(`${this.typeReason}${this.fieldReason}`) === undefined ? '' : this.mapReasons.get(`${this.typeReason}${this.fieldReason}`).description;
    }
    getReasonOptions = () =>{
        const request = {objectReason: this.objectReason, fieldReason: this.fieldReason};
        getReasonValues(request)
        .then(result =>{
            if(result){
                this.optionsReason = JSON.parse(result);
                this.loadingPicklist = false;
            }
        })
        .catch(error =>{
        })
    }
    handleClose(){
        if(this.internalControl){
            this.open = false;
        }
        this.loadingPicklist = true;
        this.clear();
    }
    handlerSelectReason(e){
        if ( e == null ) return;
        this.isOtherSelected(e.target.value);
    }

    isOtherSelected(value) {

        if ( value == null ) return;
        if ( value.toUpperCase() != OTHER_REASON) {
            this.saveDisabled = false;
            this.openNote = false;
        } else{
            this.openNote = true;
            this.saveDisabled = true;
        }
    }

    handlerChangeNote(e){
        this.saveDisabled = !this.validateInput('lightning-textarea');
    }

    handlerSave(event){
        
        let btnAction = event.target.getAttribute('data-action');
        let objResultReason = {};
        
        if(btnAction === 'close'){
            objResultReason.reason = null;
            if(this.checkedField){
                const evt = new CustomEvent('cancel', {
                    detail: {
                        ...this.checkedField,
                        typeReason : this.typeReason,
                        fieldReason : this.fieldReason,
                        objectReason: this.objectReason
                    }
                });
                this.dispatchEvent(evt);
                this.handleClose();
                return;
            }
        }else{
            this.template.querySelectorAll(".form-reason").forEach(elem => {

                objResultReason[elem.name] = (elem.value) ? elem.value : null;
                this[elem.name] = (elem.value) ? elem.value : null;
            });
        }

        objResultReason.field = this.fieldReason;
        objResultReason.type = this.typeReason;
        objResultReason.object = this.objectReason;
        objResultReason.originField = this.checkedField;
        this.selectedReason(objResultReason);
        this.handleClose();
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
    clear(){
        this.openNote = false;
        this.saveDisabled = true;
    }
}