@isTest
public class ProposalContactDataServiceTest {
    
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
    }

    @isTest
    static void resultCommunicationContactBlank(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,CommunicationContacts__c> resultCommunications = new Map<String,CommunicationContacts__c>();
            
        Test.startTest();
        resultCommunications = ProposalContactDataService.getCommunicationContactFromAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, resultCommunications.isEmpty(),'Map result should be blank');    
    }
    
    @isTest
    static void resultCommunicationContactNotBlank(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,CommunicationContacts__c> resultCommunications = new Map<String,CommunicationContacts__c>();
        CommunicationContacts__c communicationEmail = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        insert communicationEmail;

        Test.startTest();
        resultCommunications = ProposalContactDataService.getCommunicationContactFromAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(communicationEmail.Code__c, resultCommunications.get('EMAIL').Code__c,'Incorrect returned Email');
    }
    
    @isTest
    static void resultContactDetailsSectionBlank(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c resultDetailsSection = new ContactDetailsSection__c();
            
        Test.startTest();
        resultDetailsSection = ProposalContactDataService.getContactDetailsSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new ContactDetailsSection__c(), resultDetailsSection,'Result should be new ContactDetailsSection__c');
    }
    
    @isTest
    static void resultContactDetailsSectionNotBlank(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c resultContactDetails = new ContactDetailsSection__c();
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opp.Id, MobileStatus__c = 'Aprovar');
        insert contactDetail;
        
        Test.startTest();
        resultContactDetails = ProposalContactDataService.getContactDetailsSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(contactDetail.Id, resultContactDetails.Id,'Incorrect returned Id');
    }
    
    @isTest
    static void insertRecordCommunicationContacts(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        CommunicationContacts__c communicationEmail = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        CommunicationContacts__c communicationSMS = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'SMS', Code__c = '11 911223344');
        List<CommunicationContacts__c> communications = new List<CommunicationContacts__c>();
        communications.add(communicationEmail);
        communications.add(communicationSMS);
        
        Test.startTest();
        ProposalContactDataService.upsertCommunicationContacts(communications);
        Test.stopTest();
        
        CommunicationContacts__c contactSMS   = [SELECT Id, Code__c FROM CommunicationContacts__c WHERE Account__c = :acc.Id AND Channel__c = 'SMS' LIMIT 1];
        CommunicationContacts__c contactEMAIL = [SELECT Id, Code__c FROM CommunicationContacts__c WHERE Account__c = :acc.Id AND Channel__c = 'EMAIL' LIMIT 1];
        
        System.assertEquals('11 911223344', contactSMS.Code__c, 'SMS insert should be a success');
        System.assertEquals('test@test.com', contactEMAIL.Code__c, 'EMAIL insert should be a success');
    }
    
    @isTest
    static void updateRecordCommunicationContacts(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        CommunicationContacts__c communicationSMS = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'SMS', Code__c = '11 911223344');
        CommunicationContacts__c communicationEMAIL = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        List<CommunicationContacts__c> communications = new List<CommunicationContacts__c>();
        communications.add(communicationSMS);
        communications.add(communicationEMAIL);
        insert communications;
        
        communicationSMS.Code__c = '11 911112222';
        
        ProposalContactDataService.upsertCommunicationContacts(communications);
        Test.stopTest();
        
        CommunicationContacts__c contactSMS   = [SELECT Id, Code__c FROM CommunicationContacts__c WHERE Account__c = :acc.Id AND Channel__c = 'SMS' LIMIT 1];
        CommunicationContacts__c contactEMAIL = [SELECT Id, Code__c FROM CommunicationContacts__c WHERE Account__c = :acc.Id AND Channel__c = 'EMAIL' LIMIT 1];
        
        System.assertEquals('11 911112222', contactSMS.Code__c, 'SMS update should be a success');
        System.assertEquals('test@test.com', contactEMAIL.Code__c, 'Email update should be a success');
    }
    
    @isTest
    static void upsertRecordCommunicationContactsFail(){
        Boolean exceptionOccurred = false;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        CommunicationContacts__c communicationSMS = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'SMS', Code__c = '11 911223344');
        CommunicationContacts__c communicationEMAIL = new CommunicationContacts__c(Account__c = acc.Id, Channel__c = 'EMAIL', Code__c = 'test@test.com');
        List<CommunicationContacts__c> communications = new List<CommunicationContacts__c>();
        communications.add(communicationSMS);
        communications.add(communicationEMAIL);
        insert communications;
        
        // Channel__c is expecting only two values: 'SMS' or 'EMAIL', therefore, any other value will result in error
        communicationEMAIL.Channel__c = 'teste';
        
        try{
            ProposalContactDataService.upsertCommunicationContacts(communications);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }
    
    @isTest
    static void insertCommunicationContacts(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opp.Id, MobileStatus__c = 'Aprovar');
        Test.startTest();
        ProposalContactDataService.upsertContactDetailsSection(contactDetail);
        Test.stopTest();
        ContactDetailsSection__c updatedContactDetailsSection = [SELECT Id, MobileStatus__c FROM ContactDetailsSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Aprovar', updatedContactDetailsSection.MobileStatus__c, '');
    }
    
    @isTest
    static void updateCommunicationContacts(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opp.Id, MobileStatus__c = 'Aprovar');
        insert contactDetail;
        contactDetail.MobileStatus__c = 'Pendenciar';
        
        Test.startTest();
        ProposalContactDataService.upsertContactDetailsSection(contactDetail);
        Test.stopTest();
        ContactDetailsSection__c updatedContactDetailsSection = [SELECT Id, MobileStatus__c FROM ContactDetailsSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals('Pendenciar', updatedContactDetailsSection.MobileStatus__c, '');
    }
    
    @isTest
    static void updateCommunicationContactsFail(){
        Boolean exceptionOccurred = false;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContactDetailsSection__c contactDetail = new ContactDetailsSection__c(Opportunity__c = opp.Id, MobileStatus__c = 'Aprovar');
        insert contactDetail;
        contactDetail.MobileStatus__c = 'Aguardando';
        
        Test.startTest();
        try{
            ProposalContactDataService.upsertContactDetailsSection(contactDetail);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        ContactDetailsSection__c updatedContactDetailsSection = [SELECT Id, MobileStatus__c FROM ContactDetailsSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
        System.assertEquals(true, exceptionOccurred, 'An exception should occur');
    }    
}