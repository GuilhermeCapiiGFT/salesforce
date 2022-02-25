/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Opportunity evaluation - set opportunity priority based on setup record at CustomSetup__c
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       15/02/2021      Created     Class creation
 **********************************************************************************************************************/
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
}