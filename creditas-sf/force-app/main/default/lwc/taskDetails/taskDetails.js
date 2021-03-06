import { LightningElement, track, api, wire } from 'lwc';
import getTaskDetails from '@salesforce/apex/TaskDetailsController.getTaskDetails';
import updateRecordTask from '@salesforce/apex/TaskDetailsController.updateRecordTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, updateRecord  } from 'lightning/uiRecordApi';
import TASKDETAILS_OBJECT from '@salesforce/schema/TaskDetails__c';
import TASKDETAILSFIELD_ID from '@salesforce/schema/TaskDetails__c.Id';
import TASKDETAILSFIELD_PRODUCT from '@salesforce/schema/TaskDetails__c.Product__c';
import TASKDETAILSFIELD_TASKTYPE from '@salesforce/schema/TaskDetails__c.TaskType__c';
import { generalMask } from 'c/maskUtils';

export default class TaskDetails extends LightningElement {
    @api recordId;
    @track taskDetails;
    @track tasks;
    mapRelatedFields = new Map();
    listRecordSave;
    listValuesSave = [];
    recordTaskDetailsId;
    isRecordUpdate = false;
    showComponent = false;
    isLoading = false;
    taskProduct;
    taskType;

    connectedCallback(){
        this.getTaskDetails();
    }

    getTaskDetails(){
        getTaskDetails({taskId: this.recordId})
        .then( data =>{

            var updatedListData = []; // Merge da lista TaskDetailSettings(campos)/TaskDetails(valores).
            let listTaskDetailSettings = data.TaskDetailSettings;
            this.taskProduct = data.Product;
            this.taskType = data.TaskType;
            let listDetailsValue = (data && data.TaskDetails) ? data.TaskDetails : null;
            this.showComponent = (listTaskDetailSettings && listTaskDetailSettings.length > 0) ? true : false;
            this.isRecordUpdate = (listDetailsValue && listDetailsValue[0]?.Id) ? true : false;

            for(let item in listTaskDetailSettings){
                let currentItem = listTaskDetailSettings[item];                
                let updatedData = { ...listTaskDetailSettings[item]};

                updatedData.picklistValues  = [];
                updatedData.checkboxGroupValues  = [];
                updatedData.radioGroupValues  = [];
                updatedData.value =  (updatedData.isCheckbox) ? false :'';
                
                //Caso j?? exista um registro de taskDetails relacionado com a Task, o valor ser?? carregado no campo.
                if(listDetailsValue){

                    this.recordTaskDetailsId = listDetailsValue[0].Id;

                    let valueField = listDetailsValue[0]['FieldValue'+listTaskDetailSettings[item].fieldMappedKey+'__c'];

                    if(!this.isUndefined(valueField)){
                        if(currentItem && currentItem.picklistValues && currentItem.isMultiPicklist){
                            let valuePicklist = valueField.split(';').map((item) => item.trim());
                            updatedData.value = valuePicklist;
                        }else if(currentItem && currentItem.isCheckbox){
                            updatedData.value = (valueField && valueField != "" && valueField == 'true') ? true : false;
                        }
                        else if(currentItem && currentItem.checkboxGroupValues != null && currentItem.isCheckboxGroup){
                            let valueCheckboxGroup = valueField.split(';').map((item) => item.trim());
                            updatedData.value = valueCheckboxGroup;
                        }
                        else{
                            updatedData.value = valueField ;
                        }
                    }
                }

                //Manipula????o dos valores que ser??o apresentados em cada campo do tipo (picklist, multipicklist, checkboxGroup e radioGroup).
                if (currentItem && currentItem.picklistValues != null && (currentItem.isMultiPicklist || currentItem.isPicklist)) {
                    let valuesJson = currentItem.picklistValues.split(';').map((item) => item.trim());
                    updatedData.picklistValues = valuesJson.map((item) => Object.assign({}, {label: item, value: item}));
                }
                else if (currentItem && currentItem.checkboxGroupValues != null && currentItem.isCheckboxGroup) {
                    let valuesJson = currentItem.checkboxGroupValues.split(';').map((item) => item.trim());
                    updatedData.checkboxGroupValues = valuesJson.map((item) => Object.assign({}, {label: item, value: item}));
                }
                else if (currentItem && currentItem.radioGroupValues != null && currentItem.isRadioGroup) {
                    let valuesJson = currentItem.radioGroupValues.split(';').map((item) => item.trim());
                    updatedData.radioGroupValues = valuesJson.map((item) => Object.assign({}, {label: item, value: item}));
                }
                
                updatedListData.push(updatedData);
            }

            this.tasks = updatedListData;
        })
        .catch(error =>{
            console.log({error});
        })
    }

