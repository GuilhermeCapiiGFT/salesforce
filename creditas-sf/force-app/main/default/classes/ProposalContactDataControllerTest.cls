@isTest
public class ProposalContactDataControllerTest {
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
        
        ContactDetailsSection__c communications = new ContactDetailsSection__c( Email__c = 'test@test123.com', Mobile__c = '11 911223344', Opportunity__c = opportunity.id );

        insert communications;
    }
    
    @isTest
    static void getContactDetailsSucess(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
  		
        Test.startTest();
        ProposalContactDataController.getContactDetails(opp.Id);
        Test.stopTest();
        
       List<ContactDetailsSection__c> contactDetailSec = [SELECT Email__c, Mobile__c, Opportunity__c FROM ContactDetailsSection__c WHERE Opportunity__r.Name = 'Teste' ];
       System.assert(!contactDetailSec.isEmpty(), 'ContactDetailsSection not found');
    }
    
    @isTest
    static void getCommunicationContactFail(){
        String exceptionMessage = '';
        
        
        Test.startTest();
        try{
         ProposalContactDataController.getContactDetails('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }
 
    @isTest
    static void saveContactDetailsSectionSuccess(){
        Boolean exceptionOccurred = false;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opp.Id, MobileStatus__c = 'Aprovar');
        
        Test.startTest();
        try{
            ProposalContactDataController.saveContactDetailsSection(contactDetail);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionOccurred,'Exception should not occur');
    }
    
    @isTest
    static void saveContactDetailsSectionFail(){
        Boolean exceptionOccurred = false;
        String exceptionMessage = '';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        try{
            ProposalContactDataController.saveContactDetailsSection(acc);
        }catch(Exception e){
            exceptionOccurred = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid conversion from runtime type Account to ContactDetailsSection__c', exceptionMessage,'Expected a ContactDetailsSection__c record');
    }
}