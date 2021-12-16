import { LightningElement, track, api, wire } from 'lwc';
import getTaskDetails from '@salesforce/apex/TaskDetailsController.getTaskDetails';
import { createRecord } from 'lightning/uiRecordApi';
import TASKDETAILS_OBJECT from '@salesforce/schema/TaskDetails__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskDetails extends LightningElement {
    @api recordid;
    @track taskDetails;
    @track tasks;
    listRecordsInsert;
    listValuesSave = [];
    lookupRecordId;

    // connectedCallback(){
    //     console.log('RecordId:', this.recordId);
    // }

    @wire(getTaskDetails, {taskId: '$recordid'}) getFields({error, data}){
        if(data){
            var updatedListData = [];
            
            for(let item in data){
                let currentItem = data[item];                
                let updatedData = { ...data[item]};

                updatedData.picklistValues  = [];

                this.listValuesSave.push(currentItem.fieldMappedKey);
                if (currentItem && currentItem.picklistValues && (currentItem.isMultiPicklist || currentItem.isPicklist)) {
                    console.log({currentItem})
                    let valuesJson = currentItem.picklistValues.split(';');
                    updatedData.picklistValues = valuesJson.map((item) => Object.assign({}, {label: item, value: item}));
                }
                updatedListData.push(updatedData);
            }

            console.log('updatedListData');
            console.log(updatedListData);
            this.tasks = updatedListData;
        }else if(error){
            console.log('ERROR: ' + error.body.message);
        }
    };

    handleSave(){
        console.log('this.listValuesSave: '+ this.listValuesSave);
        var listTaskDetails = [];

        this.template.querySelectorAll(".form-fields").forEach(ele => {
            var objTaskDetails = {};
            let dataId = ele.getAttribute("data-id");
            
            console.log(dataId +"  -   "+ ele.tagName);
            objTaskDetails["FieldKey"+dataId+"__c"] = ele.getAttribute("data-fieldKey");
            objTaskDetails["FieldName"+dataId+"__c"] = ele.getAttribute("data-name");
            objTaskDetails["FieldValue"+dataId+"__c"] = (ele.type == 'checkbox') 
            ? ele.checked.toString() 
            : (ele.tagName == 'LIGHTNING-DUAL-LISTBOX') 
            ? ele.value.join(';') 
            : (ele.tagName == 'C-SEARCH-COMPONENT') ? this.lookupRecordId : ele.value;
            
            
            listTaskDetails.push(objTaskDetails);
        }); 

        this.listRecordsInsert = JSON.parse(JSON.stringify(listTaskDetails));
        this.insertRecord();
    }

    insertRecord(){

        let listFields = this.listRecordsInsert;

        const fields = Object.assign({}, ...listFields);

        const recordInput = {apiName: TASKDETAILS_OBJECT.objectApiName, fields};
        let newRecordId;
        console.log(recordInput);

        createRecord(recordInput)
        .then( taskdetails =>{
            newRecordId = taskdetails.id;

            console.log(taskdetails);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Registro criado com sucesso.',
                    variant: 'success'
                })
            )
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao criar um registro.',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }
    handleLookup(event){
        console.log("AQUI");
        console.log(event.detail.data.recordId );
        this.lookupRecordId = event.detail.data.recordId;
        console.log( JSON.stringify ( event.detail) );
    }
}