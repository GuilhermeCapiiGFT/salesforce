import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNTID_FIELD from '@salesforce/schema/Opportunity.AccountId';

export default class FichaFormalizacao extends LightningElement {
  @api recordId
  account
  accountId

  @wire(getRecord, { recordId: '$recordId', fields: ACCOUNTID_FIELD })
  wiredRecord({ error, data }) {
    if (data) {
      this.account = data
      this.accountId = this.account.fields.AccountId.value
    } else if (error) {
      let message = 'Erro desconhecido'
      if (Array.isArray(error.body)) {
        message = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error loading contact',
            message,
            variant: 'error',
        }),
      );
    }
  }


}