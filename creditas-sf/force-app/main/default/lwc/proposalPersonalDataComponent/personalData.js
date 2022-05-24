/**
 * @author Otávio Frank - GFT Brasil
 */

export const politicallyExposedOptions = [
    { label: 'Sim', value: 'true' }, 
    { label: 'Não', value: 'false' }
];

export const observationByStatus = new Map([
    ['BirthDateStatus__c','BirthDateObservation__c'],
    ['CPFStatus__c','CPFObservation__c'],
    ['RGStatus__c','RGobservation__c'],
    ['CNHnumberStatus__c','CNHnumberObservation__c'],
    ['CNHdispatchDateStatus__c','CNHdispatchDateObservation__c'],
    ['PoliticallyExposedPersonStatus__c', 'PoliticallyExposedPersonObservation__c']
]);

export const disabledFields = {
    name : false,
    father : false,
    mother : false,
    birthdate : false,
    cpf : false,
    birthCity : false,
    birthCountry : false,
    nationality  : false,
    politicallyExposed : false,
    rg : false,
    issuer : false,
    issueDate : false,
    issuerState : false,
    cnhNumber : false,
    cnhIssueDate  : false,
    cnhIssuer : false
};