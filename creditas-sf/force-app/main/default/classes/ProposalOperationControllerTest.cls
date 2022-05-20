@isTest
public class ProposalOperationControllerTest {
    
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
    static void getOperationDetailsTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c result = new OperationSection__c();

        Test.startTest();
        result = ProposalOperationController.getOperationDetails(opp.Id);
        Test.stopTest();

        System.assertEquals('Aprovar', result.BranchStatus__c ,'Incorrect OperationSection value');
    }
    
    @isTest
    static void getOperationDetailsFailTest(){
        Exception testException;
        Account acc = [SELECT Id FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        Test.startTest();
        try{
        	ProposalOperationController.getOperationDetails(opp.Id);
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'An opportunity id should be passed.');
    }

    @isTest
    static void saveOperationDetailsSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c operationSection = [SELECT Id, BranchStatus__c FROM OperationSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        operationSection.BranchStatus__c = 'Rejeitar';            
        
        Test.startTest();
        ProposalOperationController.saveOperationDetails(operationSection);
        Test.stopTest();
        
        OperationSection__c operationUpdated = [SELECT Id, BranchStatus__c FROM OperationSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Rejeitar', operationUpdated.BranchStatus__c,'Incorrect OperationSection value');
    }
    
    @isTest
    static void saveOperationDetailsFailTest(){
        Exception testException;
        
        Account proponent = [SELECT Id, Name FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        proponent.Name = 'Nivaele2';
        
        Test.startTest();
        try{
        	ProposalOperationController.saveOperationDetails(proponent);
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        Account resultProponent = [SELECT Id, Name FROM Account WHERE Id = :proponent.Id LIMIT 1];
        System.assertEquals('System.AuraHandledException', testException.getTypeName(), 'Wrong exception was thrown');
        System.assertEquals('Invalid conversion from runtime type Account to OperationSection__c', testException.getMessage(),'Incorrect Exception message');
        System.assertEquals('Nivaele', resultProponent.Name,'Incorrect Account Name value');

    }
}