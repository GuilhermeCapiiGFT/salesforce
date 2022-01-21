import { LightningElement, api, wire, track } from 'lwc';
import getRecordType from '@salesforce/apex/TaskDetailsController.getRecordType';

export default class TaskContainer extends LightningElement {

  @api recordId
  @api objectApiName;

  isRecordTypeHome = false;
  isRecordTypeAutoFin = false;

  
  @wire(getRecordType, { taskId: '$recordId' }) getRecordTypeName({ error, data }) {
    if (data) {
      if(data === 'AutoFin') this.isRecordTypeAutoFin = true
      else if(data === 'Home') this.isRecordTypeHome = true
    }
    else if(error) {
      console.log(error)
    }
  }
  
  connectedCallback() {
    console.log('RecordId:', this.recordId);
  }

  
}