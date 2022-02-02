@isTest
global with sharing class MinuatorSearchTest {  
    @isTest 
    public static void getAccessTokenSuccess() {        
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(201));         
        
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('https://auth-staging.creditas.com.br/api/consultants/tokens');
            request.setMethod('POST');                     
      		request.setHeader('grant_type', 'password'); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Cookie', '__cf_bm=X4J6ojMX0YK2yrGzHRcTPqlXDs_Nw1BgwL9UQ6TI0kU-1643395420-0-AXc5X0C5yIJaYODpoKDNOq6CMMJCXiFEdP3QpTcRgtRhzKTHZxo0r8mlqH+2/vVrKtb4ar80XcC8g28C5RhLRII=');
            request.setBody('{"grant_type": "password", "username": "consultor@creditas.com.br", "password": "tamuMaech7xa9thu"}');			
            HttpResponse response = http.send(request);        
            MinuatorSearchService.getAccessToken();
         Test.stopTest();

        MinuatorSearchService.getAccessToken();
     	System.assertEquals(201,response.getStatusCode(), 'The request has been fulfilled and resulted in a new resource being created.');
    }       
    
    @isTest 
    static void getAccessTokenFailed() {        
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(500)); 
        
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('https://auth-staging.creditas.com.br/api/consultants/tokens');
            request.setMethod('POST');                     
      		request.setHeader('grant_type', 'password'); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Cookie', '__cf_bm=X4J6ojMX0YK2yrGzHRcTPqlXDs_Nw1BgwL9UQ6TI0kU-1643395420-0-AXc5X0C5yIJaYODpoKDNOq6CMMJCXiFEdP3QpTcRgtRhzKTHZxo0r8mlqH+2/vVrKtb4ar80XcC8g28C5RhLRII=');
        	HttpResponse response = http.send(request);   
        MinuatorSearchService.getAccessToken();
         Test.stopTest();
        
        MinuatorSearchService.getAccessToken();
     	System.assertEquals(500,response.getStatusCode(), 'The request has been failed.');
    }       
    
    @isTest 
    static void getLeadSuccess() {   
        String friendlyId = 'friendlyId';
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(200));         
        
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId=');             
            request.setMethod('GET');	           
       		request.setHeader('grant_type', 'password');                  
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('X-TENANT-ID', 'creditasbr');      
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyId);
         Test.stopTest();

        String body = MinuatorSearchService.getLead(friendlyId);
     	System.assertEquals(body,response.getBody(), 'The request has been fulfilled.');
    }       
    
    @isTest 
    static void getLeadFailed() {   
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(500));  
        String friendlyIdError = 'friendlyId';
               
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId=');             
            request.setMethod('GET');	           
       		request.setHeader('grant_type', 'password');                  
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('X-TENANT-ID', 'creditasbr');      
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyIdError);
        Test.stopTest();
        
        response.getStatusCode();
     	System.assertEquals(500,response.getStatusCode(), 'The request has been Failed.');
    }      
    
    @isTest 
    static void getLeadFailedCatch() {             
        String friendlyIdError = 'friendlyId';
        String validateException = '';   
        
        Test.startTest();
        try{
            MinuatorSearchService.getLead(friendlyIdError);
        }catch(AuraHandledException e){
            validateException = e.getMessage();
        } 	            
        Test.stopTest();
        
        System.assertEquals('Script-thrown exception',validateException, 'The request has been Failed.');
    }
}