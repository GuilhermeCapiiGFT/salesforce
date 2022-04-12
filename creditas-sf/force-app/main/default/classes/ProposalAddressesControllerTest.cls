@isTest
public class ProposalAddressesControllerTest {
    
    @TestSetup
    static void makeData(){
        Account varAccount = TestSetup.getAccount('Nivaele', true);
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = varAccount.Id;
        opportunity.Name = 'Teste';
        opportunity.StageName = 'Novo';
        opportunity.CloseDate = Date.today().addDays(10);
        opportunity.ExternalTenant__c = 'creditasbr';
        opportunity.ExternalVersion__c = 1;      
        insert opportunity;
        
        Addresses__c address = new Addresses__c();
        address.Account__c      =  varAccount.Id;
        address.PostalCode__c   = '01392003';
        address.Neighborhood__c = 'Boa Vista';
        address.StreetNumber__c = '45';
        address.Street__c       = 'Rua da Glória';
        address.AreaLevel2__c   = 'São Paulo';
        address.AreaLevel1__c   = 'SP';
        address.Country__c      = 'BR';
        address.Complement__c   = 'Perto do Hotel Capunzeira';
        insert address;
        
        AddressDataSection__c addressSection  = new AddressDataSection__c();
        addressSection.Opportunity__c         = opportunity.Id;
        addressSection.CEPStatus__c           = 'Aprovar';
        addressSection.NeighborhoodStatus__c  = 'Aprovar';
        addressSection.StreetAddressStatus__c = 'Aprovar';
        addressSection.AddressNumberStatus__c = 'Aprovar';
        addressSection.StateStatus__c         = 'Aprovar';
        addressSection.CountryStatus__c       = 'Aprovar';
        addressSection.AddOnStatus__c         = 'Aprovar';
        insert addressSection;
    }
    
    @isTest
    static void getAddressSuccess() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
  		List<Addresses__c> recordInfo = new List<Addresses__c>();
        
        Test.startTest();
        recordInfo = ProposalAddressesController.getAddress(acc.Id);
        Test.stopTest();
         
        System.assertEquals(recordInfo.size() > 0, true, 'List must not be empty.');
    }
    
    @isTest
    static void getAddressFail() {
        String exceptionMessage = '';
        List<Addresses__c> resultAddress = new List<Addresses__c>();
        
        Test.startTest();
        try {
            resultAddress = ProposalAddressesController.getAddress('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }
 
    @isTest
    static void getAddressesDetailsSuccess(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c resultAddress = new AddressDataSection__c();
        
        Test.startTest();
        resultAddress = ProposalAddressesController.getAddressSectiontDetails(opp.Id); 
        Test.stopTest();
        
        System.assertEquals('Aprovar', resultAddress.CEPStatus__c,'Incorrect CEPStatus value'); 
    }
    
    @isTest
    static void getAddressDetailsFail() {
        String exceptionMessage = '';
        AddressDataSection__c resultAddress = new AddressDataSection__c();
        
        Test.startTest();
        try{
            resultAddress = ProposalAddressesController.getAddressSectiontDetails('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.'); 
    }

    
    @isTest
    static void saveAddressSuccess(){
        Boolean exceptionOccurred = false;
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Addresses__c address = new Addresses__c();
        address.Account__c      = acc.Id;
        address.PostalCode__c   = '0140334';
        address.Neighborhood__c = 'Vila Montina';
        address.StreetNumber__c = '54';
        
        List<Addresses__c> addresses = new List<Addresses__c>();
        addresses.add(address);

        Test.startTest();
        try{
            ProposalAddressesController.saveAddress(addresses);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionOccurred,'Exception should not occur');
    }
    
    
    @isTest
    static void insertAddressesSectionSuccess() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Teste';
        opp.StageName = 'Novo';
        opp.CloseDate = Date.today().addDays(16);
        insert opp;

        AddressDataSection__c addressSection  = new AddressDataSection__c();
        addressSection.Opportunity__c         =  opp.Id;
        addressSection.CEPStatus__c           = 'Pendenciar';
        
        Test.startTest();
        ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();
        
        AddressDataSection__c addressSectionResult = [SELECT Id, Name, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c =: opp.Id LIMIT 1];

        System.assertEquals(addressSectionResult.CEPStatus__c, 'Pendenciar', 'AddressDataSection for this opportunity does not exist.');
    }
    
    @isTest
    static void updateRecordAddress(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Addresses__c address = [SELECT Id, PostalCode__c FROM Addresses__c WHERE Account__c = :acc.Id LIMIT 1];

        List<Addresses__c> addresses = new List<Addresses__c>();
        
        addresses.add(address);
        
        Test.startTest();
        address.PostalCode__c = '222109';
        ProposalAddressesController.saveAddress(addresses);
        Test.stopTest();
        
        System.assertEquals('222109', address.PostalCode__c, 'Postal Code update should have been a success');
    }

    @isTest
    static void insertRecordAddress(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Addresses__c address   = new Addresses__c();
        address.Account__c     = acc.Id;
        address.PostalCode__c  = '0050994';
        address.Country__c     = 'Brasil';
        
        List<Addresses__c> addresses = new List<Addresses__c>();

        addresses.add(address);
        
        Test.startTest();
        address.PostalCode__c = '222109';
        ProposalAddressesController.saveAddress(addresses);
        Test.stopTest();
        
        Addresses__c resultAddress = [SELECT Id, PostalCode__c FROM Addresses__c WHERE Account__c = :acc.Id AND Country__c = 'Brasil' LIMIT 1];
        
        System.assertEquals('222109', resultAddress.PostalCode__c, 'Address insertion should have been a success');
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
            ProposalAddressesController.saveAddress(addresses);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }

    @isTest
    static void insertAddressSection() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        addressSection.CEPStatus__c = 'Aprovar';

        Test.startTest();
        ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();

        AddressDataSection__c updatedAddressSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Aprovar', updatedAddressSection.CEPStatus__c, 'Field status is different from what is expected');
    }

    @isTest
    static void updateAddressSection(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = [SELECT Id, Name, CEPStatus__c FROM AddressDataSection__c LIMIT 1];
        
        addressSection.CEPStatus__c = 'Pendenciar';
        
        Test.startTest();
        ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();
        AddressDataSection__c updatedaddressSectionsSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Pendenciar', updatedaddressSectionsSection.CEPStatus__c, 'Field status is different from what is expected');
    }

    @isTest
    static void updateAddressSectionFail() {
        Boolean exceptionOccurred = false;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = [SELECT Id, Name, CEPStatus__c FROM AddressDataSection__c LIMIT 1];
        
        addressSection.CEPStatus__c = 'Aguardando';
        
        Test.startTest();
        try{
            ProposalAddressesController.saveAddressSection(addressSection);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
         
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }   
}