public with sharing class OpportunityEvaluationController {
  public static void evaluateByOpportunity(List<Opportunity> opportunities) {
    List<CustomQueue__c> allCustomQueues = CustomSetupController.selectCustomQueues();

    OpportunityEvaluationService evaluation = new OpportunityEvaluationService();
    evaluation.setPriorityPointsMap(OpportunityEvaluationService.createPriorityPointsMap(allCustomQueues));
    evaluation.setProducts(allCustomQueues);
    evaluation.setOpportunities(opportunities);
    evaluation.evaluateOpportunities();
    evaluation.updateChangedOpportunities();
  }

  public static void evaluateByCustomQueue(List<CustomQueue__c> customQueues) {
    List<CustomQueue__c> allCustomQueues = CustomSetupController.selectCustomQueues();

    OpportunityEvaluationService evaluation = new OpportunityEvaluationService();
    evaluation.setPriorityPointsMap(OpportunityEvaluationService.createPriorityPointsMap(allCustomQueues));
    evaluation.setProducts(customQueues);
    evaluation.selectOpportunities();
    evaluation.evaluateOpportunities();
    evaluation.updateChangedOpportunities();
  }

  public static void evaluateOnUpdate(List<Opportunity> opportunities) {
    List<Opportunity> opportunitiesToEvaluate = OpportunityEvaluationService.filterOpportunitiesToEvaluate(
      opportunities
    );

    evaluateByOpportunity(opportunitiesToEvaluate);
  }
}