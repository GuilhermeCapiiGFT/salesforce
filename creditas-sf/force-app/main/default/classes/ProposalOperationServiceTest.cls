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
    static void getOperationSectionSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c result = new OperationSection__c();

        Test.startTest();
        result = ProposalOperationService.getOperationSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals('Aprovar', result.BranchStatus__c ,'Incorrect BranchStatus__c value');
        System.assertEquals('11111', result.Agency__c ,'Incorrect Agency__c value');
    }
    
    @isTest
    static void saveOperationSectionTest(){
        OperationSection__c opSection = [SELECT Id, Agency__c FROM OperationSection__c LIMIT 1];
		opSection.Agency__c = '00001';
		
        Test.startTest();
        ProposalOperationService.saveRecord(opSection);
        Test.stopTest();
        OperationSection__c opSectionUpdated = [SELECT Id, Agency__c FROM OperationSection__c LIMIT 1];
        System.assertEquals('00001', opSectionUpdated.Agency__c ,'Incorrect Agency__c value');
    }

}