import { LightningElement } from 'lwc';

export default class CustomLookup extends LightningElement {
    fields = ["FirstName__c"];
    displayFields = 'FirstName__c'

    handleLookup(event){
        console.log( JSON.stringify ( event.detail) )
    }
}