    handleSave(){
        var listTaskDetails = [];
        let isValid = true;

        this.template.querySelectorAll(".form-fields").forEach(elem => {
            var objTaskDetails = {};
            let dataId = elem.getAttribute("data-id");
             
            if(elem.tagName == 'C-SEARCH-COMPONENT'){
                
                if(elem.fieldRequired == true){
                    let isValidRelationship = elem.getValidityRelationship();
                    (isValidRelationship != true) ? isValid = false: '';
                }
            }else if(!elem.checkValidity()) {
                elem.reportValidity();
                isValid = false;
            }
            if(!this.isUndefined(dataId) && isValid){

                objTaskDetails["FieldKey"+dataId+"__c"] = elem.getAttribute("data-fieldKey");
                objTaskDetails["FieldName"+dataId+"__c"] = elem.getAttribute("data-name");

                let valueField;
                if(elem.type == 'checkbox'){
                    valueField = elem.checked.toString();
                }else if(elem.tagName == 'LIGHTNING-DUAL-LISTBOX' || elem.tagName == 'LIGHTNING-CHECKBOX-GROUP' && elem.value != ""){
                    valueField = elem.value.join(';');
                }else if(elem.tagName == 'C-SEARCH-COMPONENT'){
                    valueField = this.mapRelatedFields.get(dataId);
                }else{
                    valueField = elem.value;
                }
                
                objTaskDetails["FieldValue"+dataId+"__c"] = valueField;
                listTaskDetails.push(objTaskDetails);
            }
        }); 

        if(isValid){
            this.listRecordSave = JSON.parse(JSON.stringify(listTaskDetails));

            (this.isRecordUpdate == true)
            ? this.updateTaskDetails()
            : this.insertTaskDetails();
        }else{
            this.dispatchShowToast('','Favor revisar os campos do formul??rio.', 'error');
        }
    }

    insertTaskDetails(){

        let listFields = this.listRecordSave;
        const fields = Object.assign({}, ...listFields);
        
        fields[TASKDETAILSFIELD_PRODUCT.fieldApiName] = this.taskProduct ? this.taskProduct.toUpperCase() : '';
        fields[TASKDETAILSFIELD_TASKTYPE.fieldApiName] = this.taskType;

        const recordInput = {apiName: TASKDETAILS_OBJECT.objectApiName, fields};

        createRecord(recordInput)
        .then( taskdetails =>{
            this.recordTaskDetailsId = taskdetails.id;
            this.isRecordUpdate = true;
            this.updateTask();
           
            this.dispatchShowToast('Success', 'Registro criado com sucesso.', 'success');
        })
        .catch(error => {
            this.dispatchShowToast('Erro ao criar o registro.', error.body.message, 'error');
        });
    }

    updateTaskDetails(){

        let listFields = this.listRecordSave;

        const fields = Object.assign({}, ...listFields);
        fields[TASKDETAILSFIELD_ID.fieldApiName] = this.recordTaskDetailsId;
        const recordInput = {fields};

        updateRecord(recordInput)
        .then( taskdetails =>{
            this.dispatchShowToast('Success', 'Registro atualizado com sucesso.', 'success');
        })
        .catch(error => {
            this.dispatchShowToast('Erro ao atualizar o registro.', error.body.message, 'error');
        });
    }

    updateTask(){ 
        updateRecordTask({ taskId: this.recordId, taskDetailsId: this.recordTaskDetailsId} )
        .then()
        .catch(error => {
            console.log('ERRO: '+JSON.stringify(error));
        });
    }

    //Evento para capturar o preenchimento do campo de relacionamento do componente searchComponent
    handleLookup(event){
        let eventRelatedFild = event.detail.data;
        this.mapRelatedFields.set(eventRelatedFild.mappedId, eventRelatedFild.recordId);
    }

    handleChange(event){
        let elem = event.target; 
        if(elem.getAttribute('data-mask') != ""){
            event.target.value = generalMask( elem.value, elem.getAttribute('data-mask'));
        }
    }

    isUndefined(value){
        var undefined = void(0);
        return value === undefined;
    }

    dispatchShowToast(aTitle, aMessage, aVariant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: aTitle,
                message: aMessage,
                variant: aVariant,
            }),
        );
    }
    
}