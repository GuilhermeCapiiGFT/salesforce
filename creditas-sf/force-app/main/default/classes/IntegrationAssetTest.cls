/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe IntegrationAsset
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           18/01/2021      Created     Classe de teste para a classe IntegrationAsset
*           Gabriel Vidal           03/03/2022      Updated     Class Refactor 
**********************************************************************************************************************************/
@isTest
global with sharing class IntegrationAssetTest {

    @TestSetup
    static void makeData(){
        Account testAcc = new Account(Name = 'Jose', ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111113');
        insert testAcc;       
        
        FinancialResources__c testIncome = new FinancialResources__c(ExternalId__c = 'AST-3FA85F64-5717-4562-B3FC-111111111111');
    	insert testIncome;    
        
        AccountFinancialRelationship__c accRelationship = new AccountFinancialRelationship__c();
        accRelationship.Account__c = testAcc.Id;
        accRelationship.Recurso_Financeiro__c = testIncome.Id;
	    insert accRelationship;
    }
 
    @isTest
    static void testUpsertAssetSuccess(){       
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();        
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('Success'));
        	RestContext.request = req;
        	RestContext.response= res;             
            IntegrationAssetController.putMethod();          
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Asset upsert successfully'); 
        
        List<FinancialResources__c> assetList = [SELECT Id FROM FinancialResources__c];
        System.assertEquals(1, assetList.size(),'FinancialResources upsert successfully'); 
        
        List<AccountFinancialRelationship__c> accFinancialRelationshipList = [SELECT Id FROM AccountFinancialRelationship__c];
        System.assertEquals(1, accFinancialRelationshipList.size(), 'Only one relation must be created, because the other owner id does not exist on salesforce'); 
    }  
    
    @isTest
    static void testUpsertAssetDmlError(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('assetDmlError'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		System.assertEquals(reqResString, '{"status":500,"message":"Currency ISO Code: invalid currency code: MXN","assetId":null}', 'Error inserting asset.');      
    }   
    
    @isTest
    static void testParseError(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('invalidJSON'));        	
        	RestContext.request = req;
        	RestContext.response= res;          
            IntegrationAssetController.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		system.assertEquals(reqResString, '{"status":500,"message":"Invalid JSON format.","assetId":null}','Invalid string for JSON format.');      
    }    

    @isTest
    static void testNullOwnerSuccess(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('nullOwners'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected success for null owners'); 
    }  

	@isTest
    static void testSucessForVehicleAsset(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('vehicle'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected success for vehicle asset type'); 
    }    
    
   	@isTest
    static void testSucessForRealStateAsset(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('realState'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected success for REAL_STATE asset type'); 
    }  
    
   	@isTest
    static void testSucessForOthersAsset(){      
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('other'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected success for any other asset type'); 
    }    
    
    @isTest
    static void testIfAccountRelationIsDeleted(){      
        Test.startTest();
       		Account testAccToDissociate = new Account(Name = 'Jose', ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111118');
        	insert testAccToDissociate;       
        
        	FinancialResources__c testIncome = [SELECT Id FROM FinancialResources__c WHERE ExternalId__c = 'AST-3FA85F64-5717-4562-B3FC-111111111111'];
        
       		AccountFinancialRelationship__c accRelationshipToBeDeleted = new AccountFinancialRelationship__c();
        	accRelationshipToBeDeleted.Account__c = testAccToDissociate.Id;
        	accRelationshipToBeDeleted.Recurso_Financeiro__c = testIncome.Id;
	    	insert accRelationshipToBeDeleted;
        	
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(getAssetMock('Success'));        	
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAssetController.putMethod();    
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected Asset sucessfully upserted'); 
        
        List<AccountFinancialRelationship__c> deletedRelations = [SELECT Id FROM AccountFinancialRelationship__c WHERE Account__r.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111118'];
        System.assertEquals(deletedRelations.size(), 0, 'Check if the relation was deleted after upsert method execution'); 
    } 

    static String getAssetMock(String param)
    {
        String currencyCode = param == 'assetDmlError' ? '"currencyCode": "MXN",' : '"currencyCode": "BRL",';
        String version = param == 'invalidJSON' ? '"version": "A",' : '"version": 1,';
        String assetType = param == 'vehicle' ? '"type": "VEHICLE",' : 
        	param == 'realState' ? '"type": "REAL_ESTATE",' :
        	param == 'other' ? '"type": "OTHER",' 
            : '"type": "CERTIFICATE",';
        
        
        String owners = param == 'nullOwners' ? '"owners": null,'
       	: '"owners": ['+
		  '    {'+
		  '      "person": {'+
		  '        "id": "PER-3FA85F64-5717-4562-B3FC-111111111113",'+
		  '        "version": 1'+
		  '      }'+
  		  '    },'+
          '    {'+
		  '      "person": {'+
		  '        "id": "PER-3FA85F64-5617-4562-B3FC-111111111112",'+
		  '        "version": 1'+
		  '      }'+
  		  '    }'+  
		  '  ],';

        String json=		'{'+
		'  "id": "AST-3FA85F64-5717-4562-B3FC-111111111111",'+
		version+
		assetType+
		owners+
		'  "value": {'+
		'    "amount": {'+
		currencyCode+
		'      "amount": "30000"'+
		'    },'+
		'    "appraisalDate": "2019-05-10"'+
		'  },'+
		'  "alienation": {'+
		'    "financialInstitution": "001"'+
		'  },'+
		'  "assetDetail": {'+
		'    "type": "CAR",'+
		'    "chassis": "123414141",'+
		'    "plate": "EIO7016",'+
		'    "brand": "Ford",'+
		'    "model": "Fiesta Sedan 1.6 16V Flex Mec.",'+
		'    "modelYear": 2014,'+
		'    "manufacturingYear": 2013,'+
		'    "licensing": {'+
		'      "address": {'+
		'        "administrativeAreaLevel1": "Pernambuco",'+
		'        "administrativeAreaLevel2": "Recife",'+
		'        "street": "Recife address",'+
		'        "neighborhood": "Boa Vista",'+
		'        "streetNumber": "5432",'+
		'        "complement": "apartment 43",'+
		'        "zipCode": "87989-000"'+
		'      }'+
		'    },'+
		'    "color": "Azul",'+
		'    "fuelType": "GASOLINE",'+
		'    "state": "SP",'+
		'    "category": "PERSONAL",'+
		'    "externalCodes": ['+
		'      {'+
		'        "origin": "FIPE",'+
		'        "code": "008026-8"'+
		'      }'+
		'    ]'+
		'  },'+
		'  "createdAt": "2019-01-10T10:00:01Z",'+
		'  "updatedAt": "2019-01-10T12:00:01Z"'+
		'}';

        return json;
    }
}