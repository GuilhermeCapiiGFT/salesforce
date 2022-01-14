@isTest
public class SearchControllerTest {
    
    @testSetup
    public static void createData() {
        
        List<Account> lLstAccount = new List<Account>();
        Account lAccMaria = new Account(Name = 'Maria');
        Account lAccJoana = new Account(Name = 'Joana');
        
        lLstAccount.add(lAccMaria);
        lLstAccount.add(lAccJoana);

        insert lLstAccount;
        
        Contact lContact = new Contact(FirstName= 'Joao', LastName = 'Junior');
        insert lContact;
    }

    @isTest
    public static void getContactBySearch(){
		Contact lContact = [SELECT Id, Name FROM Contact WHERE LastName = 'Junior' LIMIT 1];
        Id [] fixedSearchResults = new Id[] {lContact.id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        List<sObject> lLstResult = SearchController.search('Contact', 'Juni');
        Test.stopTest();
        
        System.assert( lLstResult.size() > 0);
    }
    
    @isTest
    public static void getAccountBySearch(){
		Account lAcc = [SELECT Id, Name FROM Account WHERE Name = 'Maria' LIMIT 1];
        Id [] fixedSearchResults = new Id[] {lAcc.id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        List<sObject> lLstResult = SearchController.search('Account', 'Mari');
        Test.stopTest();
        
        System.assert( lLstResult.size() > 0);
    }
    
    @isTest
    public static void updateTaskTest(){
		Account lAcc = [SELECT Id, Name FROM Account WHERE Name = 'Maria' LIMIT 1];
        
        Test.startTest();
        sObject lLstResult = SearchController.getRelatedRecord('Account', lAcc.Id);
        Test.stopTest();
        
        System.assertEquals( 'Maria', lLstResult.get('Name'));
    }
    
    @isTest
    public static void searchErro(){
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	SearchController.search('Acccount','abc');
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
    
    @isTest
    public static void getRelatedRecordErro(){
        Account lAcc = [SELECT Id, Name FROM Account WHERE Name = 'Maria' LIMIT 1];
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	SearchController.getRelatedRecord('Acccount',lAcc.Id);
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
}