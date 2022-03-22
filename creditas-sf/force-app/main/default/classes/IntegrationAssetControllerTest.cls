/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe IntegrationAssetController
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           14/03/2022      Updated     Class Refactor 
**********************************************************************************************************************************/
@isTest
global with sharing class IntegrationAssetControllerTest {
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
        
        String responseMessage = res.responseBody.toString();
        System.assert(responseMessage.startsWith('Asset successfully upserted')); 
        System.assertEquals(res.statusCode, 200); 
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

        System.assertEquals(500, res.statusCode, 'Error for invalid currency code');
        System.assertEquals(res.responseBody.toString(), 'Currency ISO Code: invalid currency code: MXN'); 
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

        System.assertEquals(500, res.statusCode, 'JSON parse error');
        System.assertEquals(res.responseBody.toString(), 'Invalid JSON format.');   
    }    

    static String getAssetMock(String param)
    {
        String currencyCode = param == 'assetDmlError' ? '"currencyCode": "MXN",' : '"currencyCode": "BRL",';
        String version = param == 'invalidJSON' ? '"version": "A",' : '"version": 1,';       
        String json=		'{'+
		'  "id": "AST-3FA85F64-5717-4562-B3FC-111111111111",'+
		version+
		'  "type": "CERTIFICATE",'+
        '  "owners": ['+
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
        '  ],'+
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