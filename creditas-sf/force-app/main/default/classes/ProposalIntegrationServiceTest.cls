@isTest
public class ProposalIntegrationServiceTest {

    @TestSetup
    static void makeData(){
        String accPessoaFisica = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Pessoa_Fisica' AND SobjectType = 'Account']?.Id;
        Account accCustomer = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opp = OpportunitySetup.createOpportunity(accCustomer.Id, 'AutoFin');
        opp.Description = 'teste';
        insert opp;

        PersonalDataSection__c personalSection  = new PersonalDataSection__c();
        personalSection.Opportunity__c = opp.Id;
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
    }

    @isTest
    static void finishAnalysisTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        ProposalIntegrationController.finishAnalysis(opp.Id, 'pendency');
        Test.stopTest();
    }
}