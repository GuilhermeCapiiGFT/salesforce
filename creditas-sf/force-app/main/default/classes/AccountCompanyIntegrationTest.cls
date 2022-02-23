/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test Class to AccountCompanyIntegration Class.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          10/11/2021      Created     Test Class to AccountCompanyIntegration Class.
**********************************************************************************************************************************/

@isTest
private with sharing class AccountCompanyIntegrationTest {

    @isTest
	private static void updateAccountCompanyTest() {
		String json= '{'+   
        '	"id": "867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2022-01-11T20:52:58.435624",	'+
        '	"updatedAt": "2022-01-11T20:52:58.435636",	'+
        '	"mainDocument":{	'+
        '	"type": "CNPJ",	'+
        '	"code": "89584475000186"	'+
        '	},	'+
        '	"businessName": "Testando 1", '+
        '	"legalName": "Testando Ltda",	'+
        '	"enabledProducts": [	'+
        '	"STORE",	'+
        '	"PAYROLL", '+
        '	"SALARY_ADVANCE", '+
        '	"CREDIT_CARD", '+
        '	"BENEFITS_CARD" '+
        '	]	'+
        '	 } '; 
        
        
        Test.startTest();
        AccountCompanyIntegrationVO VO = new AccountCompanyIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Account/Company'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        String lResponse = AccountCompanyIntegration.upsertCompany();    
        Test.stopTest();
        System.assertEquals(200, res.statusCode, 'Status code incorreto');
        Account lAcc = [SELECT DocumentNumber__c,ExternalId__c, Name FROM Account LIMIT 1];
        System.assertEquals('89.584.475/0001-86', lAcc.DocumentNumber__c, 'Wrong DocumentNumber');
        System.assertEquals('867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20', lAcc.ExternalId__c, 'Wrong External Company');
        System.assertEquals('Registro criado/atualizado com sucesso!', lResponse, 'Registro não foi inserido');
      }

    @isTest
    private static void upsertAccountCompanyTest() {
        String json= '{'+   
        '	"id": "867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2022-01-11T20:52:58.435624",	'+
        '	"updatedAt": "2022-01-11T20:52:58.435636",	'+
        '	"mainDocument":{	'+
        '	"type": "CNPJ",	'+
        '	"code": "89584475000186"	'+
        '	},	'+
        '	"businessName": "Testando 1", '+
        '	"legalName": "Testando Ltda",	'+
        '	"enabledProducts": [	'+
        '	"STORE",	'+
        '	"PAYROLL", '+
        '	"SALARY_ADVANCE", '+
        '	"CREDIT_CARD", '+
        '	"BENEFITS_CARD" '+
        '	]	'+
        '	 } '; 
        
        Account lNewAcc = AccountSetup.createAccount('Test', 'Pessoa_Juridica');
        lNewAcc.ExternalId__c = '867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20';
        insert lNewAcc;
        
        Test.startTest();
        AccountCompanyIntegrationVO VO = new AccountCompanyIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Account/Company'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
		String lResponse = AccountCompanyIntegration.upsertCompany();      
        Test.stopTest();
        System.assertEquals(200, res.statusCode, 'Status code incorreto');
        Account lAcc = [SELECT DocumentNumber__c,ExternalId__c, Name FROM Account LIMIT 1];
        System.assertEquals('89.584.475/0001-86', lAcc.DocumentNumber__c, 'Wrong DocumentNumber');
        System.assertEquals('867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20', lAcc.ExternalId__c, 'Wrong External Company');
        System.assertEquals('Testando 1', lAcc.Name, 'Wrong Name');
        System.assertEquals('Registro criado/atualizado com sucesso!', lResponse, 'Registro não foi atualizado');
    }

    @isTest
    private static void exceptionTest() {
        String json= '{'+   
        '	"id": "",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2022-01-11T20:52:58.435624",	'+
        '	"updatedAt": "2022-01-11T20:52:58.435636",	'+
        '	"mainDocument":{	'+
        '	"type": "CNPJ",	'+
        '	"code": "89584475000186"	'+
        '	},	'+
        '	"businessName": "Testando 1", '+
        '	"legalName": "Testando Ltda",	'+
        '	"enabledProducts": [	'+
        '	"STORE",	'+
        '	"PAYROLL", '+
        '	"SALARY_ADVANCE", '+
        '	"CREDIT_CARD", '+
        '	"BENEFITS_CARD" '+
        '	]	'+
        '	 } '; 
                
        Test.startTest();
        AccountCompanyIntegrationVO VO = new AccountCompanyIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Account/Company'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
		String lResponse = AccountCompanyIntegration.upsertCompany();      
        Test.stopTest();
        System.assertEquals(400, res.statusCode, 'Status code incorreto');
        System.assertEquals(0, [SELECT Count() FROM Account], 'Não deveria existir nenhuma conta');
        System.assertEquals('CompanyId inválido!', lResponse,'Wrong Response');
    }
            
}