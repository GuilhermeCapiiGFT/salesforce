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
    String userId = UserInfo.getUserId();
    String targetId = customQueues[0].CustomSetup__c;
    sendCustomNotification(new Set<String>{userId}, 'start', targetId);
    BatchEvaluateOpportunity batch = new BatchEvaluateOpportunity(evaluation.getQuery(), userId, targetId);
    batchEvaluateSize__c csBatchSize = batchEvaluateSize__c.getOrgDefaults();
    Integer batchSize = String.isBlank(csBatchSize.size__c) ? 666 : Integer.valueOf(csBatchSize.size__c);
		Database.executeBatch(batch, batchSize);
  }

  public static void evaluateOnUpdate(List<Opportunity> opportunities) {
    List<Opportunity> opportunitiesToEvaluate = OpportunityEvaluationService.getPriorityOpportunities( opportunities );
    evaluateByOpportunity(opportunitiesToEvaluate);
  }

  public static void sendCustomNotification(Set<String> userIdSet, String process, String targetId){

    CustomNotificationController.createCustomNotificationBatch(userIdSet, process, targetId);

  }
}