/*
* Base component to handle Proposal Form Building
* Maintaining Recomendations:
* Respect the sections for each variable or function type
* Try the to respect the alphabetic order in each section unless it's not possible
* This component was created to be extended so, when modified, retrocompatibility MUST be considered
*/
import { LightningElement, api, track, wire } from 'lwc';
import saveSection from '@salesforce/apex/ProposalController.saveSection';
import getLastSection from '@salesforce/apex/ProposalController.getLastSection';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

const CLEANBLE_FIELDS = ['text', 'string', 'phone', 'email']
export default class ProposalBaseComponent extends LightningElement {
    /* ---------------- 'CONSTANTS' SECTION ----------------------*/
    APPROVE = 'APPROVED';
    COMPLETE = 'COMPLETE';
    ID_FIELD = 'Id';
    FIELD_UPDATE = 'FIELD_UPDATE';
    HISTORY_LIMIT = 35;
    HISTORY_BUTTON_CURRENT = 'current-button';
    HISTORY_BUTTON_LAST = 'last-button';
    HISTORY_BUTTON_START = 'start-button';
    HISTORY_BUTTON_REDO = 'redo-button';
    HISTORY_BUTTON_UNDO = 'undo-button';
    PENDING = 'PENDING';
    REJECT = 'REJECTED';
    SCROLL_BEHAVIOUR = 'smooth';
    STATUS_UPDATE = 'STATUS_UPDATE'
    SUCCESS_SAVED = 'Dados atualizados com sucesso!';
    ERROR_SAVE = 'Erro ao atualizar registro: '
    VARIANT_BASE = 'base';
    VARIANT_BASE_COMPLETE = 'base-autocomplete';
    VARIANT_EXPIRED = 'expired';
    VARIANT_WARNING = 'warning';
    VARIANTBYSTATUS = {
        [this.COMPLETE]: { variant: this.VARIANT_BASE_COMPLETE, priority : 0 },
        [this.APPROVE] : { variant: this.VARIANT_BASE, priority: 10 },
        [this.PENDING] : { variant: this.VARIANT_WARNING, priority: 100 },
        [this.REJECT]  : { variant: this.VARIANT_EXPIRED, priority : 200 }

    }
    VIEWPORT_PADDING = 250;
    WRAPPER = 'section-wrapper';

    /* ----------- TRACk PROPERTIES SECTION ---------------------- */
    @track collapsed = true;
    @track componentFields = [];
    @track currentStep = 0;
    @track disabledBtnSave = true;    
    @track fieldsMeta;
    @track loadedFields = [];
    @track loadedFieldData = false;
    @track loadedFieldMetaData = false;
    @track modalReason;
    @track modalReasonField;
    @track modalReasonObject;
    @track openModal = false;
    @track openModalReason = false;
    @track progress = this.progress || {
        percentage : 0,
        type: this.VARIANTBYSTATUS[this.VARIANT_BASE],
        status : this.APPROVE
    };
    @track saved = true;
    @track SObjects = {};
    @track sectionId;
    @track validatedFields = {};
    @track retrievedRecord = {};
    @track recordSetup = false;
    @track sobjectData;
    /* ------------ STANDARD PROPERTIES SECTION -------------*/
    actionHistory = [];
    controlledFieldByPending = {};
    controlledFieldByReject= {};
    controlledFieldByObservation = {};
    controlledFieldByStatus = {};
    fieldsSetted = false;
    initialStatus;
    isLoadingRecord;
    fieldCount = 0;
    fieldCounts = {};
    fieldMap = {};
    fieldSet = new Set();
    firstOpening = true;
    firstRender = true;
    oppId;
    currentState = {};
    uniqueName;
    uniquekey;

    /*----------  ---------------Navigation Buttons------------------*/

    currentButton;
    undoButton;
    startButton;
    redoButton;
    lastButton;
    

    /* ----------------- @api Properties, GETTERS, SETTERS AND METHODS SECTION ---------*/

    /******* @api properties *************/
    
    @api hideButtons = false;
    @api disabled = false;
    @api parentid;
    @api parentRelationField;
    @api sectionName;
    @api sobjectName;
    
