public with sharing class SynchAccountDataController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(Id accountId) {
        return [SELECT IsSynchEnabled__c, name FROM Account WHERE Id =:accountId][0];         
    }

    @AuraEnabled
    public static void checkSynchingField(Account acc) {
        Account accToUpdate = new Account(
            Id = acc.Id,
            IsSynchEnabled__c = 'SYNCHING'
        );
        update accToUpdate;
    }
}