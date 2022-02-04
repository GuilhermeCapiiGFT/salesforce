@isTest
public class TriggerHelperTest {
    
    @testSetup
    static void TestSetup(){
        Account lAcc = AccountSetup.createAccount('Teste Account', 'Pessoa_Fisica');
        lAcc.MigrationRecord__c = false;
        insert lAcc;
    }
    
    @isTest
    private static void changeFieldTest(){
        List<Account> lAcc =  [SELECT Id FROM Account ];
        Test.startTest();
        lAcc[0].Name = 'changedField';
        lAcc[0].BillingStreet = 'billyJean';
        update lAcc;
        Test.stopTest();
        
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account LIMIT 1];
        System.assert(lAccResponse.MigrationRecord__c,'o campo aField não foi alterado ');
    }
    
    @isTest
    private static void changedFieldList(){
        
        List<Account> lAcc = [SELECT Id,Name,BillingStreet FROM Account LIMIT 1];
        
        
        Test.startTest();
        lAcc[0].Name = 'changedFieldList';
        lAcc[0].BillingStreet = 'johnWick';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,' Nenhum dos campos em aFields foi alterado');
    }
    @isTest
    private static void notChangedField(){
        
        
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
        
        
        Test.startTest();
        lAcc[0].Name = 'notChangedField';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'o campo aField não foi alterado ');
    }
    @isTest
    private static void notChangedFieldList(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
  
        Test.startTest();
        lAcc[0].Name = 'notChangedFieldList';
        update lAcc;
        Test.stopTest();
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'nenhum dos campos em aFields foi alterado');
    }
    @isTest
    private static void changedToExpectedValue(){
        List<Account> lAcc = [SELECT id,Name,BillingStreet FROM Account ];
        
        Test.startTest();
            lAcc[0].Name = 'changedToExpectedValue';
            lAcc[0].BillingStreet = 'Rua 2';
            update lAcc;
        Test.stopTest();
        
        Account lAccResponse = [SELECT MigrationRecord__c FROM Account ];
        System.assert(lAccResponse.MigrationRecord__c == true,'determinado campo foi alterado para o valor esperado');
    }
    
    @isTest
    private static void changedFromTo(){
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
    @isTest
    private static void changedFrom(){
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