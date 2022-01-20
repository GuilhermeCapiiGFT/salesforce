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
        Account testAcc = new Account(Name = 'Jose', ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111113');
        insert testAcc;       
        
        FinancialResources__c testIncome = new FinancialResources__c(ExternalId__c = 'AST-3FA85F64-5717-4562-B3FC-111111111111');
    	insert testIncome;    
        
        AccountFinancialRelationship__c accRelationship = new AccountFinancialRelationship__c(Account__c = testAcc.Id, Recurso_Financeiro__c = testIncome.Id);
	    insert accRelationship;
    }
 
    @isTest
    static void testUpsertAssetSuccess(){   
        /*Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';        
        insert owner;*/
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();        
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMock());
        	RestContext.request = req;
        	RestContext.response= res;             
            IntegrationAsset.putMethod();          
        Test.stopTest();
        System.assertEquals(res.statusCode, 200); 
        
        List<FinancialResources__c> assetList = [SELECT Id FROM FinancialResources__c];
        System.assertEquals(1, assetList.size()); 
        
        List<AccountFinancialRelationship__c> accFinancialRelationshipList = [SELECT Id FROM AccountFinancialRelationship__c];
        System.assertEquals(1, accFinancialRelationshipList.size()); 
    }  
    
    @isTest
    static void testUpsertAssetDmlError(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockDmlError());        	
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAsset.putMethod();          
        Test.stopTest();
        System.debug(EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString());
		system.assertEquals(res.statusCode, 500);      
    }   
    
    @isTest
    static void testParseError(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof('string inválida para formato JSON');        	
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAsset.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 500);      
    }         

	@isTest
    static void testUpsertAssetNullOwner(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMockErroNull('nullOwners'));        	
        	RestContext.request = req;
        	RestContext.response= res;  
        
        	IntegrationAsset.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();

       	system.assertEquals(reqResString, '{"status":500,"message":"The owner(s) was not found on Salesforce.","assetId":null}');   
		system.assertEquals(res.statusCode, 500);      
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
            delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1]; 
            IntegrationAsset.putMethod();   	
		Test.stopTest();
        
        List<Account> errorAccount = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1]; 
        
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		system.assertEquals(reqResString, '{"status":500,"message":"The owner(s) was not found on Salesforce.","assetId":null}');
        system.assertEquals(res.statusCode, 500);
    }   
    
    @isTest
    static void testAssetErrorNull(){ 
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
        	RestContext.request = null;
        	RestContext.response= null;           
            IntegrationAsset.putMethod(); 
        Test.stopTest();      
        
        List<Account> errorAccount = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];  
        system.assertEquals(res.statusCode, null);    
    }    
    
    @isTest
    static void testSetErrorResponseOthers(){         
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
       		/*delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];
       		IntegrationAsset.putMethod();*/
        Test.stopTest();  
        
		List<Account> errorAccount = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1]; 
        system.assertEquals(res.statusCode, 200);      
    }  
    
    @isTest
    static void testAssetMockErrorRealState(){        
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
      		delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];
        	IntegrationAsset.putMethod();
        Test.stopTest();   
        
		List<Account> errorAccount = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];  
        system.assertEquals(res.statusCode, 500);      
    }  
}