@isTest
public class ProposalIntegrationControllerTest {

    private static final String MOCK_AUTH = '{"access_token":"tOxqtBAtTEMUdeCNOlZdsUnvjO8gGmMFq01AFQeOLAtlOWglcI3lR6aXpKNvYH8i2hXgbKjqDZ6sJs8SmpQZ9g","token_type":"Bearer","expires_in":86400}';
    
    @TestSetup
    static void makeData(){
        Account accCustomer = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opp = OpportunitySetup.createOpportunity(accCustomer.Id, 'AutoFin');
        opp.Description = 'teste';
        insert opp;
        
        PersonalDataSection__c personalSection  = new PersonalDataSection__c();
        personalSection.Opportunity__c = opp.Id;
        personalSection.Name__c = 'Nivaele';
        insert personalSection;

        AddressDataSection__c addressSection   = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        insert addressSection;
        
        ContactDetailsSection__c contactSection   = new ContactDetailsSection__c();
        contactSection.Opportunity__c = opp.Id;
        insert contactSection;

        WarrantyDataSection__c warrantySection  = new WarrantyDataSection__c();
        warrantySection.Opportunity__c = opp.Id;
        insert warrantySection;

        IncomeDataSection__c incomeSection    = new IncomeDataSection__c();
        incomeSection.Opportunity__c = opp.Id;
        insert incomeSection;

        OperationSection__c operationSection = new OperationSection__c();
        operationSection.Opportunity__c = opp.Id;
        insert operationSection;

        OthersSection__c othersSection = new OthersSection__c();
        othersSection.Opportunity__c = opp.Id;
        insert othersSection;

        GeneralSection__c generalSection = new GeneralSection__c();
        generalSection.Opportunity__c = opp.Id;
        insert generalSection;
    }

    @isTest
    static void finishAnalysisSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String response;
        
        HttpMockFactory mock = createMock(new List<Integer>{200,200},new List<String>{MOCK_AUTH,''});
    
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        response = ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        Test.stopTest();
        System.assertEquals('Success', response, 'Should have received a success message.');
    }
    
    @isTest
    static void finishAnalysisFailTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String response;
        
        HttpMockFactory mock = createMock(new List<Integer>{200,400},new List<String>{MOCK_AUTH,''});

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        response = ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        Test.stopTest();
        System.assertEquals('Error', response, 'Should return Error.');
    }
    
    @isTest
    static void finishAnalysisCatchErrorTest(){
        Opportunity opp = new Opportunity(Name = 'teste1', StageName = 'Em Análise de Formalização', CloseDate = Date.today());
        insert opp;
        Exception testException;
    
        Test.startTest();
        Try{
        	ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        }catch(Exception e){
            testException = e;
        }
        
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'Should have sections record');
    }

    @isTest
    static void failedAuthentication(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String response;
        
        HttpMockFactory mock = createMock(new List<Integer>{400},new List<String>{MOCK_AUTH});
    
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        response = ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        Test.stopTest();
        System.assertEquals('Error', response, 'Should have received a error message.');
    }

    private static HttpMockFactory createMock(List<Integer> statusCode, List<String> payloads){
        HttpMockFactory mock = new HttpMockFactory(
            statusCode,
            new List<String>{'OK','OK'},
            payloads,
            new List<Map<String,String>>{new Map<String,String>(), new Map<String,String>()}
        );
        return mock;
    }
}