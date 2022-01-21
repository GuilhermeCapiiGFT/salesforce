public class TriggerHelperClassToTest {

    public static void metodoTeste(List<Account> lstNewAccount)
     {
         for(Account cAcc : lstNewAccount)
         {	
             switch on cAcc.Name
             {
                 when 'changedField'
                 { cAcc.MigrationRecord__c = TriggerHelper.changedField(cAcc, 'BillingStreet'); }
                 when 'changedFieldList'
                 { cAcc.MigrationRecord__c = TriggerHelper.changedField(cAcc, new List<String> { 'BillingStreet' }); }
                 when 'notChangedField'
                 { cAcc.MigrationRecord__c = TriggerHelper.notChangedField(cAcc, 'BillingStreet'); }
                 when 'notChangedFieldList'
                 { cAcc.MigrationRecord__c = TriggerHelper.notChangedField(cAcc, new List<String> { 'BillingStreet' }); }
                 when 'changedToExpectedValue'
                 { cAcc.MigrationRecord__c = TriggerHelper.changedToExpectedValue(cAcc, 'BillingStreet', 'Rua 2'); }
                 when 'changedFrom'
                 { cAcc.MigrationRecord__c = TriggerHelper.changedFrom(cAcc, 'BillingStreet', 'Rua 2'); }
                 when 'changedFromTo'
                 { cAcc.MigrationRecord__c = TriggerHelper.changedFromTo(cAcc, 'BillingStreet', 'Rua 1', 'Rua 2'); }
             }
         }
     }
 }