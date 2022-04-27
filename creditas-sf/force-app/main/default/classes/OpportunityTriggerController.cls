/***********************************************************************************************************************************
 * Copyright © 2021 Creditas
 * ================================================================================================================================
 * @description Default Controller for trigger OpportunityTrigger
 * ================================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Nathalia Rosa           17/12/2021      Created     Default Controller for trigger OpportunityTrigger
 * 1.1       Matheus Fernandes       17/02/2021      Changed     Calling OpportunityEvaluationController on beforeInsert
 **********************************************************************************************************************************/
public without sharing class OpportunityTriggerController extends TriggerHandler {
    private List<Opportunity> newOpportunities;
    private List<Opportunity> oldOpportunities;
    private Map<Id, Opportunity> newOpportunitiesById;
    private Map<Id, Opportunity> oldOpportunitiesById;

    public OpportunityTriggerController() {
      this.newOpportunities = (List<Opportunity>) Trigger.new;
      this.oldOpportunities = (List<Opportunity>) Trigger.old;
      this.newOpportunitiesById = (Map<Id, Opportunity>) Trigger.newMap;
      this.oldOpportunitiesById = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert() {
      OpportunityEvaluationController.evaluateByOpportunity(newOpportunities);
    }

    public override void afterInsert() {

    }

    public override void beforeUpdate() {
      OpportunityTriggerService.updateIsExternallySynced(newOpportunitiesById, oldOpportunitiesById);
      OpportunityTriggerService.firePlatformEventSynchAccount(newOpportunitiesById);
      OpportunityEvaluationController.evaluateOnUpdate(newOpportunities);
    }

    public override void afterUpdate() {
      OpportunityAssignmentController.handleOpportunitiesAssignment(newOpportunities);
    }
    
      
  }