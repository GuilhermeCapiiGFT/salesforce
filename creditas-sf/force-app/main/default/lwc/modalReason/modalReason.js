import { api, LightningElement } from 'lwc';

export default class ModalReason extends LightningElement {

    saveDisabled = true;
    optionsReason = [];
    optionsSubReason = [];
    mapRelatedReasons = new Map();
    openSubReason = false;
    listValuesReason = [];
    openNote = false;

    @api modalHeader;
    @api field;

    connectedCallback(){
        this.mapRelatedReasons.set('Motivo 1', ['SubMotivo 1.1','SubMotivo 1.2','SubMotivo 1.3','SubMotivo 1.4']);
        this.mapRelatedReasons.set('Motivo 2', ['SubMotivo 2.1','SubMotivo 2.2','SubMotivo 2.3','SubMotivo 2.4']);
        this.mapRelatedReasons.set('Motivo 3', ['SubMotivo 3.1','SubMotivo 3.2','SubMotivo 3.3','SubMotivo 3.4']);
        this.mapRelatedReasons.set('Motivo 4', ['SubMotivo 4.1','SubMotivo 4.2','SubMotivo 4.3','SubMotivo 4.4']);
        this.mapRelatedReasons.set('Outros', []);

        let mapReason = [... this.mapRelatedReasons.keys()];
        this.optionsReason = mapReason.map((item) => Object.assign({}, {label: item, value: item}));
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
        if(e.target.value != 'Outros'){
            let mapSubReason = [... this.mapRelatedReasons.get(e.target.value)];
            this.optionsSubReason = mapSubReason.map((item) => Object.assign({}, {label: item, value: item}));
            this.openSubReason = true;
            this.saveDisabled = true;
            this.openNote = false;
        }else{
            this.openNote = true;
            this.openSubReason = false;
            this.saveDisabled = false;
        }
    }

    handlerSelectSubReason(e){
        this.saveDisabled = false;
    }

    handlerSave(){
        let objResultReason = {};
        this.template.querySelectorAll(".form-reason").forEach(elem => {
            objResultReason[elem.name] = (elem.value) ? elem.value : '';
        });
        objResultReason.field = this.field;
        console.log(objResultReason);
        this.handlerClose();
    }
}