@isTest
private with sharing class FinancialResourcesTriggerTest {

    @TestSetup
    static void makeData(){

        Account account = AccountSetup.createAccount('Jeffrey', 'Pessoa_Fisica');
        account.IsExternallySynched__c = true;
        Account accountPJ = AccountSetup.createAccount('Empresa S.A', 'Pessoa_Juridica');
        accountPJ.IsExternallySynched__c = true;

        TriggerHandler.bypass('AccountTriggerHandler');
        insert account;
        insert accountPJ;

        FinancialResources__c financialResource = new FinancialResources__c();
        financialResource.Type__c = 'MONTHLY_INCOME';
        financialResource.Amount__c = 666;
        financialResource.RecordTypeId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');

        insert financialResource;

        AccountFinancialRelationship__c financialRelationship = new AccountFinancialRelationship__c();
        financialRelationship.Recurso_Financeiro__c = financialResource.Id;
        financialRelationship.Account__c = account.id;

        TriggerHandler.bypass('AccFinancialRelationshipTriggerHandler');
        insert financialRelationship;
        TriggerHandler.clearAllBypasses();
        
    }

    @isTest
    private static void testIsExternallySyncedAcc(){
        FinancialResources__c financialResource = [SELECT Id FROM FinancialResources__c LIMIT 1];
        List<Account> accountList = [SELECT Name,IsExternallySynched__c FROM Account];
        for(Account iAccount : accountList){
            System.debug(iAccount.Name + ' -> ' + iAccount.IsExternallySynched__c);
            System.assertEquals(true, iAccount.IsExternallySynched__c, 'Expected TRUE');
        }
        financialResource.Amount__c = 6666;
        Test.startTest();
            update financialResource;
        Test.stopTest();
        List<Account> accountListAfterUpdate = [SELECT IsExternallySynched__c,Name FROM Account];
        for(Account iAccount: accountListAfterUpdate){
            if(iAccount.Name == 'Jeffrey'){
                System.assertEquals(false, iAccount.IsExternallySynched__c, 'Expected FALSE');
            } else {
                System.assertEquals(true, iAccount.IsExternallySynched__c, 'Expected TRUE');
            }
        }
    }
    
}