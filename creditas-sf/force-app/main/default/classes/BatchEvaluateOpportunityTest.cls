@isTest
private with sharing class BatchEvaluateOpportunityTest {
    
    @TestSetup
    static void makeData(){

        Account acc = AccountSetup.createAccount('Batch', 'Pessoa_Fisica');
        insert acc;

        Id recordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', 'AtWork');

        CustomSetup__c cSetup = new CustomSetup__c(
        RecordTypeId = recordTypeId,
        Name = 'Test',
        DateFilter__c = 'CreatedDate'
        );

        insert cSetup;

        Id queueRecordTypeId = Util.getRecordTypeIdbyName('CustomQueue__c', 'AtWork');

        insert new List<CustomQueue__c>{
            new CustomQueue__c(Name = 'DISCHARGING', QueueName__c = 'DISCHARGING', CustomSetup__c = cSetup.Id, Points__c = 10, recordTypeId = queueRecordTypeId),
            new CustomQueue__c(Name = 'REFINANCING', QueueName__c = 'REFINANCING', CustomSetup__c = cSetup.Id, Points__c = 20, recordTypeId = queueRecordTypeId),
            new CustomQueue__c(Name = 'STORE', QueueName__c = 'STORE', CustomSetup__c = cSetup.Id, Points__c = 30, recordTypeId = queueRecordTypeId),
            new CustomQueue__c(Name = 'PAYROLL_LOAN', QueueName__c = 'PAYROLL_LOAN', CustomSetup__c = cSetup.Id, Points__c = 40, recordTypeId = queueRecordTypeId),
            new CustomQueue__c(Name = 'SALARY_ADVANCE', QueueName__c = 'SALARY_ADVANCE', CustomSetup__c = cSetup.Id, Points__c = 50, recordTypeId = queueRecordTypeId),
            new CustomQueue__c(Name = 'PENDENCY_RETURN', QueueName__c = 'PENDENCY_RETURN', CustomSetup__c = cSetup.Id, Points__c = 100, recordTypeId = queueRecordTypeId)
        };
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppLoan = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppLoan.QueueName__c = 'PAYROLL_LOAN';
        oppList.add(oppLoan);
        Opportunity oppRefinancing = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppRefinancing.QueueName__c = 'REFINANCING';
        oppList.add(oppRefinancing);
        Opportunity oppStore = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppStore.QueueName__c = 'STORE';
        oppList.add(oppStore);
        Opportunity oppSalary = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppSalary.QueueName__c = 'SALARY_ADVANCE';
        oppList.add(oppSalary);
        insert oppList;
        
    }

    @isTest
    private static void testBatchApexOneQueue(){
        CustomQueue__c queue = [SELECT Points__c FROM CustomQueue__c WHERE Name = 'PAYROLL_LOAN'];
        queue.Points__c = 75;
        Test.startTest();
        update queue;
        Test.stopTest();
        Opportunity opp = [SELECT PriorityPoints__c FROM Opportunity WHERE QueueName__c = 'PAYROLL_LOAN' LIMIT 1];
        System.assertEquals(75, opp.PriorityPoints__c, 'Wrong points!');
    }

    @isTest
    private static void testBatchApexMultipleQueues(){
        List<CustomQueue__c> queues = [SELECT Points__c FROM CustomQueue__c];
        for(CustomQueue__c cQueue : queues){
            cQueue.Points__c = 77;
        }
        Test.startTest();
        update queues;
        Test.stopTest();
        List<Opportunity> oppList = [SELECT PriorityPoints__c FROM Opportunity];
        for(Opportunity opp : oppList){
            System.assertEquals(77, opp.PriorityPoints__c, 'Wrong points!');
        }
    }
}