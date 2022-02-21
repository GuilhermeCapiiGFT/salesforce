public with sharing class SendCustomNotificationController {

    public static void SendCustomOpportunityNotification(Set<Id> objectIdSet){
        SendCustomNotificationService.sendNotificationOpportunityAtWork(objectIdSet);
    }
}