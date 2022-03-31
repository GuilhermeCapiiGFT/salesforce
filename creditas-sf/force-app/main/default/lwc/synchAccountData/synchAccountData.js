import { LightningElement, api, wire } from 'lwc';
import { subscribe } from 'lightning/empApi';
import {
  getRecord,
  updateRecord,
  getFieldValue,
  generateRecordInputForUpdate,
  getRecordNotifyChange
} from 'lightning/uiRecordApi';

import SYNC_ENABLED_FIELD from '@salesforce/schema/Account.IsSynchEnabled__c';
import EXT_SYNC_FIELD from '@salesforce/schema/Account.IsExternallySynched__c';

const ACCOUNT_FIELDS = [SYNC_ENABLED_FIELD, EXT_SYNC_FIELD];

export default class SynchAccountData extends LightningElement {
  @api recordId;
  channelName = '/event/SynchAccount__e';
  account;
  error;

  @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
  parseAccount({ data, error }) {
    if (data) {
      this.account = data;
    } else if (error) {
      this.error = error;
    }
  }

  get isEnabled() {
    const syncEnabled = getFieldValue(this.account, SYNC_ENABLED_FIELD);
    return syncEnabled === 'ENABLED';
  }

  get isSynching() {
    const syncEnabled = getFieldValue(this.account, SYNC_ENABLED_FIELD);
    return syncEnabled === 'SYNCHING';
  }

  connectedCallback() {
    this.subscribeSynchAccountEvent(this);
  }

  handleClick() {
    const record = generateRecordInputForUpdate(this.account);
    record.fields[SYNC_ENABLED_FIELD.fieldApiName] = 'SYNCHING';
    record.fields[EXT_SYNC_FIELD.fieldApiName] = false;
    updateRecord(record).catch(error => (this.error = error));
  }

  subscribeSynchAccountEvent(component) {
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