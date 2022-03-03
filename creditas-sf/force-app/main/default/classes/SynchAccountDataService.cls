public with sharing class SynchAccountDataService {
    
    public static Account queryAccountData(String accountId){
        return [SELECT IsSynchEnabled__c, name FROM Account WHERE Id =:accountId LIMIT 1];
    }

    public static void updateSynchingField(Account account){
        account.IsSynchEnabled__c = 'SYNCHING';
        update account;
    }
    
}
