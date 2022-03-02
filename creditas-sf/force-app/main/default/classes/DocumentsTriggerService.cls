public with sharing class DocumentsTriggerService {
    
    public static void updateIsExternallySynced(List<Documents__c> lstNewDocuments, Map<Id,Documents__c> mapOldDocuments){
        Util.updateIsExternallySynced('Documents__c', lstNewDocuments, mapOldDocuments);
    }

    public static void updateAccountExternalFields(List<Documents__c> lstNewDocuments){
        
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Documents__c varDocuments : lstNewDocuments)
        {
             setAccountIds.add(varDocuments.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(Documents__c varDocuments : lstNewDocuments)
        {
            varDocuments.ExternalAccountId__c = mapAccounts.get(varDocuments.Account__c).ExternalId__c;
            varDocuments.ExternalAccountVersion__c = mapAccounts.get(varDocuments.Account__c).ExternalVersion__c;
            varDocuments.ExternalAccountTenant__c = mapAccounts.get(varDocuments.Account__c).ExternalTenant__c;
        }        
    }
}
