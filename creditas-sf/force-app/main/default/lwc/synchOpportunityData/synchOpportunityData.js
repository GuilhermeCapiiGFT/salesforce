import { LightningElement, track, api, wire } from 'lwc';
import getSyncInfo from '@salesforce/apex/SynchOpportunityDataController.getSyncInfo';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import updateSynchingFields from '@salesforce/apex/SynchOpportunityDataController.updateSynchingFields';


export default class SynchOpportunityData extends LightningElement {
    @api channelName = '/event/SynchOpportunity__e';
    subscription = {};

    @api recordId;

    @track opportunity;
    @track error;
    @track showSynchOppButton = false;
    @track showComponent = false;
    @track showSynchingScreen = false;
    @track showEventReceived = false;
    

    connectedCallback(){
        let myComponent = this;
        this.subscribeSynchOpportunityEvent(myComponent)

        getSyncInfo({oppId: this.recordId}) 
            .then(result => { 
                this.opportunity = result;
                 if(this.opportunity.IsSynchEnabled__c == 'DISABLED' || !this.opportunity.IsSynchEnabled__c || result.IsSynchEnabled__c == 'ENABLED'){
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