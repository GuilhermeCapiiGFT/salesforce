/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default Controller for trigger OpportunityProcessTrigger
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     Default Controller for trigger OpportunityProcessTrigger
**********************************************************************************************************************************/
public without sharing class OpportunityProcessTriggerController extends TriggerHandler
{
    private List<OpportunityProcess__c> newOpportunities;
    private List<OpportunityProcess__c> oldOpportunities;
    private Map<Id, OpportunityProcess__c> newOpportunitiesById;
    private Map<Id, OpportunityProcess__c> oldOpportunitiesById;
 
    public OpportunityProcessTriggerController()
    {
        this.newOpportunities = (List<OpportunityProcess__c>) Trigger.new;
        this.oldOpportunities = (List<OpportunityProcess__c>) Trigger.old;
        this.newOpportunitiesById = (Map<Id, OpportunityProcess__c>) Trigger.newMap;
        this.oldOpportunitiesById = (Map<Id, OpportunityProcess__c>) Trigger.oldMap;
    }
   
    public override void beforeInsert()
    {
        OpportunityProcessTriggerService.updateOpportunityExternalFields(newOpportunities);
    }
    
    public override void beforeUpdate()
    {
        OpportunityProcessTriggerService.updateMethod(newOpportunities, oldOpportunitiesById);
        OpportunityProcessTriggerService.updateOpportunityExternalFields(newOpportunities);
    }
}