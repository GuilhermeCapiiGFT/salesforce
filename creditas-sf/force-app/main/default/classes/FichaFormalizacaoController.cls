public with sharing class FichaFormalizacaoController {
   
    @AuraEnabled(cacheable=true)
    public static Map<String, List<SObject>> getRecords(String accountId)
    {
        Map<String, List<SObject>> mapSObjectList = new Map<String, List<SObject>>();
        Set<Id> setFinancialResourceIds = new Set<Id>();

        List<Documents__c> listDocuments = [SELECT Id, Name, Account__c, DocumentType__c FROM Documents__c WHERE Account__c =: accountId];

        List<ProfessionalInfo__c> listProfessionalInfo = [SELECT Id, Name, JobTitle__c, Status__c FROM ProfessionalInfo__c WHERE Account__c =: accountId];

        List<CommunicationContacts__c> listCommunicationContacts = [SELECT Id, Name, Code__c, Type__c, Channel__c FROM CommunicationContacts__c WHERE Account__c =: accountId];
                                                                    
        List<Addresses__c> listAddresses = [SELECT Id, Name, Street__c FROM Addresses__c WHERE Account__c =: accountId];

        List<AccountFinancialRelationship__c> listAccFinancialRel = [SELECT Id, Name, Recurso_Financeiro__c, Account__c FROM AccountFinancialRelationship__c WHERE Account__c =: accountId];

        if(!listAccFinancialRel.isEmpty())
        {
            for(AccountFinancialRelationship__c varAccFinancialRel : listAccFinancialRel)
            {
                setFinancialResourceIds.add(varAccFinancialRel.Recurso_Financeiro__c);
            }
        }

        List<FinancialResources__c> listFinancialResources = [SELECT Id, Name, Type__c, Amount__c FROM FinancialResources__c WHERE Id = : setFinancialResourceIds];

        mapSObjectList.put('documents', listDocuments);
        mapSObjectList.put('professionalInfo', listProfessionalInfo);
        mapSObjectList.put('communicationContacts', listCommunicationContacts);
        mapSObjectList.put('addresses', listAddresses);
        mapSObjectList.put('financialResources', listFinancialResources);
        
        return mapSObjectList;
    }
}