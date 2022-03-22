public with sharing class OpportunityProcessTriggerService {
    
    public static void updateMethod(List<OpportunityProcess__c> newOpportunities, Map<Id, OpportunityProcess__c> oldOpportunitiesById)
    {
        Util.updateIsExternallySyncedOpportunity('OpportunityProcess__c', newOpportunities, oldOpportunitiesById);
    }

    public static void updateOpportunityExternalFields(List<OpportunityProcess__c> newOpportunities)
    {
        Set<Id> opportunityIds = new Set<Id>();
        
        for(OpportunityProcess__c opportunityProcess : newOpportunities)
        {
            opportunityIds.add(opportunityProcess.Opportunity__c);
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :opportunityIds]);

        for(OpportunityProcess__c opportunityProcess : newOpportunities)
        {
            opportunityProcess.ExternalOpportunityId__c = opportunities.get(opportunityProcess.Opportunity__c).ExternalId__c;
            opportunityProcess.ExternalOpportunityVersion__c = opportunities.get(opportunityProcess.Opportunity__c).ExternalVersion__c;
            opportunityProcess.ExternalOpportunityTenant__c = opportunities.get(opportunityProcess.Opportunity__c).ExternalTenant__c;
        }        
    }
}