    /************ @api getters and setters **************/
    @api
    get fields(){
        return this.componentFields;
    }
    set fields(data){
        if(!data) return;
        this.componentFields = data.map( (field) =>{
            
            const uniqueName = field.SObject + '.' + field.ApiFieldName;            
            this.fieldMap[uniqueName] = Object.assign({}, field);
            const validatable = this.isValidatable(field);
            this.fieldSet.add(field.ApiFieldName);

            if(field.StatusField){
                const statusKey = field.SObject + '.' + field.StatusField;
                this.controlledFieldByStatus[statusKey] = uniqueName;
                this.fieldSet.add(field.StatusField);
            }
            if(field.PendingStatus) {
                this.fieldSet.add(field.PendingStatus.ApiFieldName);
                const pedingUniqueKey = field.PendingStatus.SObject + '.' + field.PendingStatus.ApiFieldName;
                this.controlledFieldByPending[pedingUniqueKey] = uniqueName;
            }
            if(field.RejectStatus) {
                this.fieldSet.add(field.RejectStatus.ApiFieldName);
                const rejectUniqueKey = field.RejectStatus.SObject + '.' + field.RejectStatus.ApiFieldName;
                this.controlledFieldByReject[rejectUniqueKey] = uniqueName;
            }
            if(field.ObservationField){
                this.fieldSet.add(field.ObservationField);
                const observationKey = field.SObject + '.' + field.ObservationField;
                this.controlledFieldByObservation[observationKey] = uniqueName;
            }
            const uniquekey = this.uniquekey ? this.uniquekey + '-' + uniqueName+ '-' + Math.floor(Math.random() * 9999) 
                              : uniqueName + '-' + Math.floor(Math.random() * 999999);
            return { ...field, uniqueName:  uniqueName, validatable : validatable, key : uniquekey, editable : false};
        });
        if(this.sobjectData){
            this.pushSobjectInfoToComponent('set fields');
        }
        this.fieldsSetted = true;
    }

    @api
    get componentLoaded(){
        return !this.disabled && this.loadedFieldMetaData;
    }

    @api
    get showButtons(){
        return !this.collapsed && !!this.hideButtons;
    }

    /****************** @api methods **********/
    @api
    enable(){
        const targetId = this.WRAPPER;
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        let positionY = target.getBoundingClientRect();
        target.classList.toggle('slds-is-open');
    }   
    @api
    buttonsLoaded = () =>{
        return !!this.currentButton &&
                !!this.undoButton && !!this.startButton
                && !!this.redoButton && !!this.lastButton;
    } 
    /* --------------------- WIRED FUNCTIONS SECTION --------------------- */
    @wire(getObjectInfo, { objectApiName: '$sobjectName'} )
    getSObjInfo({error, data}){
        if(data){                      
            this.sobjectData = data;
            if(this.componentFields.length){
                this.pushSobjectInfoToComponent('getSObjInfo');
            }
            this.loadedFieldMetaData = true;
        }else{
            if(error){
                console.error('[ERROR] OBJECT INFO NOT RETRIEVED STACKTRACE: '+error)
            }else{
                console.debug('[GET OBJECT INFO] INFO NOT LOADED YET');
            }
        }

    }
    /* -------------- LIFE CYCLE FUNCTIONS SECTION ----------------------*/
    renderedCallback(){
        if(!this.disabled && this.firstRender && this.fieldsSetted){
            this.getSection();
            this.firstRender = false;
            if(this.componentFields.length){
                this.componentFields.forEach((current) =>{
                    if( current.validatable || current.required ) {
                        this.fieldCount += 1;
                        this.fieldCounts[current.uniqueName] = current;
                    }
                });
            }
            this.recalculateProgress();
        }
    }
    /* ----------------- CUSTOM GETTERS AND SETTERS SECTION------------*/

    getSection = () =>{
        getLastSection({
            opportunityId : this.parentid,
            sobjectName: this.sobjectName,
            fields : Array.from(this.fieldSet),
            parentRelationField : this.parentRelationField
        }).then((data) =>{
            let result = JSON.parse(data);                        
            this.sectionId = result[this.sobjectName].Id;                        
            this.mapRecord(result);
            this.loadedFieldData = true;
        })
    }

    getField(name){
        return this.fieldMap[name];
    }
    setField = (name, value) => {
        this.fieldMap[name] = value;
    }

