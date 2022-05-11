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
    static void resultAddressBlank() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Addresses__c> resultAddress = new List<Addresses__c>();
            
        Test.startTest();
        resultAddress = ProposalAddressesService.getAddress(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, resultAddress.isEmpty(),'List result should be blank');    
    }
    
    @isTest
    static void resultAddressNotBlank() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<Addresses__c> resultAddress = new List<Addresses__c>();
        
        Addresses__c address = new Addresses__c();
        address.Account__c    = acc.Id;
        address.PostalCode__c = '0132234';
        insert address;

        Test.startTest();
        resultAddress = ProposalAddressesService.getAddress(acc.Id);
        Test.stopTest();
        
        System.assertEquals(address.PostalCode__c, resultAddress[0].PostalCode__c,'Incorrect returned CEP value');
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