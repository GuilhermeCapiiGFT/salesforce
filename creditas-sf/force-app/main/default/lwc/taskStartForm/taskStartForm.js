import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunity from '@salesforce/apex/TaskDetailsController.getOpportunity';

export default class TaskStartDetails extends NavigationMixin(LightningElement) {
  @api recordId
  
  @track proposalData
  @track proposalName
  @track createdDate
  @track cpf
  @track clientName
  @track accountId
  @track idProposal
  @track vehicleType
  @track proposalIN
  @track entranceDate
  @track shopKeeper
  @track cnpj

  @wire(getOpportunity, { Id: '$recordId' })
  getInformation({ error, data }) {
    if (data) {
      this.proposalData = data
      this.proposalName = this.proposalData.Name
      this.createdDate = this.formatDate(this.proposalData.CreatedDate)
      this.cpf = this.proposalData.Account.DocumentNumber__c
      this.clientName = this.proposalData.Account.Name
      this.accountId = this.proposalData.Account.Id
      this.idProposal = this.proposalData.Id
      //this.entranceDate = this.proposalData
      // this.vehicleType = this.proposalData.
      //this.proposalIN = this.proposalData.
      //this.shopKeeper = this.proposalData.Logista__r.Name
      
      console.log('oportunidade/proposta: ', this.proposalData)

    }
    else if (error) {
      console.log(error)
    }
  }

  connectedCallback(){    
    console.log('RecordId:', this.recordId);

    
    console.log('tyumi teste', this.createdDate)
  }

  viewProposal(event) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            "recordId": event.target.value,
            "objectApiName": "Opportunity",
            "actionName": "view"
        },
    });
  }

  viewFicha(event) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            "recordId": event.target.value,
            "objectApiName": "Account",
            "actionName": "view"
        },
    });
  }

  formatDate(date) {
    let dt = new Date(date)

    const formatter = new Intl.DateTimeFormat('pt-BR', {
      year: 'numeric',
      month: 'numeric',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    })

    let formattedDate = formatter.format(dt)
    
    return formattedDate
  }
}