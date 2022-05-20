@isTest
public with sharing class ProposalAddressesServiceTest {
    
    @TestSetup
    static void makeData() {
        
        Account varAccount = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = varAccount.Id;
        opportunity.Name = 'Teste';
        opportunity.StageName = 'Novo';
        opportunity.CloseDate = Date.today().addDays(10);
        opportunity.ExternalTenant__c = 'creditasbr';
        opportunity.ExternalVersion__c = 1;
        insert opportunity;
    }

    @isTest
    static void resultAddressSectionBlank(){
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AddressDataSection__c resultAddressSection = new AddressDataSection__c();
            
        Test.startTest();
        	resultAddressSection = ProposalAddressesService.getAddressDataSection(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new AddressDataSection__c(), resultAddressSection,'Result should be new AddressDataSection__c');
    }
    
    @isTest
    static void resultAddressesSectionNotBlank(){
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AddressDataSection__c resultAddressSection = new AddressDataSection__c();
        
        AddressDataSection__c addressSection = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        addressSection.CEPStatus__c = 'Aprovar';
        insert addressSection;
        
        Test.startTest();
        	resultAddressSection = ProposalAddressesService.getAddressDataSection(opp.Id);
        Test.stopTest();
        
        System.assertEquals(addressSection.Id, resultAddressSection.Id, 'Incorrect returned Id');
    }
}