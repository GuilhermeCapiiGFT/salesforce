/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Test class with AccountEmployeeIntegration
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Guilherme Assis       09/11/2021        Created     Test class with AccountEmployeeIntegration
**********************************************************************************************************************************/

@isTest
public with sharing class AccountEmployeeIntegrationTest {
    static testMethod void updateEmployeeTest() {
		String json=		'{'+
		'    "version": 1,	'+
		'    "createdAt": "2020-04-04 9:24:55",	'+
		'    "updatedAt": "2020-04-04 9:24:55",	'+
		'    "employeeCode": "5856",	'+
		'    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",	'+
		'    "employeeType": "STANDARD_CONTRACT",	'+
		'    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",	'+
		'    "personVersion": 1,	'+
		'    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",	'+
		'    "mainDocument": {'+
		'        "code": "45106105803",'+
		'        "type": "CPF"'+
		'    },'+
		'    "tenant": "creditasbr",	'+
		'    "status": "ACTIVE",	'+
		'    "admissionDate": "2015-01-01",	'+
		'    "margin": {'+
		'        "amount": 333,'+
		'        "currency": "BRL"'+
		'    },'+
		'    "salary": {'+
		'        "amount": 1000,'+
		'        "currency": "BRL"'+
		'    }'+
		'}';

        Test.startTest();

            AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/Account/upsertEmployee'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             

            AccountEmployeeIntegration.upsertEmployee();         
        Test.stopTest();   
	}

    static testMethod void updateEmployeeWithIdTest() {
		String json=		'{'+
		'    "version": 1,	'+
		'    "createdAt": "2020-04-04 9:24:55",	'+
		'    "updatedAt": "2020-04-04 9:24:55",	'+
		'    "employeeCode": "5856",	'+
		'    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",	'+
		'    "employeeType": "STANDARD_CONTRACT",	'+
		'    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",	'+
		'    "personVersion": 1,	'+
		'    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",	'+
		'    "mainDocument": {'+
		'        "code": "45106105803",'+
		'        "type": "CPF"'+
		'    },'+
		'    "tenant": "creditasbr",	'+
		'    "status": "ACTIVE",	'+
		'    "admissionDate": "2015-01-01",	'+
		'    "margin": {'+
		'        "amount": 333,'+
		'        "currency": "BRL"'+
		'    },'+
		'    "salary": {'+
		'        "amount": 1000,'+
		'        "currency": "BRL"'+
		'    }'+
		'}';

        Test.startTest();

            Account acc = new Account();
            acc.Name = 'Account teste';
            acc.ExternalId__c = 'PER-784029DB-7142-48D7-A8AC-475B96FFB325';
            insert acc;
            
            AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/Account/upsertEmployee'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             

            AccountEmployeeIntegration.upsertEmployee();         
        Test.stopTest();   
	}
}