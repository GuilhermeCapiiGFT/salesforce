@isTest
public with sharing class SObjectUtilsTest {
    
    @TestSetup
    static void makeData(){
        Account varAccount = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opportunity        = new Opportunity();
        opportunity.AccountId          = varAccount.Id;
        opportunity.Name               = 'Teste';
        opportunity.StageName          = 'Novo';
        opportunity.CloseDate          = Date.today().addDays(10);
        opportunity.ExternalTenant__c  = 'creditasbr';
        opportunity.ExternalVersion__c = 1;      
        insert opportunity;
        
        Documents__c rgDocument      = new Documents__c();
        rgDocument.Account__c        = varAccount.Id;
        rgDocument.DocumentType__c   = 'RG';
        rgDocument.DocumentNumber__c = '43325578';
        rgDocument.RecordTypeId      = Util.getRecordTypeIdbyName('Documents__c', 'RG');
        insert rgDocument;

        Documents__c cnhDocument      = new Documents__c();
        cnhDocument.Account__c        = varAccount.Id;
        cnhDocument.DocumentType__c   = 'CNH';
        cnhDocument.DocumentNumber__c = '1123432432565';
        cnhDocument.RecordTypeId      = Util.getRecordTypeIdbyName('Documents__c', 'CNH');
        insert cnhDocument;
        
    }

    @isTest
    static void upsertRecordsSuccess() {
        List<Documents__c> documents = [SELECT Id, Name, DocumentType__c, DocumentNumber__c FROM Documents__c];
        Documents__c rg = new Documents__c();
        Documents__c cnh = new Documents__c();

        for(Documents__c document : documents) 
        {
            if(document.DocumentType__c.equals('RG')) 
            {
                rg = document;
                rg.DocumentNumber__c = '33222445';
            } else {
                cnh = document;
                cnh.DocumentNumber__c = '99984432';
            }
        }

        Test.startTest();
        SObjectUtils.upsertRecords(documents);
        Test.stopTest();

        System.assertEquals(rg.DocumentNumber__c, '33222445', 'RG number not successfully updated.');
    }

    @isTest
    static void upsertRecordSuccess() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PersonalDataSection__c personalDataSection = new PersonalDataSection__c();
        personalDataSection.CPFStatus__c = 'Approved';
        personalDataSection.Opportunity__c = opp.Id;

        Test.startTest();
        SObjectUtils.upsertRecord(personalDataSection);
        Test.stopTest();

        System.assertEquals(personalDataSection.CPFStatus__c, 'Approved', 'CPFStatus with wrong value.');
    }

    @isTest
    static void upsertRecordsFail() {
        Account account = [SELECT Id FROM Account];
        List<Documents__c> documents = [SELECT Id, Account__c, DocumentType__c, Name FROM Documents__c WHERE DocumentType__c = 'RG'];

        String exceptionMessage = '';
        
        Test.startTest();
            try {
                documents[0].Account__c = '123456778';
                SObjectUtils.upsertRecords(documents);
            } catch (Exception e) {
                exceptionMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }

    @isTest
    static void upsertRecordFail() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PersonalDataSection__c personalDataSection = new PersonalDataSection__c();
        personalDataSection.CPFStatus__c = 'Aprovado';
        personalDataSection.Opportunity__c = opp.Id;

        String exceptionMessage = '';

        Test.startTest();
        try {
            SObjectUtils.upsertRecord(personalDataSection);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert( exceptionMessage != null);
    }
}