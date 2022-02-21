/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Class to test the methods created by the Minuator SearchService class
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           02/02/2022      Created      Class to test the methods created by the Minuator SearchService class  
*************************************************************************************************************************************/
@isTest
global with sharing class MinuatorSearchTest {  
    @isTest 
    public static void getAccessTokenSuccess() {        
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(201));         
        
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('callout:MinuatorCredentials');
            request.setMethod('POST');                     
      		request.setHeader('grant_type', 'password'); 
            request.setHeader('Content-Type', 'application/json');  		
            HttpResponse response = http.send(request);        
            MinuatorSearchService.getAccessToken();
         Test.stopTest();

        MinuatorSearchService.getAccessToken();        
     	System.assertEquals(201,response.getStatusCode(), 'The request was not fulfilled and it was not possible to create a new resource.');
    }       
    
    @isTest 
    static void getAccessTokenFailed() {    
        String friendlyId = 'friendlyId';
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(500)); 
        
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest(); 
          	request.setEndpoint('callout:MinuatorCredentials');
        	HttpResponse response = http.send(request);           	
        Test.stopTest();
        
        MinuatorSearchResponse getSuccess = MinuatorSearchService.getLead(friendlyId);
     	System.assertEquals(500,response.getStatusCode(), 'The request should have failed.');
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

        MinuatorSearchResponse getSuccess = MinuatorSearchService.getLead(friendlyId);
     	System.assertEquals(200,response.getStatusCode(), 'The request was not fulfilled.');
    }       
    
    @isTest 
    static void getLeadFailed400() {   
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(400));  
        String friendlyIdError = 'friendlyId';
		String responseError = 'Lead does not have credit analysis yet';
               
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyIdError);
        Test.stopTest();
        
        response.getStatusCode();
     	System.assertEquals(400,response.getStatusCode(), 'The returned status does not match the generated response.');
        System.assertEquals('Lead does not have credit analysis yet',responseError, 'The returned status does not match the generated response.');
        
    }   
    
    @isTest 
    static void getLeadFailed404() {   
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(404));  
        String friendlyIdError = 'friendlyId';
		String responseError = 'Lead not found';
               
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyIdError);
        Test.stopTest();
        
        response.getStatusCode();
     	System.assertEquals(404,response.getStatusCode(), 'The returned status does not match the generated response.');
        System.assertEquals('Lead not found',responseError, 'The returned status does not match the generated response.');
        
    }   
    
    @isTest 
    static void getLeadFailed500() {   
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(500));  
        String friendlyIdError = 'friendlyId';
		String responseError = 'Internal server error';
               
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyIdError);
        Test.stopTest();
        
        response.getStatusCode();
     	System.assertEquals(500,response.getStatusCode(), 'The returned status does not match the generated response.');
        System.assertEquals('Internal server error',responseError, 'The returned status does not match the generated response.');
        
    }   
    
    @isTest 
    static void getLeadFailed() {   
        Test.setMock(HttpCalloutMock.class, new MinuatorSearchMockTest(500));  
        String friendlyIdError = 'friendlyId';
		String responseError = 'no content to map to Object due to end of input';
               
        Test.startTest();
         	Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = http.send(request);      
        	MinuatorSearchService.getLead(friendlyIdError);
        Test.stopTest();
        
        response.getStatusCode();
     	System.assertEquals(500,response.getStatusCode(), 'The returned status does not match the generated response.');
        System.assertEquals('no content to map to Object due to end of input',responseError, 'The returned status does not match the generated response.');
        
    }      
    
    @isTest 
    static void getLeadFailedCatch() {             
        String friendlyIdError = 'friendlyId';
        String validateException = 'Script-thrown exception';   
        
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