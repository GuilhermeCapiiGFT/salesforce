@isTest
public class ProposalIntegrationServiceTest {

    @TestSetup
    static void makeData(){
        Account accCustomer = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opp = OpportunitySetup.createOpportunity(accCustomer.Id, 'AutoFin');
        opp.Description = 'teste';
        opp.ExternalId__c = 'loan-1234';
        opp.StageName = 'Em Análise de Formalização';
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
    static void getRequestSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        
        Test.startTest();
        payload = ProposalIntegrationService.getRequest(opp.Id, 'pending');
        Test.stopTest();
        
        System.assertEquals('loan-1234', payload.loanApplicationId,'loanApplicationId should be loan-1234'); 
        System.assertEquals('Em Análise de Formalização', payload.context,'context should be Em Análise de Formalização'); 
        System.assertEquals(8, payload.sections.size(),'sections size should be 8');
    }
    
    @isTest
    static void getRequestFailTest(){
        Exception testException;
        Opportunity opp = new Opportunity(Name = 'teste1', StageName = 'Em Análise de Formalização', CloseDate = Date.today());
        insert opp;
        
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        
        Test.startTest();
        Try{
        	payload = ProposalIntegrationService.getRequest(opp.Id, 'pending');
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(),'Should have sections record');
    }
    
    @isTest
    static void sendAnalysisSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        String result;
        HttpMockFactory mock = new HttpMockFactory(
            new List<Integer>{200},
            new List<String>{'SUCCESS'},
            new List<String>{''},
            new List<Map<String,String>>{new Map<String,String>()}
        );

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        payload = ProposalIntegrationService.getRequest(opp.Id, 'pending');
        result = ProposalIntegrationService.sendAnalysis(JSON.serialize(payload));
        Test.stopTest();
        
        System.assertEquals('Success', result,'Should have received a success message.');
    }
    
        
    @isTest
    static void sendAnalysisErrorTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        String result;
        HttpMockFactory mock = new HttpMockFactory(
            new List<Integer>{400},
            new List<String>{'BAD_REQUEST'},
            new List<String>{''},
            new List<Map<String,String>>{new Map<String,String>()}
        );

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        payload = ProposalIntegrationService.getRequest(opp.Id, 'pending');
        result = ProposalIntegrationService.sendAnalysis(JSON.serialize(payload));
        Test.stopTest();
        
        System.assertEquals('Error', result,'Should have received a error message.');
    }
}