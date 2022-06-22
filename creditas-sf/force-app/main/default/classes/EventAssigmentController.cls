public without sharing class EventAssigmentController {
   public static void updateOpportunities(){
    List<Opportunity> oppToUpdateList = new List<Opportunity>();
    for(opportunityAssignment__e event : (List<opportunityAssignment__e >) Trigger.new){
        Opportunity opp = new Opportunity(
            ExternalId__c = event.externalId__c,
            StageName = event.stageName__c,
            OwnerId = event.ownerId__c
        );
        oppToUpdateList.add(opp);
    }
    if(oppToUpdateList.isEmpty()) { return; }

    EventAssigmentService.updateOpps(oppToUpdateList);
   }
}