public with sharing class FinancialResourcesTriggerService {

    public static void updateIsExternallySynced(List<FinancialResources__c> lstNewFinancialResources){
        List<String> trackedFields = Util.returnCustomMetadaDataFieldApiName('FinancialResources__c');
        Set<Id> changedFinancialResourceIdSet = new Set<Id>();
        for(FinancialResources__c iFinancialResource : lstNewFinancialResources){
            if(TriggerHelper.changedField(iFinancialResource, trackedFields)){
                changedFinancialResourceIdSet.add(iFinancialResource.Id);
            }
        }

        if(changedFinancialResourceIdSet.isEmpty()) { return; }

        List<Account> accountToUpdateList = new List<Account>();

        for(AccountFinancialRelationship__c accountFinancialRelationship : [SELECT Account__c,Account__r.IsExternallySynched__c,Account__r.ExternalId__c FROM AccountFinancialRelationship__c WHERE Recurso_Financeiro__c IN : changedFinancialResourceIdSet]){
            if(String.isNotBlank(accountFinancialRelationship.Account__c)){
                Account accountToUpdate = new Account(
                    Id = accountFinancialRelationship.Account__c,
                    IsExternallySynched__c = false
                );
                accountToUpdateList.add(accountToUpdate);
            }
        }

        if(accountToUpdateList.isEmpty()) { return; }
        
        TriggerHandler.bypass('AccountTriggerController');
        upsert accountToUpdateList;
        TriggerHandler.clearBypass('AccountTriggerController');
        
    }
}
