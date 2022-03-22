public with sharing class ProfessionalInfoTriggerService {
    
    public static void updateIsExternallySynced(List<ProfessionalInfo__c> newProfessionalInfos, Map<Id, ProfessionalInfo__c> oldProfessionalInfosById)
    {
        Util.updateIsExternallySynced('ProfessionalInfo__c', newProfessionalInfos, oldProfessionalInfosById);
    }

    public static void updateAccountExternalFields(List<ProfessionalInfo__c> newProfessionalInfos)
    {
        Set<Id> accountIds = new Set<Id>();
        
        for(ProfessionalInfo__c professionalInfo : newProfessionalInfos)
        {
             accountIds.add(professionalInfo.Account__c);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :accountIds]);

        for(ProfessionalInfo__c professionalInfo : newProfessionalInfos)
        {
            professionalInfo.ExternalAccountId__c = accounts.get(professionalInfo.Account__c).ExternalId__c;
            professionalInfo.ExternalAccountVersion__c = accounts.get(professionalInfo.Account__c).ExternalVersion__c;
            professionalInfo.ExternalAccountTenant__c = accounts.get(professionalInfo.Account__c).ExternalTenant__c;
        }        
    }
}