/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe DocumentsTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o DocumentsTriggerHandlerTest
**********************************************************************************************************************************/
@isTest
public class DocumentsTriggerHandlerTest {
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = true;
        
        Documents__c varDocument = new Documents__c();
        varDocument.Account__c = varAccount.Id;
        varDocument.IssueDate__c = Date.today();
        varDocument.IssuerState__c = 'SP';
        varDocument.DocumentNumber__c = '4324235234';
        varDocument.Issuer__c = 'SSP';
        
        insert varDocument;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Documents__c varDocument = [SELECT Id, Name, Account__c, IssueDate__c, IssuerState__c, ExternalId__c, DocumentNumber__c, DocumentType__c, Issuer__c
                                    FROM Documents__c LIMIT 1]; 

        varDocument.IssueDate__c = Date.today().addDays(6);
        varDocument.IssuerState__c = 'MG';
        varDocument.DocumentNumber__c = '42423423432';
        varDocument.Issuer__c = 'SSP';
    
        Test.startTest();
        update varDocument;
        Test.stopTest();

        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account
                              WHERE Id =: varDocument.Account__c
                              LIMIT 1];

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultiple()
    {
        Account varAccount = [SELECT Id, Name, isExternallySynched__c FROM Account LIMIT 1];
        List<Documents__c> listDocumentsInsert = new List<Documents__c>();
        List<Documents__c> listDocumentsUpdate = new List<Documents__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            Documents__c varDocument = new Documents__c();
            varDocument.Account__c = varAccount.Id;

            listDocumentsInsert.add(varDocument);    
        }

        insert listDocumentsInsert;

        for(Documents__c varDocument : listDocumentsInsert)
        {
            varDocument.IssuerState__c = 'MG';
            listDocumentsUpdate.add(varDocument);
        }
        
        update listDocumentsUpdate;
    }
}