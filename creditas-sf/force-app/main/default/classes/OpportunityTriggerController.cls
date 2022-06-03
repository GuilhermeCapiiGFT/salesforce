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
    OpportunityTriggerService.firePlatformEventAutoFinContractUpdate(newOpportunitiesById);
    OpportunityEvaluationController.evaluateOnUpdate(newOpportunities);
  }

  public override void afterUpdate() {
    OpportunityAssignmentController.handleOpportunitiesAssignment(newOpportunities);
  }
}