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
    
    @isTest
    static void insertRecordAddress() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Addresses__c address = new Addresses__c();
        address.Account__c = acc.Id;
        address.PostalCode__c = '0132234';
        
        List<Addresses__c> addresses = new List<Addresses__c>();
        addresses.add(address);
        
        Test.startTest();
        ProposalAddressesService.upsertAddress(addresses);
        Test.stopTest();
        
        Addresses__c resultAddress = [SELECT Id, PostalCode__c FROM Addresses__c WHERE Account__c = :acc.Id LIMIT 1];
       
        System.assertEquals('0132234', resultAddress.PostalCode__c, 'Address insertion should have been a success');
    }
    
    @isTest
    static void updateRecordAddress(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Addresses__c address = new Addresses__c();
        address.Account__c     = acc.Id;
        address.PostalCode__c  = '0050994';

        List<Addresses__c> addresses = new List<Addresses__c>();

        addresses.add(address);
        insert addresses;
        
        address.PostalCode__c = '222109';
        
        ProposalAddressesService.upsertAddress(addresses);
        Test.stopTest();
        
        Addresses__c resultAddress   = [SELECT Id, PostalCode__c FROM Addresses__c WHERE Account__c = :acc.Id LIMIT 1];
        
        System.assertEquals('222109', resultAddress.PostalCode__c, 'Postal Code update should have been a success');
    }
    
    @isTest
    static void upsertRecordAddressFail(){
        Boolean exceptionOccurred = false;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Addresses__c address = new Addresses__c();
        address.Account__c = acc.Id;
        address.Type__c = 'HOME';
        
        List<Addresses__c> addresses = new List<Addresses__c>();
        addresses.add(address);
        insert addresses;
        
        // 'AtWork' value will result in error, since it is not available in the picklist
        address.Type__c = 'AtWork';
        
        try{
            ProposalAddressesService.upsertAddress(addresses);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }
    
    @isTest
    static void insertAddress() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        addressSection.CEPStatus__c = 'Aprovar';

        Test.startTest();
        ProposalAddressesService.upsertAddressSection(addressSection);
        Test.stopTest();

        AddressDataSection__c updatedAddressSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Aprovar', updatedAddressSection.CEPStatus__c, '');
    }
    
    @isTest
    static void updateAddress(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = new AddressDataSection__c(Opportunity__c = opp.Id, CEPStatus__c = 'Aprovar');
        insert addressSection;

        addressSection.CEPStatus__c = 'Pendenciar';
        
        Test.startTest();
        ProposalAddressesService.upsertAddressSection(addressSection);
        Test.stopTest();
        AddressDataSection__c updatedaddressSectionsSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Pendenciar', updatedaddressSectionsSection.CEPStatus__c, '');
    }
    
    @isTest
    static void updateAddressFail() {
        Boolean exceptionOccurred = false;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = new AddressDataSection__c(Opportunity__c = opp.Id, CEPStatus__c = 'Aprovar');

        insert addressSection;
        
        addressSection.CEPStatus__c = 'Aguardando';
        
        Test.startTest();
        try{
            ProposalAddressesService.upsertAddressSection(addressSection);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        AddressDataSection__c updatedAddressSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }    
}