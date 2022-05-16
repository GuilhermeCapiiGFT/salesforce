@isTest
public class ProposalControllerTest {

    @TestSetup
    static void makeData() 
    {
        Account accCustomer               = TestSetup.getAccount('Nivaele', false);
        accCustomer.RecordTypeId          = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        accCustomer.Birth_City__c         = 'Monte Caramelo';
        accCustomer.Mother__c             = 'Juzimara da Silva';
        accCustomer.Father__c             = 'Josialdo Ferreira';
        insert accCustomer;

        Opportunity opportunity              = new Opportunity();
        opportunity.AccountId                = accCustomer.Id;
        opportunity.Name                     = 'Formalizacao Autofin';
        opportunity.StageName                = 'Em Análise de Formalização';
        opportunity.CloseDate                = Date.today().addDays(10);
        opportunity.ExternalTenant__c        = 'creditasbr';
        opportunity.ExternalVersion__c       = 1;      
        opportunity.RecordTypeId             = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        insert opportunity;
    }

    @isTest
    private static void getReasonTest(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('PersonalDataSection__c','CNHnumberPendingReason__c');
        Test.stopTest();

        System.assertNotEquals('[]', returnReason, 'Should have returned String');
    }

    @isTest
    private static void getReasonWithParamsBlank(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('', '');
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }
    
    @isTest
    private static void getReasonObjectError(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('abc','def');   
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }
    
    @isTest
    private static void getReasonFieldError(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('PersonalDataSection__c','def');   
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }

    @isTest
    private static void startCopySuccess()
    {
        Account acc = [SELECT Id, Name, Birth_City__c, Mother__c, Father__c FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 

        Test.startTest();
            ProposalController.createNewInstance(acc.Id, opp.Id);   
        Test.stopTest();

        PersonalDataSection__c personalSection = [SELECT Id, Name__c FROM PersonalDataSection__c LIMIT 1];

        System.assertEquals(acc.Name, personalSection.Name__c, 'Field value should be the same');
    }

    @isTest
    public static void startCopyFail()
    {
        Exception testException;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Contact newContact = new Contact();
        newContact.LastName = 'TesteContato';
        newContact.AccountId = acc.Id;
        insert newContact;
        
        Test.startTest();
        try {
            ProposalController.createNewInstance(acc.Id, newContact.Id);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'Wrong exception Thrown.');
    }

    
}