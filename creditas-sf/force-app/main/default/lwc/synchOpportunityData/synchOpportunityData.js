import { LightningElement, track, api, wire } from 'lwc';
import getSyncInfo from '@salesforce/apex/SynchOpportunityDataController.getSyncInfo';
import updateSynchingFields from '@salesforce/apex/SynchOpportunityDataController.updateSynchingFields';


export default class SynchOpportunityData extends LightningElement {

    //API
    @api recordId;

    //Track
    @track opportunity;
    @track error;
    @track showSynchOppButton = false;
    @track showComponent = false;
    @track showSynchingScreen = false;
    

    connectedCallback(){
        let myComponent = this;

        //this.subscribeSynchOppEvent(myComponent);

        getSyncInfo({oppId: this.recordId}) 
            .then(result => { 
                this.opportunity = result;
                 if(this.opportunity.IsSynchEnabled__c == 'DISABLED' || !this.opportunity.IsSynchEnabled__c){
                    this.showComponent = true;
                    this.showSynchOppButton = true;
                } else if (this.opportunity.IsSynchEnabled__c == 'SYNCHING'){
                    this.showComponent = true;
                    this.showSynchingScreen = true;
            }
        })
        .catch(error => {
            this.error = error;
        });
}

    clickHandler(){
        updateSynchingFields({opp: this.opportunity}) 
            .then(result => { 
                this.showComponent = true;
                this.showSynchOppButton = false;
                this.showSynchingScreen = true;
            })
            .catch(error => {
                this.error = error;
            });
    }

}