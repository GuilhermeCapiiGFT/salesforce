public with sharing class AccFinRelationshipTriggerService {
    public static void updateIsExternallySynced(List<AccountFinancialRelationship__c> lstNewAccountFinancialRelationship) {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountsToUpdateIds = new Set<Id>();

        for (AccountFinancialRelationship__c accFinancialRelationship : lstNewAccountFinancialRelationship) {
            String accountId = accFinancialRelationship?.Account__c;
            if (String.isNotBlank(accountId) && !accountsToUpdateIds.contains(accountId))
            {
                accountsToUpdateIds.add(accountId);
                
                accountsToUpdate.add(new Account(
                    Id = accountId,
                    IsExternallySynched__c = false
                ));
            }
        }
        TriggerHandler.bypass('AccountTriggerController');
        update accountsToUpdate;
        TriggerHandler.clearBypass('AccountTriggerController');
    }
}
