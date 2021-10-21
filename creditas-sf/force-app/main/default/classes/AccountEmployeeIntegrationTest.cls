@isTest
public with sharing class AccountEmployeeIntegrationTest {
    static testMethod void updateEmployeeTest() {
		String json=		'{'+
		'    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",'+
		'    "tenant": "CREDITASBR",'+
		'    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",'+
		'    "personVersion": 2,'+
		'    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",'+
		'    "status": "ACTIVE",'+
		'    "employeeType": "STANDARD_CONTRACT",'+
		'    "margin": {'+
		'        "currency": "BRL",'+
		'        "amount": 5000'+
		'    },'+
		'    "salary": {'+
		'        "currency": "BRL",'+
		'        "amount": 10000'+
		'    },'+
		'    "employeeCode": "5024",'+
		'    "admissionDate": "2015-01-01",'+
		'    "sourceId": "FILEIMP-0aada683-f912-4391-97ff-efc73049b5cc",'+
		'    "version": 460'+
		'}';

        Test.startTest();

            AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/Account/updateEmployee'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             

            AccountEmployeeIntegration.updateEmployee();         
        Test.stopTest();   
	}

    static testMethod void updateEmployeeWithIdTest() {
		String json=		'{'+
		'    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",'+
		'    "tenant": "CREDITASBR",'+
		'    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",'+
		'    "personVersion": 2,'+
		'    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",'+
		'    "status": "ACTIVE",'+
		'    "employeeType": "STANDARD_CONTRACT",'+
		'    "margin": {'+
		'        "currency": "BRL",'+
		'        "amount": 5000'+
		'    },'+
		'    "salary": {'+
		'        "currency": "BRL",'+
		'        "amount": 10000'+
		'    },'+
		'    "employeeCode": "5024",'+
		'    "admissionDate": "2015-01-01",'+
		'    "sourceId": "FILEIMP-0aada683-f912-4391-97ff-efc73049b5cc",'+
		'    "version": 460'+
		'}';

        Test.startTest();

            Account acc = new Account();
            acc.Name = 'Account teste';
            acc.ExternalId__c = 'PER-784029DB-7142-48D7-A8AC-475B96FFB325';
            insert acc;
            
            AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/Account/updateEmployee'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             

            AccountEmployeeIntegration.updateEmployee();         
        Test.stopTest();   
	}
}