public with sharing class OpportunityEvaluationController {
  public static void evaluateByOpportunity(List<Opportunity> opportunities) {
    OpportunityEvaluationService evaluation = new OpportunityEvaluationService();
    evaluation.setOpportunities(opportunities);
    evaluation.evaluateOpportunities();
    evaluation.updateChangedOpportunities();
  }

  public static void evaluateByCustomQueue(List<CustomQueue__c> customQueues) {
    OpportunityEvaluationService evaluation = new OpportunityEvaluationService();
    evaluation.setProducts(customQueues);
    evaluation.evaluateOpportunities();
    evaluation.updateChangedOpportunities();
  }

  public static void evaluateOnUpdate(List<Opportunity> opportunities) {
    List<Opportunity> opportunitiesToEvaluate = OpportunityEvaluationService.getPriorityOpportunities(
      opportunities
    );

    evaluateByOpportunity(opportunitiesToEvaluate);
  }
}