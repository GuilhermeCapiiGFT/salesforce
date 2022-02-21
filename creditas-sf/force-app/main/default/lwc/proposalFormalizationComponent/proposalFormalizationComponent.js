import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNTID_FIELD from '@salesforce/schema/Opportunity.AccountId';

export default class ProposalFormalizationComponent extends LightningElement {
  @api recordId
  account
  accountId
  showContract = false;

  handlerAnaylisApprovement() {

    let openSections = this.template.querySelectorAll("section")

    openSections.forEach(section => {
      section.classList.remove('slds-is-open')
    })

    console.log('open sections:')
    console.log(openSections.length)

    this.showContract = true
  }

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

  handleClick(){
    this.showContract = true;
  }

}