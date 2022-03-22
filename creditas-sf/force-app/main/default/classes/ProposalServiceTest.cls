@isTest
public with sharing class ProposalServiceTest {

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
    }

    @isTest
    private static void getPersonalDataRecord() {

        Opportunity varOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        Map<String, SObject> returnedObject;
        Test.startTest();
        returnedObject = ProposalService.getPersonalDataSectionRecord(varOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, returnedObject.get('dadosPessoais'), 'Result is null');
    }

    @isTest
    private static void resultDocumentBlank() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String, SObject> resultDocuments = new Map<String, SObject>();
            
        Test.startTest();
        resultDocuments = ProposalService.getDocuments(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, resultDocuments.isEmpty(),'Map result should be blank');    
    }

    @isTest
    static void resultDocumentNotBlank(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,SObject> resultDocument = new Map<String,SObject>();
        Documents__c document = new Documents__c(Account__c = acc.Id, DocumentType__c = 'RG', DocumentNumber__c = '983943');
        document.RecordTypeId = Util.getRecordTypeIdbyName('Documents__c', 'RG');

        insert document;

        Test.startTest();
        resultDocument = ProposalService.getDocuments(acc.Id);
        Test.stopTest();
        
        System.assertEquals(document.DocumentNumber__c, resultDocument.get('RG').get('DocumentNumber__c'), 'Incorrect Document number');
    }
}