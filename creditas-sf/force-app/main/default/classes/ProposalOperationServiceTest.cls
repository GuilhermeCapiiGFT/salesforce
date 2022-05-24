@isTest
public class ProposalOperationServiceTest {
    @TestSetup
    static void makeData(){
        Account accCustomer = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opp = TestSetup.getOpportunity(accCustomer.Id, true);

        OperationSection__c operation = new OperationSection__c();
        operation.Opportunity__c = opp.Id;
        operation.BranchStatus__c = 'Aprovar';
        operation.Agency__c = '11111';
        insert operation;
    }
    
    @isTest
    static void getOperationSectionFromOppSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c result = new OperationSection__c();

        Test.startTest();
        result = ProposalOperationService.getOperationSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals('Aprovar', result.BranchStatus__c ,'Incorrect BranchStatus__c value');
        System.assertEquals('11111', result.Agency__c ,'Incorrect Agency__c value');
    }
    
    @isTest
    static void getOperationSectionFromOppFailTest(){
        Exception testException;
        Account acc = [SELECT Id FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        Test.startTest();
        try{
        	ProposalOperationService.getOperationSectionFromOpp(opp.Id);
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'Opportunity must have a related section record');
    }
    
    @isTest
    static void saveRecordSuccessTest(){
        OperationSection__c opSection = [SELECT Id, Agency__c FROM OperationSection__c LIMIT 1];
        opSection.Agency__c = '00001';

        Test.startTest();
        ProposalOperationService.saveRecord(opSection);
        Test.stopTest();
        OperationSection__c opSectionUpdated = [SELECT Id, Agency__c FROM OperationSection__c LIMIT 1];
        System.assertEquals('00001', opSectionUpdated.Agency__c ,'Incorrect Agency__c value');
    }
        
    @isTest
    static void saveRecordFailTest(){
        String testException;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c operationSection = [SELECT Id, BranchStatus__c FROM OperationSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        operationSection.BranchStatus__c = 'teste';
        
        Test.startTest();
        try{
        	ProposalOperationService.saveRecord(operationSection);
        }catch(Exception e){
            testException = e.getMessage();
        }
        Test.stopTest();
        System.assert(testException.contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST'),'An error message should occur');
    }
}