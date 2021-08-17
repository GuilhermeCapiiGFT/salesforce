public with sharing class SynchAccountDataController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(Id accountId) {
       System.debug(accountId);
        return [SELECT IsSynchEnabled__c, name FROM Account WHERE Id =:accountId][0];         
    }

    @AuraEnabled
    public static void checkSynchingField(Account acc) {
        // acc.IsSynchEnabled__c = 'SYNCHING';
        Account accToUpdate = new Account(
            Id = acc.Id,
            IsSynchEnabled__c = 'SYNCHING'
        );
        update accToUpdate;
    }
}