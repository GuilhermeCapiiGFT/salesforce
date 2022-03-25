import { LightningElement, api } from 'lwc';
import { subscribe } from 'lightning/empApi';
import getAccountData from '@salesforce/apex/SynchAccountDataController.getAccountData';
import checkSynchingField from '@salesforce/apex/SynchAccountDataController.checkSynchingField';

export default class SynchAccountData extends LightningElement {
    @api recordId;
    channelName = '/event/SynchAccount__e';
    subscription = {};
    account;
    error;
    showSynchButton = false;
    showSynchingScreen = false;
    showEventReceived = false;

    connectedCallback(){
        let myComponent = this;
        this.subscribeSynchAccountEvent(myComponent)

        getAccountData({accountId: this.recordId}) 
            .then(result => { 
                this.account = result;
                if (result.IsSynchEnabled__c == 'DISABLED' || !result.IsSynchEnabled__c){
                    this.showSynchButton = true;
                } else if (result.IsSynchEnabled__c == 'SYNCHING'){
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
        checkSynchingField({acc: this.account}) 
            .then(result => { 
                this.showSynchButton = false;
                this.showSynchingScreen = true;
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    subscribeSynchAccountEvent(myComponent){
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