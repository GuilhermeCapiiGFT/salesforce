import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class ProposalFieldSection extends LightningElement {
    
    APPROVE = 'APPROVED';
    DATETIME = 'DateTime';
    LIST_TYPES = ['Picklist', 'CheckBox'];
    PENDING = 'PENDING';
    PICKLIST = 'Picklist';
    TEXTAREA = 'TextArea';
    REJECT = 'REJECTED';
    RETURNED_PENDING = 'RETURNED_PENDING';

    @track cloneField = {};
    @track hasApprovalPermission;
    @track hasPendingPermission;
    @track hasRejectPermission;
    @track dataType = {
        Text : true
    }
    @track fieldMetaValue = '';
    @track fieldUniqueName;
    @track options = [{
        label : '',
        value : ''
    }];
    @track pendingChecboxId;
    @track novalidation;
    @track recTypeId;
    @track
    status = {};
    @track rejectCheckboxId;
    @track recordTypeId;

    firstLoad = true;
    returnedFromPending = false;
    settingField = false;

    @api
    get fieldValue(){
        return this.fieldMetaValue;
    }
    set fieldValue(data){

        console.log('setting fieldValue for: ' + this.fieldUniqueName);
        data = data != undefined ? data : '';
        this.fieldMetaValue = data;

        if(this.settingField){
            this.notifyChange('load', {
                ...this.cloneField,
                loaded : this.fieldUniqueName

            });

        }else{
            this.notifyChange('inputchange', {
                ...this.cloneField,
                value : data,
                fieldValue : this.fieldValue
            });
        }

        
    }
    @api
    observationValue;
    @api
    pendingValue;
    @api
    rejectValue;
    @api
    get statusValue(){
        return this.status;
    }
    set statusValue(value){
        switch(value) {
            case this.APPROVE:
                this.status = {approved: true};
                break;
            case this.PENDING:
                this.status = {pending: true};
                break;
            case this.REJECT:
                this.status = {rejected: true};
                break;
            case this.RETURNED_PENDING:
                this.returnedFromPending = true;
        }
        if(this.settingField){
            this.notifyChange('load',{
                ...this.cloneField,
                fieldValue : this.fieldValue,
                value: value
            });
        }else{
            this.notifyChange('fieldvalidation',{
                ...this.cloneField,
                fieldValue : this.fieldValue,
                value: value
            });
        }
        
    }
    @api
    get disabled(){
        return this.novalidation;
    }
    set disabled(value){
        this.novalidation = value;
    }

    @api
    get field() {
        return this.clonefield;
    }
    set field(value){

        this.settingField = true;

        this.cloneField = Object.assign({}, value);
        //setting field API Name with Object {sobjectName}.{sobjectFieldName}
        if(!this.fieldUniqueName){
            this.fieldUniqueName = value.uniqueName;
        }
        //setting visual permissions to field
        this.hasApprovalPermission = !(value.actions.includes('APPROVE'));
        this.hasPendingPermission = !(value.actions.includes('PENDING'));
        this.hasRejectPermission = !(value.actions.includes('REJECT'));
        this.hasEditPermission =  !(value.editable && value.updateable);
        this.cloneField.actions = this.cloneField.actions || [];
        this.novalidation = (this.cloneField.actions.includes('READONLY')) || (this.cloneField.actions.includes('NO_VALIDATION')) || !value.actions.length;
        //setting checkbox id
        this.approvalCheckboxId = 'approve_'+ value.uniqueName;
        this.pendingChecboxId = 'pending_'+ value.uniqueName;
        this.rejectCheckboxId = 'reject_'+ value.uniqueName;
        
        //setting input text id
        this.fieldId = 'field_' + value.uniqueName;

        // setting data type
        if ( this.LIST_TYPES.includes(value.dataType) ){
            this.dataType = { Picklist : true };
        }
        if(value.dataType == this.TEXTAREA){
            this.dataType = {};
            this.dataType[this.TEXTAREA] = true;
        }
        if(value.dataType == this.DATETIME){
            this.dataType = {};
            this.dataType[this.DATETIME] = true;
        }
        if(value.dataType == this.PICKLIST && !this.recTypeId){
            this.recTypeId = value.recordTypeId;
        }

        if(value.fieldValue){
            console.log('component has fieldValue')
            this.fieldValue = value.fieldValue; 
        }else{
            console.log('component does not have fieldValue');
            console.log(JSON.parse(JSON.stringify(value)));
        }
        if(value.statusValue){
            this.statusValue = value.statusValue;
        }
        if(value.pendingValue){
            this.pendingValue = value.pendingValue;
        }
        if(value.rejectValue){
            this.rejectValue = value.rejectValue;
        }
        if(value.observationValue){
            this.observationValue = value.observationValue;
        }
        this.settingField = false;
    }
    handleInputChange(event) {
        event.preventDefault();
        const input = event.target;
        this.fieldValue = input.value;
    }
    handleInputFocus = (event) => {
        this.notifyChange('inputfocus',{
            ...this.cloneField,
            value: this.value,
            fieldValue: this.fieldValue
        });
    }
    handleInputBlur = (event) => {
        this.notifyChange('inputblur',{
            ...this.cloneField,
            value: this.value,
            fieldValue: this.fieldValue
        });
    }
    handleChange(event) {
        event.stopPropagation();
        const input = event.target;
        const value = input.value;
        this.notifyChange('fieldvalidation', {
            ...this.cloneField,
            value: value,
            fieldValue : this.fieldValue
        });
    }
    notifyChange(event, detail){
        const evt = new CustomEvent(event,{
            detail: detail
        });
        this.dispatchEvent(evt);
    }
    @api
    clear(){
        this.status = {}
    }
    @wire(getPicklistValues, { recordTypeId: '$recTypeId', fieldApiName: '$fieldUniqueName' })
    getPickListValue({error, data}){
        if(data){
            const options = this.options.concat(data.values);
            this.options = options;
        }
    }
}