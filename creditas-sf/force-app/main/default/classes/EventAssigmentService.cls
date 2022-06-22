public without sharing class EventAssigmentService {
    public static void updateOpps (List<Opportunity> oppToUpdateList){

        Schema.SObjectField oppExternalIdField = Opportunity.Fields.ExternalId__c;
        TriggerHandler.bypass('OpportunityTriggerController');
        Database.upsert(oppToUpdateList, oppExternalIdField, false);
    }
}