    /* ----------------------- FUNCTIONS SECTIONS ----------------------*/
    closeSection = () =>{
        this.Up();
        this.handleAccordionToggle();
    }
    cleanField = (fieldMeta, clearStatus) =>{
        
        if ( this.isLoadingRecord ) return;

        const key = fieldMeta.SObject;
        const targetId =  fieldMeta.SObject + '.' + fieldMeta.ApiFieldName;

        if(clearStatus && this.currentState[key]) {
            this.currentState[key][fieldMeta.StatusField] = null;
        }
        
        if( this.SObjects[key] == null ) this.SObjects[key] = JSON.parse(JSON.stringify(this.currentState[key]));

        const sobject = this.SObjects[key];

        if(!sobject) return;
        if(sobject){
            if(fieldMeta.PendingStatus){
                
                this.SObjects[key][fieldMeta.PendingStatus.ApiFieldName] = null;
                this.currentState[key][fieldMeta.PendingStatus.ApiFieldName] = null;
            }
            if(fieldMeta.RejectStatus){
                
                this.SObjects[key][fieldMeta.RejectStatus.ApiFieldName] = null;
                this.currentState[key][fieldMeta.RejectStatus.ApiFieldName] = null;
            }
            if(fieldMeta.ObservationField){
                
                this.SObjects[key][fieldMeta.ObservationField] = null;
                this.currentState[key][fieldMeta.ObservationField] = null;
            }
            
        }
        const target = this.template.querySelector(`[data-id="${targetId}"]`);
        target.clearStatusValues();
        
    }
    clear(targetId){
        try{
            const target = this.template.querySelector(`[data-id="${targetId}"]`);
            this.deleteValidatedField(targetId);
            if(target) { target.clear(); }
        }catch(e){
            console.error('[ERROR] Error during field clear. Stacktrace: ' + e);
        }
    }
    deleteValidatedField = (targetId) =>{
        if(!this.isLoadingRecord){
            this.deletePropertiyFromObject(this.validatedFields, targetId);
        }
    }
    deletePropertiyFromObject(object, targetId){
        if(object[targetId]){
            delete object[targetId];
        }
    }
    clearAll(){
        let targets = this.template.querySelectorAll('c-proposal-field-section');
        for(let i = 0; i < targets.length; i++){
            targets[i].clear();
        }
        this.validatedFields = {};
        this.disabledBtnSave = true;
        this.recalculateProgress();
    }    
    isValidatable(field){
        let tempField = Object.assign({}, field);                
        field.actions = field.actions || [];                
        let readOnly = field.actions.includes('READONLY') || field.actions.includes('NO_VALIDATION') || !field.actions.length;
        readOnly = readOnly;
        return !readOnly;
    }
    isEditable(field){                
        let tempField = Object.assign({}, field);                
        field.actions = field.actions || [];                                
        let editable = (field.actions.includes('EDIT') || field.required) && !!field.updateable;
        return editable;
    }
    handleApproval = (field) => {
        try{
            this.cleanField(field);
            this.prepareRequestJSON(field)
        }catch(e){
            console.error('[ERROR] MOUNT SOBJECT WAS NOT POSSIBLE, SEE STACKTRACE' + e);
        }
    }
    handleInputInteraction = (event) =>{
       
    }
    handleChange = (event) => {
        try{
            if(!event.detail.uniqueName) return;
            let field = event.detail;

            if(!this.isLoadingRecord){ 
                this.saved = false;
                this.clear(event.detail.uniqueName);
            }
            let pushHistory = false;
            try{
                if(event.detail.required){
                    if(!String(event.detail.fieldValue).trim()){
                        this.deleteValidatedField(event.detail.uniqueName)
                    }else{
                        if(!event.detail.validatable){
                            event.detail.value = this.APPROVE;
                            this.validatedFields[event.detail.uniqueName] = event.detail;
                        }
                    }
                }
                
            }catch(e){
                console.error(e)
            }
            const dataType = event.detail.dataType || 'text';
           
            if( String(event.detail.fieldValue).trim() && 
                ((String(event.detail.fieldValue).endsWith(' '))
                || ((dataType.toLowerCase().indexOf('text') == -1)
                && (dataType.toLowerCase().indexOf('string') == -1)))
            ){
                pushHistory = true;
            }; 
            this.recalculateProgress();
            this.mountField(event.detail, this.FIELD_UPDATE);
            if(pushHistory) { 
                
                this.cleanField(field, this.actionHistory.length > 0 && !this.isLoadingRecord);
                this.pushHistory(this.currentState);             
            }
        }catch(e){
            console.error(e);
        }
    }
    handleChoice = (event) => {
        if(this.isLoadingRecord){
            this.prepareRequestJSON(event.detail);
            return;
        }
        const status = event.detail.value;
        this.modalReason = this.progress.type;
        this.modalReasonObject = event.detail.SObject;
        switch(status) {
            case this.APPROVE:
                this.handleApproval(event.detail);
                break;
            case this.PENDING:
                this.handlePending(event.detail);
                break;
            case this.REJECT:
                this.handleRejection(event.detail);
                break;
        }
    }
    handleFieldLoad = (evt) =>{
        this.isLoadingRecord = true;
        try{
            if(evt.detail.fieldValue){
                this.handleChange(evt);
            }
            if(evt.detail.value){
                this.handleFieldValidation(evt);
            }
        }catch(e){            
        }
      
        this.isLoadingRecord = false;
    }
    handleFieldValidation = (event) => {
        if(!this.isLoadingRecord){ 
            this.saved = false; 
            
            
            
            
            
        }
        this.handleProgress(event);
        this.handleChoice(event);
    }
    handleModalClose(){
        const modal = this.template.querySelector('c-modal-reason');
        let opened = false;
        if(!!modal) {
            opened =  modal.closeModal();
        }
    }
    handleModalCancel(event){   
        if(!this.currentState[event.detail.objectReason][event.detail.StatusField]){
            this.currentState[event.detail.objectReason][event.detail.StatusField] = null;
        }
        this.setRecord(this.currentState);
    }
    handleOpenModal = (field, reason) =>{
        const modal = this.template.querySelector('c-modal-reason');
        let opened = false;
        if(!!modal) {
            try{
                modal.typeReason = field.value;
                modal.fieldReason = reason.ApiFieldName;
                modal.objectReason = field.SObject;
                modal.checkedField = field;
                modal.setModalHeader(reason.Label);
                opened =  modal.openModal();
            }catch(e){
                console.error(e);
            }
        }
    }
    handlePending = (field) => {
        if(field.PendingStatus){
            this.handleOpenModal(field, field.PendingStatus);
        }else{
            this.prepareRequestJSON(field);
        }
    }
    handleProgress = (event) => {
        if(!this.VARIANTBYSTATUS[event.detail.value]) return;
        if(event.detail.validatable){
            if(!event.detail.required){
                this.validatedFields[event.detail.uniqueName] = event.detail;
            }else if( event.detail.fieldValue ){
                this.validatedFields[event.detail.uniqueName] = event.detail;
            }
            
        }
        this.recalculateProgress();
        
    }
    handleRejection = (field) => {
        if(field.RejectStatus){
            this.handleOpenModal(field, field.RejectStatus);
        }else{
            this.prepareRequestJSON(field);
        }
    }
    handleSaveSection = () => {
        let data = JSON.stringify(this.SObjects);
        
        saveSection({section : data}).then( (result ) =>{
            this.showToast('Sucesso', this.SUCCESS_SAVED, 'success');
            this.saved = true;
            this.recalculateProgress();
            this.notifyRecordChange();
            this.closeSection();
        }).catch((error) => {
            console.error(error);
            this.showToast('Erro', this.ERROR_SAVE + error.body.pageErrors[0].message, 'error');
        });
    }
    handleSelectedReason = (event) =>{
        try{
            this.cleanField(event.detail.originField);
            if(event.detail.reason){
                const returnedData = event.detail;
                const uniqueName = event.detail.originField.uniqueName;
                this.prepareRequestJSON(this.fieldMap[uniqueName], event.detail);
                const newField = Object.assign({}, event.detail.originField);
                const newFieldValue = {
                    [event.detail.object] : {
                        [event.detail.field] : event.detail.reason,
                        [event.detail.originField.ObservationField] : event.detail.description
                    }
                };
                this.setRecord(newFieldValue);
            }
        }catch(e){
            console.error(e);
        }
    }
    handleAccordionToggle(event) {
        if(!this.disabled){
            const targetId = this.WRAPPER;
            let target = this.template.querySelector(`[data-id="${targetId}"]`);
            let positionY = target.getBoundingClientRect();
            target.classList.toggle('slds-is-open');
            if(target.classList.contains('slds-is-open')){
                this.collapsed = false;
                
            }else{
                this.collapsed = true;
            }
            if(!this.collapsed){
                this.clearButtonCache();
                this.setButtons(1);                
                this.firstOpening = false;
                
            }
            
        }
    }
    hasHistory = (field) => {
        if( !this.actionHistory[this.currentStep - 1] ){
            return false;
        }
        const hasChanges = !this.isLoadingRecord && 
            (!this.actionHistory[this.currentStep - 1] || (this.actionHistory[this.currentStep - 1] && 
            (this.actionHistory[this.currentStep - 1][field.SObject][field.ApiFieldName].fieldValue 
            != field.fieldValue)));
        
        return hasChanges;
    }
    setButtons = (attempt) =>{
        parent = this;
        if(this.redoButton && this.lastButton && this.undoButton && this.startButton && this.currentButton){
                this.updateButtons(true);
            return;
        }
        else if(attempt <=5){
            setTimeout(() => {
                this.redoButton = this.template.querySelector(`[data-id="${this.HISTORY_BUTTON_REDO}"]`);
                this.lastButton = this.template.querySelector(`[data-id="${this.HISTORY_BUTTON_LAST}"]`);
                this.undoButton = this.template.querySelector(`[data-id="${this.HISTORY_BUTTON_UNDO}"]`);
                this.startButton = this.template.querySelector(`[data-id="${this.HISTORY_BUTTON_START}"]`);
                this.currentButton = this.template.querySelector(`[data-id="${this.HISTORY_BUTTON_CURRENT}"]`);
                this.setButtons(attempt++);
                }, 10*(Math.pow(2, attempt)));
           
        }
    }
    undo(event){
        if(this.actionHistory.length){
            const desiredStep = this.currentStep - 1;
            if(desiredStep >= 0){
                this.goToStep(desiredStep);
            }
        }
    }
    mountField = (fieldMeta, operation) => {
        if(this.isLoadingRecord) return;       
        if(fieldMeta.updateable){
            const key = fieldMeta.SObject;                      
            this.SObjects[key] = this.SObjects[key] ? this.SObjects[key] : {};
            let  tempData = {};
            
            switch (operation) {
                case this.FIELD_UPDATE:
                      tempData[fieldMeta.ApiFieldName] = fieldMeta.fieldValue;
                    break;
            
                default:
                    tempData[fieldMeta.ApiFieldName] = fieldMeta.value;
                    break;
            }
            tempData[this.ID_FIELD] = this.sectionId;
            this.SObjects[key] = {
                ...this.SObjects[key],
                ...tempData
            }
            this.currentState[key] = this.currentState[key] || { [key] : {} };
            this.currentState[key] ={
                ...this.currentState[key],
                ...this.SObjects[key],
                ...tempData
            }
        }
    }
    prepareRequestJSON = (fieldMeta, fieldData) =>{

        if( this.isLoadingRecord ) return;
        const key = fieldData ? fieldData.object : fieldMeta.SObject;
        fieldData = fieldData || {};
        fieldData.originField = fieldData.originField || {};
        this.SObjects[key] = this.SObjects[key] ? this.SObjects[key] : {};

        let tempData = {};

        if(fieldMeta.StatusField){
            tempData[fieldMeta.StatusField] = fieldMeta.value || fieldData.originField.value
        }
        if(fieldMeta.ObservationField && fieldData.description){
            tempData[fieldMeta.ObservationField] = fieldData.description || null
        }
        if(fieldData.reason){
            tempData[fieldData.field] = fieldData.reason || null
        }
        if(this.sectionId) {
            tempData[this.ID_FIELD] = this.sectionId;
        }
        if(!this.actionHistory.length){            
            this.currentState[key] = this.currentState[key] || { [key] : {} };
            this.currentState[key].progress = this.initialStatus;
            this.pushHistory({
              ...this.currentState
            });
            
        }
        this.SObjects[key] = {
            ...this.SObjects[key],
            ...tempData
        };
        
        this.currentState[key] = {
            ...this.currentState[key],
            ...this.SObjects[key],
            ...tempData,
            progress : this.progress.status
        };
        this.pushHistory(this.currentState);
        
        
    }
    notify = (event, data) => {
        try{
            const evt = new CustomEvent(event, {
                detail : {
                    ...data
                }
            });
            this.dispatchEvent(evt);
        }catch(e){
            console.error(e);
        }
    }
    notifySectionComplete = () => {
        this.notify('sectioncomplete', {
            progress : this.progress.percentage,
            sectionName : this.sectionName,
            status : this.progress.status,
            type : this.progress.type,
            uniquekey : this.uniquekey,
            complete : true
        });        
    }
    notifyProgress = () =>{
        const sectionUpdateEvent = new CustomEvent('progresschange', {
            detail : {
                percentage : this.progress.percentage,
                sectionId : this.sectionId,
                sectionName : this.sectionName,
                uniquekey : this.uniquekey,
                status : this.progress.status,
                returnedId : this.uniquekey,
                type : this.progress.type,
                variant: this.progress.type,
                value : this.progress.percentage,
                complete : this.progress.percentage == 100 ? true : false
            }
        });
        this.dispatchEvent(sectionUpdateEvent);
    }
    notifyRecordChange = () => {
        getRecordNotifyChange([{recordId : this.parentId},{ recordId : this.sectionId }]);
    }
    pushHistory = (currentState) => {
        if(this.isLoadingRecord && this.actionHistory.length == 1) {
            this.actionHistory = [];
        }
        if(!this.isLoadingRecord || !this.actionHistory.length){
            if(this.currentStep < this.actionHistory.length - 1){
                this.actionHistory = this.actionHistory.reduce((previous, current, index)=>{
                    if(this.currentStep >= index ){
                        previous.push(current);
                        this.clearForwardButton(index);
                        return previous;
                    }else { return previous; }         
                },[]);
            }
            if(this.actionHistory.length == this.HISTORY_LIMIT ) {
                this.actionHistory = this.actionHistory.reduce((previous, current, index)=>{
                    if(index != 1 ){
                        previous.push(current);
                        return previous;
                    }else { return previous; }         
                },[]);
            }
            const history = {
                ...currentState
            }
            this.actionHistory.push(JSON.parse(JSON.stringify(history)));

            try{
                this.goToStep(this.actionHistory.length - 1, false);
            }catch(e){
                console.error(e);
            }
            this.currentStep = this.actionHistory.length ?
                               this.actionHistory.length - 1
                               : 0;
        }
    }
    pushSobjectInfoToComponent(caller){
        if(!this.sobjectData) return;        
        let updatedComponentField = [];
        this.isLoadingRecord = true;
        this.componentFields.forEach((item) =>{
            const newItem = {
                ...item,
                updateable : this.sobjectData.fields[item.ApiFieldName].updateable,
                helpText1 : this.sobjectData.fields[item.ApiFieldName].inlineHelpText,
                dataType : this.sobjectData.fields[item.ApiFieldName].dataType,
                recordTypeId : item.RecordTypeId ? 
                               item.RecordTypeId : 
                               this.sobjectData.defaultRecordTypeId,
                editable : this.isEditable ({...item, updateable: this.sobjectData.fields[item.ApiFieldName].updateable})
            }
            updatedComponentField.push(newItem);
           
            this.handleFieldLoad({
                detail : newItem
            });                        
        });                
        this.componentFields = updatedComponentField;
        this.isLoadingRecord = false
        

    }
    recalculateProgress = () => {
        
        if(!this.actionHistory.length && this.isLoadingRecord){
            this.initialStatus = this.progress.status;
        }
        const validatedKeys =  Object.keys(this.validatedFields);                
        const validatedCount = validatedKeys.length;
        this.progress.percentage = validatedCount / this.fieldCount * 100;
        
        const value = validatedKeys.length
                      ?
                      this.validatedFields[validatedKeys[0]].value
                      :
                      this.APPROVE;
       
        
        this.progress.status = validatedKeys.length ? Object.values(this.validatedFields).reduce((acc, current)=>{
            return this.VARIANTBYSTATUS[current.value].priority >= this.VARIANTBYSTATUS[acc].priority
                    ? current.value
                    : acc
        }, value) : this.APPROVE;

        this.progress.type = this.VARIANTBYSTATUS[this.progress.status].variant
        
        if(this.progress.percentage < 100) {
            this.disabledBtnSave = true;
        }
        if( (this.progress.percentage == 100 && this.sectionId)){
            if(!this.saved) {
                this.progress.percentage = 99;
                this.disabledBtnSave = false;
            } else {
                this.disabledBtnSave = true;
            }
            
            let type;
            if(this.saved && this.progress.status == this.APPROVE){
               type = this.COMPLETE
               
            }
            else{
                type = this.progress.status;
            }
            this.progress.status = type;
            this.progress.type = this.VARIANTBYSTATUS[this.progress.status].variant;
        }
            
        if(this.progress.percentage == 100 ) { this.notifySectionComplete() };                
        this.notifyProgress();
    }
    mapRecord (retrievedRecord){
        let fieldName = '';
        let objectName;
        let currentState = {};
        let currentFields = {}
        for ( let [key, value] of Object.entries(retrievedRecord) ) {
            
            let child = value;
            let obj = key;
            for ( let [key, value] of Object.entries(child) ){
                const targetId = obj + '.' + key;                                
                currentFields[key] = value;
                if(this.fieldMap[targetId]){
                    this.retrievedRecord[targetId] = this.retrievedRecord[targetId] || {};
                    this.retrievedRecord[targetId]['value'] = value;
                    fieldName = targetId;                    
                    objectName = obj;
                    currentState[obj];
                }
                if( this.controlledFieldByStatus[targetId]){
                    const statusKey = this.controlledFieldByStatus[targetId];
                    this.retrievedRecord[statusKey] = this.retrievedRecord[statusKey] || {};
                    this.retrievedRecord[statusKey]['statusValue'] = value;
                    
                }
                if(this.controlledFieldByPending[targetId]){
                    const pendingKey = this.controlledFieldByPending[targetId];
                    this.retrievedRecord[pendingKey] = this.retrievedRecord[pendingKey] || {};
                    this.retrievedRecord[pendingKey]['pendingValue'] = value;
                    currentFields[key = value];
                }
                if(this.controlledFieldByReject[targetId]){
                    const rejectKey = this.controlledFieldByReject[targetId];
                    this.retrievedRecord[rejectKey] = this.retrievedRecord[rejectKey] || {};
                    this.retrievedRecord[rejectKey]['rejectValue'] = value;
                }
                if(this.controlledFieldByObservation[targetId]){
                    const observationKey = this.controlledFieldByObservation[targetId];
                    this.retrievedRecord[observationKey] = this.retrievedRecord[observationKey] || {};
                    this.retrievedRecord[observationKey]['observationValue'] = value;
                }
            }
            
        }
        let updatedComponentFields = [];
        
        this.componentFields.forEach((item) =>{
            const recordData = this.retrievedRecord[item.uniqueName]
            if(recordData){
                const newItem = {
                    ...item,
                    fieldValue : recordData.value,
                    statusValue : recordData.statusValue,
                    ...recordData
                };
                updatedComponentFields.push(newItem);
                this.handleFieldLoad({
                    detail : newItem
                });
            }else{
                updatedComponentFields.push(item);
            }
        });
        this.isLoadingRecord = true;
        this.componentFields = updatedComponentFields;       
        currentState[this.sobjectName] = {
            ...currentFields,
            progress : this.progress.status
        }       
        this.currentState = currentState;
        this.pushHistory(this.currentState);
        this.isLoadingRecord = false;
        this.saved = true;

        
    }
    redo(){
        if(this.actionHistory.length){
            const desiredStep = this.currentStep + 1;
            if(desiredStep <= (this.actionHistory.length - 1) ){
                this.goToStep(this.currentStep + 1);
            }
        }
    }
    reload = async () =>{
        this.clearButtons();
        this.actionHistory = [];
        await this.getSection();
        this.notifyRecordChange();
       
    }
    setFieldValue(targetId, field) {
        
        
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
       
        target.fieldValue = field.fieldValue;
        target.statusValue = field.statusValue;
        target.pendingValue = field.pendingValue;
        target.rejectValue = field.rejectValue;
        target.observationValue = field.observationValue;

    }
    
