import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
const TEMPLATE = /(\{\!(\w+)\})/g
const ALLOWED_OPERATIONS = /==|!=|>=|<=|<|>/g
const DISALLOWED_OPERATIONS = /window|document|var|let|const|console|for|while|map|[()]|\.|alert/g
export default class ProposalFieldSection extends LightningElement {
    
    APPROVE = 'APPROVED';
    BOOLEAN = 'Boolean';
    DATETIME = 'DateTime';
    DATE = 'Date';
    LIST_TYPES = ['Picklist', 'CheckBox', 'Boolean'];
    PENDING = 'PENDING';
    PICKLIST = 'Picklist';
    TEXTAREA = 'TextArea';
    REJECT = 'REJECTED';
    RETURNED_PENDING = 'RETURNED_PENDING';
    renderCount = 1;
    
    @track cloneField = {};
    @track daysBetweenNow = 0;
    @track hoursBetweenNow = 0;
    @track monthsBetweenNow = 0;
    @track yearsBetweenNow = 0;
    @track hasApprovalPermission;
    @track hasPendingPermission;
    @track hasRejectPermission;
    @track helpText1;
    @track helpText2;
    @track helpText2Conditions;
    @track helpText2Style;
    @track hidden;
    @track dataType = {
        Text : true
    }
    @track fieldMetaValue = "";
    @track options = [{
        label : '',
        value : ''
    }];
    @track pendingChecboxId;
    @track novalidation;
    @track status = {};
    @track rejectCheckboxId;
    @track recordTypeId;
    @track timeRange;
    
    firstLoad = true;
    returnedFromPending = false;
    settingField = false;
    initialHelpText2 = '';

    @api fieldUniqueName;
    @api customHelpText1;
    @api recTypeId;

    @api
    get fieldValue(){
        return this.fieldMetaValue;
    }
    set fieldValue(data){

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
    get fieldHelpText1(){
        return this.customHelpText1 || this.helpText1; 
    }
    @api 
    get fieldHelpText2(){
        return this.helpText2;
    }
    set fieldHelpText2(data) {
        const match = data.match(TEMPLATE);
        if ( !match ) return;
        let tempHelpText = data;
        match.forEach((current) =>{
            const variable = current.replace(/[!{}]/g,'');
            tempHelpText = data.replace(current, this[variable]);
        })
        this.helpText2 = tempHelpText;
        if(this.helpText2Conditions){
            let script = '';
            let style = '';
            for(let [key, value] of Object.entries(this.helpText2Conditions)){
                let tempScript = value.expr
                const match = tempScript.match(TEMPLATE);
                match.forEach((current) =>{
                    const variable = current.replace(/[!{}]/g,'');
                    if(this[variable]){
                        script = tempScript.replaceAll(current, this[variable]);
                        style = value.style;
                    }
                });
                if(script){
                    let scriptResult = eval(script);
                    if(scriptResult){
                        this.helpText2Style = style;
                    }
                }              
            }
            
        }
    }
    @api
    observationValue ="";
    @api
    pendingValue ="";
    @api
    rejectValue ="";
    @api section;
    @api
    get statusValue(){
        return this.status;
    }
    set statusValue(value){
        switch(value) {
            case this.APPROVE:
                this.status = {approved: true};
                this.clearStatusValues();
                break;
            case this.PENDING:
                this.status = {pending: true};
                break;
            case this.REJECT:
                this.status = {rejected: true};
                break;
            case this.RETURNED_PENDING:
                this.returnedFromPending = true;
            case null :
                this.status = {}
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
            this.calcTimeBetweenToday(value.fieldValue);
            
        }
        if(value.dataType == this.DATE){
            this.dataType = {};
            this.dataType[this.DATE] = true;
            this.calcTimeBetweenToday(value.fieldValue);
        }
        if(value.dataType == this.BOOLEAN){
            this.cloneField.fieldValue = String(value.fieldValue);
            this.options = [{
                label : 'Sim',
                value : 'true'
            },{
                label : 'Não',
                value : 'false'
            }];
            this.dataType = {
                Picklist : true
            }   
        }
        if( this.cloneField.fieldValue ){
            this.fieldValue = String(value.fieldValue); 
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
        if(value.helpText2Conditions){
            this.helpText2Conditions = value.helpText2Conditions
        }
        if(value.helpText1){
            this.helpText1 = value.helpText1;
        }
        if(value.helpText2){
            this.initialHelpText2 = value.helpText2;
            this.fieldHelpText2 = value.helpText2
        }
        this.hidden = value.hidden;   
        this.settingField = false;
    }
    @api
    clearStatusValues() {
        this.observationValue = '';
        this.pendingValue = '';
        this.rejectValue = '';
    }

    calcTimeBetweenToday = (value) =>{
        if(value){
            const date1 = new Date(value);
            const date2 = Date.now()
            const milissecondsBetween = date2 - date1;
            const hoursBetween = milissecondsBetween / (1000 * 60 * 60);
            const daysBetween = hoursBetween / 24;
            this.daysBetweenNow = Math.round(daysBetween);
            this.monthsBetweenNow = Math.round( daysBetween / 30);
            this.hoursBetweenNow = Math.round(hoursBetween);
            this.yearsBetweenNow = Math.round(daysBetween / 365);
        }else{
            return '';
        }
    }
    handleInputChange(event) {
        event.preventDefault();
        const input = event.target;
        this.fieldValue = input.value;
        if(this.dataType[this.DATETIME] || this.dataType[this.DATE]){
            this.calcTimeBetweenToday(this.fieldValue);
            this.fieldHelpText2 = this.initialHelpText2;
        }
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
            fieldValue : this.fieldValue,
            rejectValue : this.rejectValue,
            pendingValue : this.pendingValue,
            observationValue : this.observationValue
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
        this.clearStatusValues();
    }
    @wire(getPicklistValues, { recordTypeId: '$recTypeId', fieldApiName: '$fieldUniqueName' })
    getPickListValue({error, data}){
        if(data){
            const options = this.options.concat(data.values);
            this.options = [...options];
        }
        if(error){
        }
    }
     renderedCallback(){
        this.renderCount++
    }
}