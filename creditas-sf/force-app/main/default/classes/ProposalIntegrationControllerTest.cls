@isTest
public class ProposalIntegrationControllerTest {
    
    @TestSetup
    static void makeData(){
        String accPessoaFisica = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Pessoa_Fisica' AND SobjectType = 'Account']?.Id;
        Account accCustomer = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opp = OpportunitySetup.createOpportunity(accCustomer.Id, 'AutoFin');
        opp.Description = 'teste';
        insert opp;

        
        PersonalDataSection__c personalSection  = new PersonalDataSection__c();
        personalSection.Opportunity__c = opp.Id;
        personalSection.Name__c = 'Nivaele';
        personalSection.NameStatus__c = 'Aprovar';
        insert personalSection;

        AddressDataSection__c addressSection   = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        addressSection.CEPStatus__c = 'Aprovar';
        insert addressSection;
        
        ContactDetailsSection__c contactSection   = new ContactDetailsSection__c();
        contactSection.Opportunity__c = opp.Id;
        insert contactSection;

        WarrantyDataSection__c warrantySection  = new WarrantyDataSection__c();
        warrantySection.Opportunity__c = opp.Id;
        insert warrantySection;

        IncomeDataSection__c incomeSection    = new IncomeDataSection__c();
        incomeSection.Opportunity__c = opp.Id;
        incomeSection.ProfessionalSituationStatus__c = 'Pendenciar';
        incomeSection.ProfessionalSituationPendingReason__c = 'Outros';
        incomeSection.ProfessionalSituationObservation__c = 'Pendency Professional Situation';
        insert incomeSection;

        OperationSection__c operationSection = new OperationSection__c();
        operationSection.Opportunity__c = opp.Id;
        operationSection.QuantityStatus__c = 'Rejeitar';
        operationSection.QuantityRejectReason__c = 'Outros';
        operationSection.QuantityObservation__c  = 'Reject Quantity';
        insert operationSection;
    }

    @isTest
    static void finishAnalysisSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String response;
        
        HttpMockFactory mock = new HttpMockFactory(
            new List<Integer>{200},
            new List<String>{'SUCCESS'},
            new List<String>{''},
            new List<Map<String,String>>{new Map<String,String>()}
        );

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
        
        HttpMockFactory mock = new HttpMockFactory(
            new List<Integer>{400},
            new List<String>{'BAD_REQUEST'},
            new List<String>{''},
            new List<Map<String,String>>{new Map<String,String>()}
        );

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        response = ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        Test.stopTest();
        System.assertEquals('Bad request', response, 'Should have received a bad request message.');
    }
    
    @isTest
    static void finishAnalysisCatchTest(){
        Opportunity opp = new Opportunity(Name = 'teste1', StageName = 'Em Análise de Formalização', CloseDate = Date.today());
        insert opp;
        Exception testException;
                
        HttpMockFactory mock = new HttpMockFactory(
            new List<Integer>{400},
            new List<String>{'BAD_REQUEST'},
            new List<String>{''},
            new List<Map<String,String>>{new Map<String,String>()}
        );

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Try{
        	ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        }catch(Exception e){
            testException = e;
        }
        
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'Should have sections record');
    }
    
    
}