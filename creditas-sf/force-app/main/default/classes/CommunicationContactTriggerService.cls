public with sharing class CommunicationContactTriggerService {
    
    public static void updateIsExternallySynced(List<CommunicationContacts__c> lstNewCommunicationContact, Map<Id, CommunicationContacts__c> mapOldCommunicationContact)
    {
        Util.updateIsExternallySynced('CommunicationContacts__c', lstNewCommunicationContact, mapOldCommunicationContact);
    }
    
    public static void updateAccountExternalFields(List<CommunicationContacts__c> lstNewCommunicationContact)
    {
        Set<Id> setAccountIds = new Set<Id>();
        
        for(CommunicationContacts__c varComunicationContacts : lstNewCommunicationContact)
        {
             setAccountIds.add(varComunicationContacts.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(CommunicationContacts__c varComunicationContacts : lstNewCommunicationContact)
        {
            varComunicationContacts.ExternalAccountId__c = mapAccounts.get(varComunicationContacts.Account__c).ExternalId__c;
            varComunicationContacts.ExternalAccountVersion__c = mapAccounts.get(varComunicationContacts.Account__c).ExternalVersion__c;
            varComunicationContacts.ExternalAccountTenant__c = mapAccounts.get(varComunicationContacts.Account__c).ExternalTenant__c;
        }        
    }
}