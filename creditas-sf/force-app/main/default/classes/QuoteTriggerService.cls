public with sharing class QuoteTriggerService {

    public static void updateOpportunityExternalFields(List<Quote> lstNewQuotes)
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for(Quote varQuotes : lstNewQuotes)
        {
            setOpportunityIds.add(varQuotes.OpportunityId);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);

        for(Quote varQuotes : lstNewQuotes)
        {
            varQuotes.ExternalOpportunityId__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalId__c;
            varQuotes.ExternalOpportunityVersion__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalVersion__c;
            varQuotes.ExternalOpportunityTenant__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalTenant__c;
        }        
    }
}