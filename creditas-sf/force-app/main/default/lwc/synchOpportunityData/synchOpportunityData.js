import { LightningElement, api } from 'lwc';
import { subscribe } from 'lightning/empApi';
import getSyncInfo from '@salesforce/apex/SynchOpportunityDataController.getSyncInfo';
import updateSynchingFields from '@salesforce/apex/SynchOpportunityDataController.updateSynchingFields';

export default class SynchOpportunityData extends LightningElement {
    @api recordId;
    channelName = '/event/SynchOpportunity__e';
    subscription = {};
    opportunity;
    error;
    showSynchButton = false;
    showSynchingScreen = false;
    showEventReceived = false;

    connectedCallback(){
        let myComponent = this;
        this.subscribeSynchOpportunityEvent(myComponent)

        getSyncInfo({oppId: this.recordId}) 
            .then(result => { 
                this.opportunity = result;
                 if(this.opportunity.IsSynchEnabled__c == 'DISABLED' || !this.opportunity.IsSynchEnabled__c){
                    this.showSynchButton = true;
                } else if (this.opportunity.IsSynchEnabled__c == 'SYNCHING'){
                    this.showSynchingScreen = true;
                } else if (result.IsSynchEnabled__c == 'ENABLED'){
                    this.showEventReceived = true;
                }
        })
        .catch(error => {
            this.error = error;
        });
    }

    clickHandler(){
        updateSynchingFields({opp: this.opportunity}) 
            .then(result => { 
                this.showSynchButton = false;
                this.showSynchingScreen = true;
            })
            .catch(error => {
                this.error = error;
            });
    }

    subscribeSynchOpportunityEvent(myComponent){
        const messageCallback = function(response) {
            myComponent.showSynchingScreen = false;
            myComponent.showEventReceived = true;
        };

        subscribe(myComponent.channelName, -1, messageCallback)       
        .then(response => {
            myComponent.subscription = response;
        });
    }
}