    setRecord(fields, clear) {
        this.isLoadingRecord = true;
        for ( let [key, value] of Object.entries(fields) ) {
            let child = value;
            let obj = key;
            for ( let [key, value] of Object.entries(child) ){
                const targetId = obj + '.' + key;
               
                if(this.fieldMap[targetId]){
                    let target = this.template.querySelector(`[data-id="${targetId}"]`);
                    target.fieldValue = ( typeof value === 'boolean') ? value.toString() : value ;
                    if(clear){
                        if(this.fieldMap[targetId].validatable){
                            target.clear();
                            this.deleteValidatedField(targetId);
                            target.fieldValue = value;
                        }
                    }
                }
                if(!clear){
                    if( this.controlledFieldByStatus[targetId]){
                        const statusKey = this.controlledFieldByStatus[targetId];
                        let target = this.template.querySelector(`[data-id="${statusKey}"]`);                       
                        target.statusValue = value;
                    }
                    if(this.controlledFieldByPending[targetId]){
                        const pendingKey = this.controlledFieldByPending[targetId];
                        let target = this.template.querySelector(`[data-id="${pendingKey}"]`);
                        target.pendingValue = value;
                    }
                    if(this.controlledFieldByReject[targetId]){
                        const rejectKey = this.controlledFieldByReject[targetId];
                        let target = this.template.querySelector(`[data-id="${rejectKey}"]`);
                        target.rejectValue = value;
                    }
                    if(this.controlledFieldByObservation[targetId]){
                        const observationKey = this.controlledFieldByObservation[targetId];
                        let target = this.template.querySelector(`[data-id="${observationKey}"]`);
                        target.observationValue = value;
                    }
                }
            }
        }
        this.recalculateProgress();
        this.isLoadingRecord = false;
       
        if(clear) this.disabledBtnSave = true;
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    toLast = () => {
        this.goToStep(this.actionHistory.length);
    }
    toStart = () => {
        this.goToStep(0);
    }
    Up = () => {
        const targetId = this.WRAPPER;
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        let position = target.getBoundingClientRect();
        let documentPosition =  document.documentElement.getClientRects()[0];
        let recoordenatedPosition = Math.sign( documentPosition.y ) === Math.sign( position.y ) ?
                                    Math.abs( documentPosition.y - position.y )
                                    : Math.abs( documentPosition.y ) + Math.abs( position.y );

        recoordenatedPosition -= this.VIEWPORT_PADDING;

        let top = Math.abs(documentPosition.y + position.y);
        const scrollOptions = {
            left: position.left,
            top:  recoordenatedPosition,
            behavior: this.SCROLL_BEHAVIOUR
        }
        window.scrollTo(scrollOptions);
    }
    goToStep  = (step, reset) =>{
        
        let position = this.currentStep;
        let newPosition =  step > 0 ? step : 0;
        newPosition = newPosition >= this.actionHistory.length ? 
                            this.actionHistory.length - 1 :
                            step;
                            
        newPosition = newPosition <= 0 ? 0 : newPosition;

        const direction = position > newPosition ? 'BACKWARDS' : 'FORWARDS';
        
        let directionActions = {
            oldStep : position,
            direction : direction
        };

        if(reset != false) this.setRecord(this.actionHistory[newPosition], false);
        
        this.currentStep = newPosition;
        this.cleanButtons(directionActions);
        this.updateButtons();
        if(this.currentStep == 0 && this.actionHistory.length > 1){
            this.disabledBtnSave = true;
        }
        
    }
    updateButtons = (updateAll) => {
        if(!this.buttonsLoaded()) return;
        if(updateAll){
            this.currentButton.classList.add((this.actionHistory[this.currentStep][this.sobjectName]?.progress));
        }

        if(this.currentStep == 0){
            this.undoButton.classList.add('inactive');
            this.startButton.classList.add('inactive');
        }else{
            this.undoButton.classList.remove('inactive');
            this.startButton.classList.remove('inactive');
            if(this.actionHistory[this.currentStep-1]){
                this.undoButton.classList.add(this.actionHistory[this.currentStep-1][this.sobjectName]?.progress);
                this.startButton.classList.add(this.actionHistory[0][this.sobjectName]?.progress);
            }
        }
        if(this.currentStep >= this.actionHistory.length -1 ){  
            
            this.redoButton.classList.add('inactive');
            this.lastButton.classList.add('inactive');

        }else{
            this.redoButton.classList.remove('inactive');
            this.lastButton.classList.remove('inactive');
            if(this.actionHistory[this.currentStep+1]){
                this.redoButton.classList.add(this.actionHistory[this.currentStep+1][this.sobjectName]?.progress);
                this.lastButton.classList.add(this.actionHistory[this.actionHistory.length -1][this.sobjectName]?.progress);
            }
        } 
    }
    clearButtonCache = () =>{
        this.redoButton = null;
        this.lastButton = null;
        this.undoButton = null;
        this.startButton = null;
        this.currentButton = null;
    }
    clearButtons = () => {
        if(!this.buttonsLoaded()) return;
        this.actionHistory.forEach((action)=>{
            if(action[this.sobjectName]){
                this.undoButton.classList.remove(action[this.sobjectName].progress);
                this.startButton.classList.remove(action[this.sobjectName].progress);
                this.redoButton.classList.remove(action[this.sobjectName].progress);
                this.lastButton.classList.remove(action[this.sobjectName].progress);
                this.currentButton.classList.remove(action[this.sobjectName].progress);    
            }
        });
    }
    clearForwardButton = (step) =>{
        if(!this.buttonsLoaded()) return;
        this.redoButton.classList.remove(this.actionHistory[step][this.sobjectName]?.progress);
        this.lastButton.classList.remove(this.actionHistory[step][this.sobjectName]?.progress);
    }
    cleanButtons = ({direction, oldStep }) =>{
        if(!this.buttonsLoaded()) return;
        if(this.currentButton){
            this.currentButton.classList.remove(this.actionHistory[oldStep][this.sobjectName]?.progress);
            this.currentButton.classList.add(this.actionHistory[this.currentStep][this.sobjectName]?.progress);            
        }
        if(direction == 'BACKWARDS'){
            this.undoButton.classList.remove(this.actionHistory[this.currentStep][this.sobjectName]?.progress);
            this.startButton.classList.remove(this.actionHistory[this.currentStep][this.sobjectName]?.progress);
            if(this.actionHistory[oldStep+1]){
                this.redoButton.classList.remove(this.actionHistory[oldStep+1][this.sobjectName]?.progress);
                this.lastButton.classList.remove(this.actionHistory[oldStep+1][this.sobjectName]?.progress);
            }
        }
        if(direction == 'FORWARDS'){
            if(this.actionHistory[oldStep-1]){
                this.undoButton.classList.remove(this.actionHistory[oldStep-1][this.sobjectName]?.progress);
                this.startButton.classList.remove(this.actionHistory[oldStep-1][this.sobjectName]?.progress);
            }
            if(this.actionHistory[this.currentStep]){
                this.redoButton.classList.remove(this.actionHistory[this.currentStep][this.sobjectName]?.progress);
                this.lastButton.classList.remove(this.actionHistory[this.currentStep][this.sobjectName]?.progress);
            }
        }
    }
}