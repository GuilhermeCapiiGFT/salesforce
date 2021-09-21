@IsTest
global with sharing class IntegrationAccountINTest {
    
    @isTest
    static void testUpsertAccount(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'POST';
        	req.requestBody = Blob.valueof(IntegrationAccountINMock.accountMock());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.postMethod();          
        	IntegrationAccountIN.postMethod();
        Test.stopTest();     
    }    
    
    @isTest
    static void testUpsertAccount2(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'POST';
        	req.requestBody = Blob.valueof(IntegrationAccountINMock.accountMock2());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.postMethod();          
        	IntegrationAccountIN.postMethod();
        Test.stopTest();     
    }    
    
}