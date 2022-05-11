public with sharing class CustomNotificationService {

    @future
    public static void sendCustomNotificationOpportunity(Set<Id> sObjectIds){
        List<Opportunity> OpportunityList = [SELECT Name,OwnerId,Id,Owner.isActive FROM Opportunity WHERE Id IN : sObjectIds];
        
        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'opportunityAssigned']?.Id;
        for(Opportunity opp : OpportunityList)
        {
            if(opp.Owner.isActive) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody(System.label.OpportunityWasAssigned);
                notification.setTitle(System.label.OpportunityWasAssignedTitle);
                notification.setNotificationTypeId(typeId);
                notification.setTargetId(opp.Id); 
                notification.send(new Set<String> { opp.OwnerId });
            }
            
        }
    }
}