public with sharing class SendCustomNotificationService {

    @future
    public static void sendNotificationOpportunityAtWork(Set<Id> opportunityIdSet) {

        List<Opportunity> opportunityList = [SELECT Name,OwnerId,Id,Owner.isActive FROM Opportunity WHERE Id IN : opportunityIdSet];

        Id notificationTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'opportunityAssigned']?.Id;

        for(Opportunity opportunity : opportunityList){

            if(opportunity.Owner.isActive) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('A oportunidade ' + opportunity.Name + ' foi atribuida, favor verificar e analisar');
                notification.setTitle('Oportunidade Atribuida');
                notification.setNotificationTypeId(notificationTypeId);
                notification.setTargetId(opportunity.Id); 
                notification.send(new Set<String> { opportunity.OwnerId });
              
            }

        }

    }

}