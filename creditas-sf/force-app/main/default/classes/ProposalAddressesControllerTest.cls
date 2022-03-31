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
         
        System.assertEquals('01392003', recordInfo[0].PostalCode__c , 'Incorrect  value');
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
        Boolean exceptionOccurred = false;
        AddressDataSection__c resultAddress = new AddressDataSection__c();
        
        Test.startTest();
        try {
            resultAddress = ProposalAddressesController.getAddressSectiontDetails(opp.Id);
        } catch(Exception e) {
            exceptionOccurred = true;
        }
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
    static void saveAddressFail() {
        String exceptionMessage = '';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Account> accounts = new List<Account>();
		accounts.add(acc);
        
        Test.startTest();
        try{
            ProposalAddressesController.saveAddress(accounts);
            
        }catch(Exception e) {
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();
        
        System.assertEquals('Invalid conversion from runtime type List<Account> to List<Addresses__c>', exceptionMessage, 'Incorrect exception message.');
    }
    
    @isTest
    static void saveAddressesSectionSuccess() {
        Boolean exceptionOccurred = false;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection  = new AddressDataSection__c();
        addressSection.Opportunity__c         =  opp.Id;
        addressSection.CEPStatus__c           = 'Aprovar'; 
        
        Test.startTest();
        try{
            ProposalAddressesController.saveAddressSection(addressSection);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionOccurred,'Exception should not occur');
    }
    
    @isTest
    static void saveAddressesSectionFail() {
        Boolean exceptionOccurred = false;
        String exceptionMessage = '';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        try{
            ProposalAddressesController.saveAddressSection(acc);
        }catch(Exception e){
            exceptionOccurred = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid conversion from runtime type Account to AddressDataSection__c', exceptionMessage,'Expected a AddressDataSection__c record');
    }
}