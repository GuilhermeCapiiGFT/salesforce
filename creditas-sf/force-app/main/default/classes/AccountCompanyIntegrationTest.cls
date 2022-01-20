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
public with sharing class AccountCompanyIntegrationTest {

	static testMethod void updateAccountCompanyTest() {
		String json= '{'+   
        '	"id": "867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2020-04-04 9:24:55",	'+
        '	"updatedAt": "2020-04-04 9:24:55",	'+
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

            AccountCompanyIntegration.upsertCompany();       
        Test.stopTest();   
      }    
    
    static testMethod void updateCompanyWithIdTest() {
        String json= '{'+   
        '	"id": "867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2020-04-04 9:24:55",	'+
        '	"updatedAt": "2020-04-04 9:24:55",	'+
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

            Account acc = new Account();
            acc.Name = 'Account teste';
            acc.ExternalCompanyId__c = '867d112e-8a8d-4dd9-a7ad-37c83a5bf7e20';
            insert acc;
            
           	AccountCompanyIntegrationVO VO = new AccountCompanyIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/Account/Company'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
 
			AccountCompanyIntegration.upsertCompany();      
        Test.stopTest();   
    }
            
}