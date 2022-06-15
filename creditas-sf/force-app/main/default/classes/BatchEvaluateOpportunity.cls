public with sharing class BatchEvaluateOpportunity implements Database.Batchable<sObject>, Database.Stateful{

    public final String query;
    public final String userId;
    public final String targetId;

	public BatchEvaluateOpportunity(String inputQuery, String inputUserId, String inputTargetId) {
        query = inputQuery;
        userId = inputUserId;
        targetId = inputTargetId;
    }
	
	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<Opportunity> oppList) 
	{
		OpportunityEvaluationService evaluation = new OpportunityEvaluationService();
        evaluation.setOpportunities(oppList);
        evaluation.evaluateOpportunities();
        evaluation.updateChangedOpportunitiesBatch();
	}

	public void finish(Database.BatchableContext BC) 
	{
        CustomNotificationController.createCustomNotificationBatch(new Set<String>{userId}, 'finish', targetId);
	}
}