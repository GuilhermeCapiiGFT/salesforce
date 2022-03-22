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
        
        CommunicationContacts__c communicationSMS = new CommunicationContacts__c(Account__c = varAccount.Id, Channel__c = 'SMS', Code__c = '11 911223344');
        CommunicationContacts__c communicationEMAIL = new CommunicationContacts__c(Account__c = varAccount.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        List<CommunicationContacts__c> communications = new List<CommunicationContacts__c>();
        communications.add(communicationSMS);
        communications.add(communicationEMAIL);
        insert communications;
        
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opportunity.Id, MobileStatus__c = 'Aprovar');
        insert contactDetail;
    }
    
    @isTest
    static void getCommunicationContactSuccess(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
  		Map<String,CommunicationContacts__c> mapResultCommunications = new Map<String,CommunicationContacts__c>();
        
        Test.startTest();
        mapResultCommunications = ProposalContactDataController.getCommunicationContact(acc.Id);
        Test.stopTest();
        
        System.assertEquals('test@test.com', mapResultCommunications.get('EMAIL').Code__c ,'Incorrect email value');
        
    }
    
    @isTest
    static void getCommunicationContactFail(){
        String exceptionMessage = '';
        Map<String,CommunicationContacts__c> mapResultCommunications = new Map<String,CommunicationContacts__c>();
        
        Test.startTest();
        try{
            mapResultCommunications = ProposalContactDataController.getCommunicationContact('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.');
    }
 
    @isTest
    static void getContactDetailsSuccess(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Boolean exceptionOccurred = false;
        ContactDetailsSection__c mapResultCommunications = new ContactDetailsSection__c();
        
        Test.startTest();
        try{
            mapResultCommunications = ProposalContactDataController.getContactDetails(opp.Id);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals('Aprovar', mapResultCommunications.MobileStatus__c,'Incorrect MobileStatus value'); 
    }
    
    @isTest
    static void getContactDetailsFail(){
        String exceptionMessage = '';
        ContactDetailsSection__c mapResultCommunications = new ContactDetailsSection__c();
        
        Test.startTest();
        try{
            mapResultCommunications = ProposalContactDataController.getContactDetails('123456778');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Invalid id: 123456778', exceptionMessage, 'Incorrect exception message.'); 
    }

    
    @isTest
    static void saveCommunicationContactsSuccess(){
        Boolean exceptionOccurred = false;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        CommunicationContacts__c communicationSMS = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'SMS', Code__c = '11 911223344');
        CommunicationContacts__c communicationEMAIL = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        List<CommunicationContacts__c> communications = new List<CommunicationContacts__c>();
        communications.add(communicationSMS);
        communications.add(communicationEMAIL);
        Test.startTest();
        try{
            ProposalContactDataController.saveCommunicationContacts(communications);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionOccurred,'Exception should not occur');
    }
    
    @isTest
    static void saveCommunicationContactsFail() {
        String exceptionMessage = '';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Account> accounts = new List<Account>();
		accounts.add(acc);
        
        Test.startTest();
        try{
            ProposalContactDataController.saveCommunicationContacts(accounts);
            
        }catch(Exception e) {
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();
        
        System.assertEquals('Invalid conversion from runtime type List<Account> to List<CommunicationContacts__c>', exceptionMessage, 'Incorrect exception message.');
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