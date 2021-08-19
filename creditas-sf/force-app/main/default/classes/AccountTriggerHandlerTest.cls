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
    
    private static final Id RECORDTYPE_CONTA_FISICA = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pessoa Física').getRecordTypeId();
    private static final Id RECORDTYPE_CONTA_JURIDICA = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pessoa Jurídica').getRecordTypeId();
    
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
        for(Integer i=0; i<3; i++)
        {
            Account testAccount = new Account(Name = 'TestAccount'+i);
            Integer aux = integer.valueof(crypto.getRandomLong());
             
            if(math.mod(i, 2) == 0)
            {
                testAccount.RecordTypeId = RECORDTYPE_CONTA_FISICA;
                testAccount.DocumentNumber__c = i > 1 ? '38496403025' : '73155938000154';
            } else
            {
                testAccount.RecordTypeId = RECORDTYPE_CONTA_JURIDICA;
                testAccount.DocumentNumber__c = i > 1 ? '66239925020' : '11428540000197';
            }
            
            if(i > 1)
            {
                testAccount.DocumentType__c = 'CPF';
            }
            lstTestAccounts.add(testAccount);
        }

        insert lstTestAccounts;
        
        // Account testTerritoryAccount = TestSetup.getAccount('testAccount', false);
        // testTerritoryAccount.Territorios__c = '123';
        // insert testTerritoryAccount;   
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account LIMIT 1];
        

        varAccount.ExternalId__c = '3213213231';
        varAccount.IsSynchEnabled__c = 'ENABLED';

        System.debug(varAccount);

        Test.startTest();
        update varAccount;
        Test.stopTest();

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
        System.assertEquals('ENABLED', varAccount.IsSynchEnabled__c, 'O campo isSynchEnabled não foi mudado para Enabled');
    }
}