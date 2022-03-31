import { LightningElement, api, wire } from 'lwc';
import { subscribe } from 'lightning/empApi';
import {
  getRecord,
  updateRecord,
  getFieldValue,
  generateRecordInputForUpdate,
  getRecordNotifyChange
} from 'lightning/uiRecordApi';

import SYNC_ENABLED_FIELD from '@salesforce/schema/Employee__c.IsSynchEnabled__c';
import EXT_SYNC_FIELD from '@salesforce/schema/Employee__c.IsExternallySynched__c';

const EMPLOYEE_FIELDS = [SYNC_ENABLED_FIELD, EXT_SYNC_FIELD];

export default class SynchEmployeeData extends LightningElement {
  @api recordId;
  channelName = '/event/SynchEmployee__e';
  employee;
  error;

  @wire(getRecord, { recordId: '$recordId', fields: EMPLOYEE_FIELDS })
  parseEmployee({ data, error }) {
    if (data) {
      this.employee = data;
    } else if (error) {
      this.error = error;
    }
  }

  get isEnabled() {
    const syncEnabled = getFieldValue(this.employee, SYNC_ENABLED_FIELD);
    return syncEnabled === 'ENABLED';
  }

  get isSynching() {
    const syncEnabled = getFieldValue(this.employee, SYNC_ENABLED_FIELD);
    return syncEnabled === 'SYNCHING';
  }

  connectedCallback() {
    this.subscribeSynchEmployeeEvent(this);
  }

  handleClick() {
    const record = generateRecordInputForUpdate(this.employee);
    record.fields[SYNC_ENABLED_FIELD.fieldApiName] = 'SYNCHING';
    record.fields[EXT_SYNC_FIELD.fieldApiName] = false;
    updateRecord(record).catch(error => (this.error = error));
  }

  subscribeSynchEmployeeEvent(component) {
    const callback = function () {
      component.notifyChange();
    };

    subscribe(component.channelName, -1, callback).then(response => {
      component.subscription = response;
    });
  }

  notifyChange() {
    getRecordNotifyChange([{ recordId: this.recordId }]);
  }
}