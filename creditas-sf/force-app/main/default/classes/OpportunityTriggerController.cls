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
    private List<Opportunity> lstNewOpportunity;
    private List<Opportunity> lstOldOpportunity;
    private Map<Id, Opportunity> mapNewOpportunity;
    private Map<Id, Opportunity> mapOldOpportunity;
  
    public OpportunityTriggerController() {
      this.lstNewOpportunity = (List<Opportunity>) Trigger.new;
      this.lstOldOpportunity = (List<Opportunity>) Trigger.old;
      this.mapNewOpportunity = (Map<Id, Opportunity>) Trigger.newMap;
      this.mapOldOpportunity = (Map<Id, Opportunity>) Trigger.oldMap;
    }
  
    public override void beforeInsert() {
      OpportunityEvaluationController.evaluateByOpportunity(lstNewOpportunity);
    }
  
    public override void afterInsert() {

    }
  
    public override void beforeUpdate() {
      OpportunityTriggerService.updateIsExternallySynced(mapNewOpportunity,mapOldOpportunity);
      OpportunityTriggerService.firePlatformEventSynchAccount(mapNewOpportunity);
    }
  
    public override void afterUpdate() {
      
    }
  }