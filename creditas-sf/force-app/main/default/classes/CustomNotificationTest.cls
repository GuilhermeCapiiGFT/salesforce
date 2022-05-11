@isTest
private with sharing class CustomNotificationTest {
    
    @TestSetup
    static void makeData(){
        Account acc = AccountSetup.createAccount('Test Notification', 'Pessoa_Fisica');
        insert acc;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppTest1 = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        oppList.add(oppTest1);
        Opportunity oppTest2 = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppList.add(oppTest2);
        insert oppList;
    }

    @isTest
    private static void testSendCustomNotification(){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        Map<String,List<SObject>> mapTest = new Map<String,List<SObject>>{'Opportunity' => oppList};
        Test.startTest();
        CustomNotificationController.createCustomNotification(mapTest);
        Test.stopTest();
    }
}