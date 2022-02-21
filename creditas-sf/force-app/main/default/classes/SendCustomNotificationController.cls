public with sharing class SendCustomNotificationController {

    public static void SendCustomNotification(Set<Id> objectIdSet){
        SendCustomNotificationService.sendNotificationOpportunityAtWork(objectIdSet);
    }
}