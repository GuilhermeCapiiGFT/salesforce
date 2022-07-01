@isTest
private with sharing class AccountTriggerTest {
    @TestSetup
    static void makeData(){
        Account accountPF = AccountSetup.createAccount('Daenerys', 'Pessoa_Fisica');
        Account accountPJ = AccountSetup.createAccount('Westeros Co.', 'Pessoa_Juridica');
        insert accountPF;
        insert accountPJ;
        
    }
    @isTest
    private static void insertValidPFAccount(){
        Account account = AccountSetup.createAccount('Jorge', 'Pessoa_Fisica');
        Test.startTest();
        Database.SaveResult sr = Database.insert(account);
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess(), 'Account not inserted');

    }

    @isTest
    static void updateIsExternallySync() 
    {
        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__c, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, BirthCity__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account LIMIT 1];
   
        varAccount.ExternalId__c = '3213213231';
        varAccount.IsSynchEnabled__c = 'ENABLED';

        Test.startTest();
        update varAccount;

        varAccount = [SELECT Id, ExternalId__c, isExternallySynched__c, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
        ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
        CivilStatus__c, BirthCity__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
        FROM Account LIMIT 1];

        Test.stopTest();

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
        System.assertEquals('ENABLED', varAccount.IsSynchEnabled__c, 'O campo isSynchEnabled não foi mudado para Enabled');
    }

    @isTest
    private static void updateWrongNumber(){

        Account accountPF = [SELECT Id,DocumentNumber__c FROM Account WHERE RecordType.DeveloperName = 'Pessoa_Fisica'];

        accountPF.DocumentNumber__c = '678123';
        String error;
        try{
            update accountPF;
        } catch(Exception e){
            error = e.getMessage();
            
        }
        System.assertNotEquals(null, error, 'Error message should have been thrown');
      
    }
}