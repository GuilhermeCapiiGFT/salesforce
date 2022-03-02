@isTest
private with sharing class DocumentsTriggerTest {

    @TestSetup
    static void makeData()
    {    
        Account account = AccountSetup.createAccount('Franscisco', 'Pessoa_Fisica');
        account.IsExternallySynched__c = true;
        insert account;
        
        Documents__c varDocument = DocumentSetup.generateDocment(account.Id,'CPF');
        insert varDocument;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Documents__c varDocument = [SELECT Account__c FROM Documents__c WHERE DocumentType__c = 'CPF' LIMIT 1]; 

        varDocument.IssueDate__c = Date.today().addDays(6);
        varDocument.IssuerState__c = 'MG';
        varDocument.DocumentNumber__c = DocumentGenerator.generateCPF();
        varDocument.Issuer__c = 'SSP';
    
        Test.startTest();
        update varDocument;
        Test.stopTest();

        Account varAccount = [SELECT isExternallySynched__C
                              FROM Account
                              WHERE Id =: varDocument.Account__c
                              LIMIT 1];

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultipleDocumentsSameAccount()
    {
        List<Documents__c> documentList = new List<Documents__c>();
        Documents__c documentCPF = [SELECT Account__c FROM Documents__c WHERE IssueDate__c = :Date.today() LIMIT 1];
        documentList.add(documentCPF);
        Documents__c documentRG = DocumentSetup.generateDocment(documentCPF.Account__c,'RG');
        insert documentRG;
        documentList.add(documentRG);

        for(Documents__c iDocument : documentList){
            iDocument.IssuerState__c = 'BA';
            iDocument.DocumentNumber__c = DocumentGenerator.generateCPF();
        }
        Test.startTest();
            update documentList;
        Test.stopTest();

        Account varAccount = [SELECT isExternallySynched__C
                              FROM Account
                              WHERE Id =: documentCPF.Account__c
                              LIMIT 1];

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');

    }

        

}
