@isTest
private with sharing class AccountCompanyIntegrationControllerTest {

    @TestSetup
    static void makeData(){
        Account account = AccountSetup.createAccount('Dupão LTDA', 'Pessoa_Juridica');
        account.ExternalId__c = 'DUPAO-EXTERNALID';
        insert account;
    }

    @isTest
    private static void testSucess(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Test.startTest();
        req.requestURI = '/services/apexrest/Account/Company/'; 
        req.httpMethod = 'POST';
        String jsonMock = AccountCompanyIntegrationVO.jsonMock('sucess');
        req.requestBody = Blob.valueof(jsonMock);
        RestContext.request = req;
        RestContext.response = res;       
        AccountCompanyIntegrationController.upsertCompany();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected 200');
        System.assertEquals(1, [SELECT Count() FROM Account], 'Expected 1 account');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('Company successfully upserted.', responseBodyString, 'wrong returned message');
    }

    @isTest
    private static void testInvalidCNPJ(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Test.startTest();
        req.requestURI = '/services/apexrest/Account/Company/'; 
        req.httpMethod = 'POST';
        String jsonMock = AccountCompanyIntegrationVO.jsonMock('invalidCNPJ');
        req.requestBody = Blob.valueof(jsonMock);
        RestContext.request = req;
        RestContext.response = res;       
        AccountCompanyIntegrationController.upsertCompany();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('Fields: (DocumentNumber__c) Message: O CNPJ não é válido.', responseBodyString, 'wrong returned message');
    }

    @isTest
    private static void testInvalidProducts(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Test.startTest();
        req.requestURI = '/services/apexrest/Account/Company/'; 
        req.httpMethod = 'POST';
        String jsonMock = AccountCompanyIntegrationVO.jsonMock('invalidProducts');
        req.requestBody = Blob.valueof(jsonMock);
        RestContext.request = req;
        RestContext.response = res;       
        AccountCompanyIntegrationController.upsertCompany();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('Payload must have at least one enabledProduct.', responseBodyString, 'wrong returned message');
    }

    @isTest
    private static void testInvalidCompanyId(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Test.startTest();
        req.requestURI = '/services/apexrest/Account/Company/'; 
        req.httpMethod = 'POST';
        String jsonMock = AccountCompanyIntegrationVO.jsonMock('invalidCompanyId');
        req.requestBody = Blob.valueof(jsonMock);
        RestContext.request = req;
        RestContext.response = res;       
        AccountCompanyIntegrationController.upsertCompany();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('CompanyId cannot be null.', responseBodyString, 'wrong returned message');
    }
        
    
    
}