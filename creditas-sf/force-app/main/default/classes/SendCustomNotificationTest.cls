@isTest
private with sharing class SendCustomNotificationTest {
    @TestSetup
    static void makeData()
    {
        User user = TestSetup.getUser(false);
        insert user;
        
        Account account = AccountSetup.createAccount('conta', 'Pessoa_Fisica');
        insert account;

        Opportunity opportunityAtWork = OpportunitySetup.createOpportunity(account.Id, 'AtWork');
        opportunityAtWork.OwnerId = user.Id;
        insert opportunityAtWork;
        
    }
    
    @isTest
    private static void sendNotificationTest()
    {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        Set<Id> opportunityIdSet = new Set<Id>{opportunity.Id};
        Test.startTest();    
        SendCustomNotificationController.SendCustomOpportunityNotification(opportunityIdSet);
        Test.stopTest();
    }

}