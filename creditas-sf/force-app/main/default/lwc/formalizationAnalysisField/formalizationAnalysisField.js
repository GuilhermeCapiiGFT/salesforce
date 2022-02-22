import { LightningElement, api, wire } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ACCOUNT_RECORD from '@salesforce/schema/Account';

export default class FormalizationAnalysisField extends LightningElement {
    @api input
    @api accountRecordTypeId = undefined;
    inputType;
    inputLabel;
    inputName;
    inputSection;
    inputDisabled;
    inputValue;
    dateStyle = '';
    //Events Variables
    openModalReason = false;
    modalReasonField;
    modalType;
    //TestTree
    treeModel;
    error;
    picklistMap;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: ACCOUNT_RECORD,
        recordTypeId: '$accountRecordTypeId'
    })
    wiredValues({ error, data }) {
        
        if (data) {
            this.treeModel = this.buildTreeModel(data.picklistFieldValues);
            console.dir(this.treeModel);
            this.error = undefined;
        } else {
            this.error = error;
            this.treeModel = undefined;
        }
    }

    buildTreeModel(picklistValues) {
        const treeNodes = [];
        let picklistMap = new Map();
        Object.keys(picklistValues).forEach((picklist) => {
            treeNodes.push({
                label: picklist,
                items: picklistValues[picklist].values.map((item) => ({
                    label: item.label,
                    name: item.value
                }))
            });
            picklistMap.set(picklist, picklistValues[picklist].values.map((item) => ({
                label: item.label,
                name: item.value
            })))
        });
        this.picklistMap = picklistMap;
        console.dir(this.picklistMap);
        return treeNodes;
    }

    connectedCallback(){
        this.inputName = this.input.inputName;
        this.inputType = this.input.inputType;
        this.inputLabel = this.input.inputLabel;
        this.inputDisabled = this.input.inputDisabled;
        this.inputValue = this.input.inputValue;
        this.inputSection = this.input.inputSection;       
    }
    
    renderedCallback(){
        this.configureFields();
    }

    configureFields(){
        if(this.inputType === 'Date' || this.inputType === "DateTime"){
            this.dateStyle = 'short';
        }
    }

    handleCheckboxChange(event){
   
        this.template.querySelectorAll('.isCheckBox').forEach(elem => {
            elem.checked = false;
        });
        
        event.target.checked = true;
    }
    
    handleApprove(event){
        this.sendProgressEvent('approve');
        
    }

    handleReject(event){
        this.sendProgressEvent('reject');
        this.openModalReason = true;
        this.modalReasonField = this.inputLabel;
        this.modalType = 'reject';
                    
    }

    handlePendency(event){   
        this.sendProgressEvent('pendency');
        this.openModalReason = true;
        this.modalReasonField = this.inputLabel;
        this.modalType = 'pendency';
    }

    sendProgressEvent(typeOfVariant){
        const clickEvent = new CustomEvent('changeprogress', { detail: { section: this.inputSection, variant: typeOfVariant, position: this.input.id } } );
        this.dispatchEvent(clickEvent);
    }

    handleCloseModalReason(event){
        this.openModalReason = false;
    }

}