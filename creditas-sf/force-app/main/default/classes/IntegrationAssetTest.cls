/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe IntegrationAsset
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           18/01/2021      Created     Classe de teste para a classe IntegrationAsset
**********************************************************************************************************************************/
@isTest
global with sharing class IntegrationAssetTest {

    @TestSetup
    static void makeData(){
        Account testAcc = new Account(Name = 'test acc', ExternalId__c = 'PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664');
        insert testAcc;       
        
        Account spouseAcc = new Account(Name = 'spouse test', ExternalId__c = 'PER-EDF4345E-04C2-45C1-87D5-445F52391DA1');
        insert spouseAcc;
        
        FinancialResources__c testIncome = new FinancialResources__c(ExternalId__c = '43a6c3d0-47db-45f3-b410-b63859efd9a2');
    	insert testIncome;    
        
        AccountFinancialRelationship__c accRelationship = new AccountFinancialRelationship__c();
	    insert accRelationship;
    }
 
    @isTest
    static void testUpsertAssetSuccess(){   
        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';
        
        insert owner;
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMock());
        	RestContext.request = req;
        	RestContext.response= res;             
            IntegrationAsset.putMethod();  
            
            upsert [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];
        Test.stopTest();
        
        system.assertEquals(res.statusCode, 200); 
    }         
    
    @isTest
    static void testUpsertAssetError(){ 
        
        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';        
        insert owner;
        
        FinancialResources__c varFinancial = [SELECT Id, Account_Financial_Relationship__c  FROM FinancialResources__c LIMIT 1]; 
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockCertificate());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAsset.putMethod();  
			//delete the owner to get the error message
            delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];  
            IntegrationAsset.putMethod(); 
        Test.stopTest();      

        system.assertEquals(res.statusCode, 500, 'The owner(s) was not found on Salesforce.');
    }  
    
    static void testUpsertAssetNull(){      

        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';        
        insert owner;
        
        FinancialResources__c varFinancial = [SELECT Id, Account_Financial_Relationship__c  FROM FinancialResources__c LIMIT 1]; 
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockErroNull('owners'));        	
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(req.requestBody, null,'errorMessage = requestBodyObj.errorMessage' );      
    }  
    
    @isTest
    static void testSetErrorResponse(){ 
        
        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';
        
        insert owner;
        
        FinancialResources__c varFinancial = [SELECT Id, Account_Financial_Relationship__c  FROM FinancialResources__c LIMIT 1]; 
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockOthers());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAsset.putMethod();  
			//delete the owner to get the error message
            delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];  
            IntegrationAsset.putMethod(); 
        Test.stopTest();      

        system.assertEquals(res.statusCode, 500, 'An error has occurred. Please, contact a Salesforce Administrator.');      
    }  
    
    @isTest
    static void testAssetMockREAL_ESTATE(){ 
        
        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';        
        insert owner;
                
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockREAL_ESTATE());
        	RestContext.request = req;
        	RestContext.response= res;               
       
        	IntegrationAsset.putMethod();  
			//delete the owner to get the error message
            delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];  
            IntegrationAsset.putMethod(); 
        Test.stopTest();      

        system.assertEquals(res.statusCode, 500);      
    }  
    
    @isTest
    static void testAssetErrorNull(){ 

        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockREAL_ESTATE());
        	RestContext.request = null;
        	RestContext.response= null;             

            IntegrationAsset.putMethod(); 
        Test.stopTest();      

        system.assertEquals(res.statusCode, null);      
    }  
    
    @isTest
    static void testAssetOwnersNull(){ 

        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockOwnersNull());
        	RestContext.request = null;
        	RestContext.response = null; 
     
            IntegrationAsset.putMethod(); 
        Test.stopTest();      

        system.assertEquals(res.responseBody, null);      
    }  
}