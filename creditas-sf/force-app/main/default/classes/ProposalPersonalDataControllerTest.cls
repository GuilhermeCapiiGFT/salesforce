@isTest
public with sharing class ProposalPersonalDataControllerTest {
    
    @TestSetup 
    static void makeData() {

        Account varAccount = TestSetup.getAccount('Nivaele', true);

        Opportunity varOpportunity = new Opportunity();
        varOpportunity.AccountId = varAccount.Id;
        varOpportunity.Name = 'Teste';
        varOpportunity.StageName = 'Novo';
        varOpportunity.CloseDate = Date.today().addDays(10);
        varOpportunity.ExternalTenant__c = 'creditasbr';
        varOpportunity.ExternalVersion__c = 1;      
        insert varOpportunity;

        PersonalDataSection__c personalDataRecord = new PersonalDataSection__c();
        personalDataRecord.Opportunity__c = varOpportunity.Id;
        personalDataRecord.NameStatus__c = 'Aprovar';
        personalDataRecord.CPFStatus__c = 'Rejeitar';
        personalDataRecord.BirthCityStatus__c = 'Aprovar';
        personalDataRecord.BirthCountryStatus__c = 'Aprovar';
        personalDataRecord.BirthDateStatus__c = 'Pendenciar';
        personalDataRecord.NationalityStatus__c = 'Pendenciar';
        personalDataRecord.PoliticallyExposedPersonStatus__c = 'Pendenciar';
        insert personalDataRecord;

        Documents__c document = new Documents__c();
        document.Account__c = varAccount.Id;
        document.DocumentType__c = 'RG';
        document.DocumentNumber__c = '43325578';
        document.RecordTypeId = Util.getRecordTypeIdbyName('Documents__c', 'RG');
        insert document;
    }

    @isTest
    static void getPersonalDataSuccess() {
        Opportunity varOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
    
        Map<String, SObject> returnedObject;
        Test.startTest();
        returnedObject = ProposalPersonalDataController.getInfoRecords(varOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, returnedObject.get('dadosPessoais'), 'Result is null');
    }
    
    @isTest
    static void getPersonalDataFail() {
        Opportunity varOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        String exceptionMessage = '';
        Map<String, SObject> returnedObject;
        
        Test.startTest();
        try {
            returnedObject = ProposalPersonalDataController.getInfoRecords('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }
 
    @isTest
    static void getDocumentsSuccess(){
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1];
    
        Map<String, SObject> returnedObject;
        Test.startTest();
        returnedObject = ProposalPersonalDataController.getDocuments(varAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, returnedObject.get('RG'), 'Result is null');
    }
    
    @isTest
    static void getDocumentsFail() {
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        String exceptionMessage = '';
        Map<String, SObject> returnedObject;
        
        Test.startTest();
        try {
            returnedObject = ProposalPersonalDataController.getDocuments('123456778');
        }catch(Exception e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }
}