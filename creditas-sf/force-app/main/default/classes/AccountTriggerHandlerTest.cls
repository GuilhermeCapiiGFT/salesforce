/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe AccountTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o AccountTriggerHandlerTest
**********************************************************************************************************************************/
@isTest
public class AccountTriggerHandlerTest {
    
    private static final Id RECORDTYPE_CONTA_FISICA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pessoa_Fisica').getRecordTypeId();
    private static final Id RECORDTYPE_CONTA_JURIDICA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pessoa_Juridica').getRecordTypeId();
    
    @TestSetup
    static void makeData()
    {
        Profile userProfile = [SELECT Id FROM Profile LIMIT 1];
        User userTest = new User();
        userTest.LastName = 'Test';
        userTest.Alias = 'Test';
        userTest.Email = 'usertest@Creditas.com.dev';
        userTest.Username = 'usertest@Creditas.com.dev';
        usertest.EmployeeNumber = '01984';
        userTest.CommunityNickname = 'UserTest';
        userTest.ProfileId = userProfile.Id;
        userTest.LocaleSidKey = 'pt_BR';
        userTest.LanguageLocaleKey = 'pt_BR';
        userTest.EmailEncodingKey = 'UTF-8';
        userTest.TimeZoneSidKey = 'America/Sao_Paulo';
        insert userTest;
        
        List<Account> lstTestAccounts = new List<Account>();

        Account testAccount = new Account(Name = 'TestAccount1', MigrationRecord__c = false, IsExternallySynched__c = true);
        Integer aux = integer.valueof(crypto.getRandomLong());
        testAccount.RecordTypeId = RECORDTYPE_CONTA_FISICA;
        testAccount.DocumentNumber__c = '66239925020';
        testAccount.ExternalTenant__c = 'creditasbr';

        lstTestAccounts.add(testAccount);

        testAccount = new Account(Name = 'TestAccount2', MigrationRecord__c = false, IsExternallySynched__c = true);
        aux = integer.valueof(crypto.getRandomLong());
        testAccount.RecordTypeId = RECORDTYPE_CONTA_JURIDICA;
        testAccount.DocumentNumber__c = '73155938000154';
        testAccount.ExternalTenant__c = 'creditasbr';

        lstTestAccounts.add(testAccount);

        insert lstTestAccounts;
        
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__c, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account LIMIT 1];
   
        varAccount.ExternalId__c = '3213213231';
        varAccount.IsSynchEnabled__c = 'ENABLED';

        Test.startTest();
        update varAccount;

        varAccount = [SELECT Id, ExternalId__c, isExternallySynched__c, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
        ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
        CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
        FROM Account LIMIT 1];

        Test.stopTest();

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
        System.assertEquals('ENABLED', varAccount.IsSynchEnabled__c, 'O campo isSynchEnabled não foi mudado para Enabled');
    }
}