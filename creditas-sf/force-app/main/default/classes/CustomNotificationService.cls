public with sharing class CustomNotificationService {

    @future
    public static void sendCustomNotificationAssignedOpportunity(Set<Id> sObjectIds){
        List<Opportunity> OpportunityList = getOpportunitiesById(sObjectIds);
        
        Id typeId = getCustomNotificationType('opportunityAssigned');
        if(typeId == null){ return; }
        for(Opportunity opp : OpportunityList)
        {
            if(opp.Owner.isActive) {
                Messaging.CustomNotification notification = buildCustomNotification(System.label.OpportunityWasAssigned,System.label.OpportunityWasAssignedTitle,typeId);
                notification.setTargetId(opp.Id); 
                notification.send(new Set<String> { opp.OwnerId });
            }
            
        }
    }

    private static List<Opportunity> getOpportunitiesById(Set<Id> oppIdSet){
        return [SELECT Name,OwnerId,Id,Owner.isActive FROM Opportunity WHERE Id IN : oppIdSet];
    }

    private static String getCustomNotificationType(String recordTypeDevName){
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :recordTypeDevName ]?.Id;
    }

    private static Messaging.CustomNotification buildCustomNotification(String body, String Title, String typeId){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(body);
        notification.setTitle(Title);
        notification.setNotificationTypeId(typeId);
        return notification;
    }

    public static void sendCustomNotificationBatch(Set<String> recipientIds, String process, String targetId){
        String labelBody = process == 'start' ? System.label.BatchStarted : System.label.BatchEnded;
        Id typeId = getCustomNotificationType('evaluateBatch');
        Messaging.CustomNotification notification = buildCustomNotification(labelBody,System.label.BatchTitle,typeId);
                                    notification.setTargetId(targetId);
                                    notification.send(recipientIds);
    }
}