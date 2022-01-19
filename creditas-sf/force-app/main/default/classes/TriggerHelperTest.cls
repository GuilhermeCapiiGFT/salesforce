@isTest
public class TriggerHelperTest {
    
    @testSetup
    static void TestSetup(){
        Id lPessoaFisicaRT = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        Account lconta = TestSetup.getAccount('Teste Account', false);
        lConta.RecordTypeId = lPessoaFisicaRT;
        lConta.DocumentNumber__c = '81357651007';
        insert lconta;
    }
    
    static testMethod void changeFieldTest(){
        List<Account> lAcc =  [SELECT Id,Name FROM Account ];

        Test.startTest();
        lAcc[0].Name = 'changedField';
        lAcc[0].BillingStreet = 'billyJean';
        update lAcc;
        Test.stopTest();
        
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'o campo aField não foi alterado ');
    }
    
    static testMethod void changedFieldList(){
        
        List<Account> lAcc = [SELECT Id,Name,BillingStreet FROM Account LIMIT 1];
        
        
        Test.startTest();
        lAcc[0].Name = 'changedFieldList';
        lAcc[0].BillingStreet = 'johnWick';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,' Nenhum dos campos em aFields foi alterado');
    }
    static testMethod void notChangedField(){
        
        
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
        
        
        Test.startTest();
        lAcc[0].Name = 'notChangedField';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'o campo aField não foi alterado ');
    }
    static testMethod void notChangedFieldList(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
  
        Test.startTest();
        lAcc[0].Name = 'notChangedFieldList';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'nenhum dos campos em aFields foi alterado');
    }
    static testMethod void changedToExpectedValue(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
        
        
        
        Test.startTest();
            lAcc[0].Name = 'changedToExpectedValue';
            lAcc[0].BillingStreet = 'Rua 2';
            update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'determinado campo foi alterado para o valor esperado');
    }
    
    static testMethod void changedFromTo(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account  ];
        lAcc[0].BillingStreet = 'Rua 1';
        update lAcc;
        
        
        Test.startTest();
        lAcc[0].Name = 'changedFromTo';
        lAcc[0].BillingStreet = 'Rua 2';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'determinado campo foi alterado do valor esperado para valor esperado ');
    } 
     static testMethod void changedFrom(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account  ];
         lAcc[0].BillingStreet = 'Rua 2';
         update lAcc;
        
        
        Test.startTest();
            lAcc[0].Name = 'changedFrom';
            lAcc[0].BillingStreet = 'Rua 3';
            update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true , 'determinado campo foi alterado do valor esperado ');
    }
    @isTest
    private static void testExceptionNotInTriggerContext(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account];
        Test.startTest();
        try{
            TriggerHelper.changedField(lAcc[0],'');
        } catch(Exception e){
            System.assertEquals('This method must be called only in trigger context.', e.getMessage(), 'Exception não rodou');
		}
        try{
            TriggerHelper.changedField(lAcc[0], new List<String>() );
        } catch(Exception e){
            System.assertEquals('This method must be called only in trigger context.', e.getMessage(), 'Exception não rodou');
		}
        Test.stopTest();
    }
}