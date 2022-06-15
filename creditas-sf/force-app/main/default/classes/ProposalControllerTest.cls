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
        opportunity.StageName                = 'Aguardando Análise de Formalização';
        opportunity.CloseDate                = Date.today().addDays(10);
        opportunity.ExternalTenant__c        = 'creditasbr';
        opportunity.ExternalVersion__c       = 1;      
        opportunity.RecordTypeId             = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        insert opportunity;

        Account acc = TestSetup.getAccount('Julio Iglesias', true);
        Opportunity opp = TestSetup.getOpportunity(acc.Id, false);
        opp.Name = 'genera-data-sectionopp-test';
        insert opp;
        ProposalGeneralSectionSetup setup = new ProposalGeneralSectionSetup(opp, 'general-data-section');
        GeneralSection__c section = setup.createGeneralSection(null, true);

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

        System.assertEquals('Attempt to de-reference a null object', testException.getMessage(), 'Wrong exception Thrown.');
    }
    @IsTest
    static void testGetSection(){
        Opportunity opp = [
            SELECT Id FROM Opportunity WHERE Name = 'genera-data-sectionopp-test'
        ];
        ProposalSectionService service = new ProposalSectionService();
        List<String> fields = new List<String> {'Name', 'GeneralDataObservation__c', 'Opportunity__c'};
        Test.startTest();
        String response = ProposalController.getLastSection(opp.Id, 'GeneralSection__c', fields, 'Opportunity__c');
        Test.stopTest();
        GeneralSection__c section = (GeneralSection__c) JSON.deserialize(response, GeneralSection__c.class);
        System.assert(String.isNotBlank(response), 'List is Empty');
        System.assertEquals(section.Opportunity__c, opp.Id, 'sections is not from de desired opportunity');
    }
    @IsTest
    static void testSaveSection(){
        Opportunity opp = [
            SELECT Id FROM Opportunity WHERE Name = 'genera-data-sectionopp-test'
        ];
        ProposalSectionService service = new ProposalSectionService();
        List<String> fields = new List<String> {'Name', 'GeneralDataObservation__c', 'Opportunity__c'};
        List<GeneralSection__c> section = (List<GeneralSection__c>) service.getLastSection(opp.Id, 'GeneralSection__c', fields, 'Opportunity__c');
        String jsonString = '{'+
                '"GeneralSection__c" : {'+
                    '"Id": "' + section.get(0).Id + '",'+
                    '"GeneralDataObservation__c":"observation 2"' +
                '}'+
        '}';
        Test.startTest();
        ProposalCOntroller.saveSection(jsonString);
        Test.stopTest();
        GeneralSection__c newSection = [
            SELECT Id, GeneralDataObservation__c FROM GeneralSection__c WHERE GeneralSectionExternalIdAtWork__c = 'general-data-section'
        ];
        System.assert(newSection != null, 'Section was not created');
        System.assertEquals(newSection.GeneralDataObservation__c,  'observation 2', 'observation was not updated');
    }
    
}