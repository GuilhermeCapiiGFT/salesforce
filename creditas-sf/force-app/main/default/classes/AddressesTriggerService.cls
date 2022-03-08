public with sharing class AddressesTriggerService {
   
    public static void updateMethod(List<Addresses__c> lstNewAddresses, Map<Id, Addresses__c> mapOldAddresses)
    {
        Util.updateIsExternallySynced('Addresses__c', lstNewAddresses, mapOldAddresses);
    }

    public static void updateAccountExternalFields(List<Addresses__c> lstNewAddresses)
    {
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Addresses__c varAddress : lstNewAddresses)
        {
             setAccountIds.add(varAddress.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(Addresses__c varAddress : lstNewAddresses)
        {
            varAddress.ExternalAccountId__c = mapAccounts.get(varAddress.Account__c).ExternalId__c;
            varAddress.ExternalAccountVersion__c = mapAccounts.get(varAddress.Account__c).ExternalVersion__c;
            varAddress.ExternalAccountTenant__c = mapAccounts.get(varAddress.Account__c).ExternalTenant__c;
        }        
    }
}