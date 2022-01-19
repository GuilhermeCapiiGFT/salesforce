public with sharing class SynchAccountController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(Id accountId) {
        return [SELECT IsSynchEnabled__c FROM Account WHERE Id =:accountId];
    }
}