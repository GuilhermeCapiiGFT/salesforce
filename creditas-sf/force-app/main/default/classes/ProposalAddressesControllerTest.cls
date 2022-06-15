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

        AddressDataSection__c addressSection  = new AddressDataSection__c();
        addressSection.Opportunity__c         = opportunity.Id;
        addressSection.CEPStatus__c           = 'APPROVED';
        addressSection.NeighborhoodStatus__c  = 'APPROVED';
        addressSection.StreetAddressStatus__c = 'APPROVED';
        addressSection.AddressNumberStatus__c = 'APPROVED';
        addressSection.StateStatus__c         = 'APPROVED';
        addressSection.CountryStatus__c       = 'APPROVED';
        addressSection.AddOnStatus__c         = 'APPROVED';
        addressSection.PostalCode__c   = '01392003';
        addressSection.Neighborhood__c = 'Boa Vista';
        addressSection.StreetNumber__c = '45';
        addressSection.Street__c       = 'Rua da Glória';
        addressSection.AreaLevel2__c   = 'São Paulo';
        addressSection.AreaLevel1__c   = 'SP';
        addressSection.Country__c      = 'BR';
        addressSection.Complement__c   = 'Perto do Hotel Capunzeira';
        insert addressSection;
    }
    
    @isTest
    static void getAddressesDetailsSuccess(){
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c resultAddress = new AddressDataSection__c();
        
        Test.startTest();
        resultAddress = ProposalAddressesController.getAddressSectiontDetails(opp.Id); 
        Test.stopTest();
        
        System.assertEquals('APPROVED', resultAddress.CEPStatus__c,'Incorrect CEPStatus value');
        System.assertEquals('01392003', resultAddress.PostalCode__c, 'Incorrect PostalCode value');
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
        addressSection.CEPStatus__c           = 'PENDING';
        
        Test.startTest();
        ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();
        
        AddressDataSection__c addressSectionResult = [SELECT Id, Name, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c =: opp.Id LIMIT 1];

        System.assertEquals(addressSectionResult.CEPStatus__c, 'PENDING', 'AddressDataSection for this opportunity does not exist.');
    }

    @isTest
    static void insertAddressSection() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AddressDataSection__c addressSection = new AddressDataSection__c();
        addressSection.Opportunity__c = opp.Id;
        addressSection.CEPStatus__c = 'APPROVED';

        Test.startTest();
        ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();

        AddressDataSection__c updatedAddressSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('APPROVED', updatedAddressSection.CEPStatus__c, 'Field status is different from what is expected');
    }

    @isTest
    static void updateAddressSection(){
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AddressDataSection__c addressSection = [SELECT Id, Name, CEPStatus__c FROM AddressDataSection__c LIMIT 1];
        
        addressSection.CEPStatus__c = 'PENDING';
        
        Test.startTest();
        	ProposalAddressesController.saveAddressSection(addressSection);
        Test.stopTest();
        
        AddressDataSection__c updatedaddressSectionsSection = [SELECT Id, CEPStatus__c FROM AddressDataSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('PENDING', updatedaddressSectionsSection.CEPStatus__c, 'Field status is different from what is expected');
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