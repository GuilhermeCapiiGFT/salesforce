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
    static void getContactDetailsSucess(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
  		ContactDetailsSection__c communications = new ContactDetailsSection__c( Email__c = 'test@test123.com', Mobile__c = '11 911223344', Opportunity__c = opp.id );
        insert communications;
        
        Test.startTest();
        ProposalContactDataController.getContactDetails(opp.Id);
        Test.stopTest();
        
        List<ContactDetailsSection__c> contactDetailSec = [SELECT Email__c, Mobile__c, Opportunity__c FROM ContactDetailsSection__c WHERE Opportunity__r.Name = 'Teste'];
       System.assert(!contactDetailSec.isEmpty(), 'ContactDetailsSection not found');
        
       System.assertEquals(contactDetailSec[0].Email__c,'test@test123.com', 'Incorrect Email value');
       System.assertEquals(contactDetailSec[0].Mobile__c, '11 911223344', 'Incorrect Email value');      
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