import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getAccountData from '@salesforce/apex/SynchAccountDataController.getAccountData';
import checkSynchingField from '@salesforce/apex/SynchAccountDataController.checkSynchingField';

export default class SynchAccountData extends LightningElement {
    @api channelName = '/event/SynchAccount__e';
    subscription = {};
    
    @track account;
    @track error;
    @api recordId;
    @track showSynchButton = false;
    @track showComponent = false;
    @track showSynchingScreen = false;
    @track showEventReceived = false;
    


    connectedCallback(){
        let myComponent = this;

        this.subscribeSynchAccountEvent(myComponent)
        // var messageCallback = function(response) {
        //     console.log('evento recxebido');
        //     updateScreen();
        // };

        // subscribe(this.channelName, -1, messageCallback)       
        // .then(response => {
        //     console.log('Subscription request sent to: ', JSON.stringify(response.channel));
        //     this.subscription = response;
        // });
            
            

        getAccountData({accountId: this.recordId}) 
            .then(result => { 
                this.account = result;
                if (result.IsSynchEnabled__c == 'DISABLED' || !result.IsSynchEnabled__c || result.IsSynchEnabled__c == 'ENABLED'){
                    this.showComponent = true;
                    this.showSynchButton = true;
                } else if (result.IsSynchEnabled__c == 'SYNCHING'){
                    this.showComponent = true;
                    this.showSynchingScreen = true;
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
            console.log('evento recebido');
            myComponent.showSynchingScreen = false;
            myComponent.showEventReceived = true;
        };

        subscribe(myComponent.channelName, -1, messageCallback)       
        .then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            myComponent.subscription = response;
        });
    }

}