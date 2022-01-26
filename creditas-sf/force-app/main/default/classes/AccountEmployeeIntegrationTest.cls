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
private with sharing class AccountEmployeeIntegrationTest {

  @isTest
  private static void updateEmployeeTest() {
    String json =
      '{' +
      '    "version": 1,	' +
      '    "createdAt": "2022-01-12T09:31:08.615466",	' +
      '    "updatedAt": "2022-01-12T09:31:08.615466",	' +
      '    "employeeCode": "5856",	' +
      '    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",	' +
      '    "employeeType": "STANDARD_CONTRACT",	' +
      '    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",	' +
      '    "personVersion": "1",	' +
      '    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",	' +
      '    "MainDocument": {' +
      '        "code": "45106105803",' +
      '        "type": "CPF"' +
      '    },' +
      '    "tenant": "creditasbr",	' +
      '    "status": "ACTIVE",	' +
      '    "admissionDate": "2015-01-01",	' +
      '    "margin": {' +
      '        "amount": 333.9,' +
      '        "currency": "BRL"' +
      '    },' +
      '    "salary": {' +
      '        "amount": 1000.9,' +
      '        "currency": "BRL"' +
      '    }' +
      '}';

      
      Test.startTest();

        AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Account/upsertEmployee';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response = res;
        
        String lResponse = AccountEmployeeIntegration.upsertEmployee();

      Test.stopTest();

      System.assertEquals('Registro criado/atualizado com sucesso', lResponse, 'Wrong Response');
      System.assertEquals(200, res.statusCode, 'Wrong Status Code');
      Account lAcc = [SELECT DocumentNumber__c,ExternalId__c, Name FROM Account LIMIT 1];
      System.assertEquals('451.061.058-03', lAcc.DocumentNumber__c, 'Wrong DocumentNumber');
      System.assertEquals('PER-784029DB-7142-48D7-A8AC-475B96FFB325', lAcc.ExternalId__c, 'Wrong External Company');

  }

  @isTest
  private static void upsertAccountEmployeeTest() {
    String json =
      '{' +
      '    "version": 1,	' +
      '    "createdAt": "2022-01-12T09:31:08.615466",	' +
      '    "updatedAt": "2022-01-12T09:31:08.615466",	' +
      '    "employeeCode": "5856",	' +
      '    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",	' +
      '    "employeeType": "STANDARD_CONTRACT",	' +
      '    "personId": "PER-784029DB-7142-48D7-A8AC-475B96FFB325",	' +
      '    "personVersion": "1",	' +
      '    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",	' +
      '    "MainDocument": {' +
      '        "code": "45106105803",' +
      '        "type": "CPF"' +
      '    },' +
      '    "tenant": "creditasbr",	' +
      '    "status": "ACTIVE",	' +
      '    "admissionDate": "2015-01-01",	' +
      '    "margin": {' +
      '        "amount": 333.9,' +
      '        "currency": "BRL"' +
      '    },' +
      '    "salary": {' +
      '        "amount": 1000.9,' +
      '        "currency": "BRL"' +
      '    }' +
      '}';

      
      Account acc = AccountSetup.createAccount('UserAccount', 'Pessoa_Fisica');
      acc.Name = 'Pedro';
      acc.ExternalId__c = 'PER-784029DB-7142-48D7-A8AC-475B96FFB325';
      insert acc;
      
    Test.startTest();

      AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      
      req.requestURI = '/services/apexrest/Account/upsertEmployee';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(json);
      RestContext.request = req;
      RestContext.response = res;
      
      String lResponse = AccountEmployeeIntegration.upsertEmployee();

    Test.stopTest();

    System.assertEquals('Registro criado/atualizado com sucesso', lResponse, 'Wrong Response');
    System.assertEquals(200, res.statusCode, 'Wrong Status Code');
    Account lAcc = [SELECT DocumentNumber__c, Name, ExternalId__c FROM Account LIMIT 1];
    System.assertEquals('451.061.058-03', lAcc.DocumentNumber__c, 'Wrong DocumentNumber');
    System.assertEquals('PER-784029DB-7142-48D7-A8AC-475B96FFB325', lAcc.ExternalId__c, 'Wrong External Id');
  }

  @isTest
  private static void exceptionAccountEmployeeTest() {
    String json =
      '{' +
      '    "version": 1,	' +
      '    "createdAt": "2022-01-12T09:31:08.615466",	' +
      '    "updatedAt": "2022-01-12T09:31:08.615466",	' +
      '    "employeeCode": "5856",	' +
      '    "companyId": "042b3737-6288-4335-9f43-ee74b3f38f60",	' +
      '    "employeeType": "STANDARD_CONTRACT",	' +
      '    "personId": "",	' +
      '    "personVersion": "1",	' +
      '    "id": "69696d82-d3b3-4e3a-9cc5-965b1273da88",	' +
      '    "MainDocument": {' +
      '        "code": "45106105803",' +
      '        "type": "CPF"' +
      '    },' +
      '    "tenant": "creditasbr",	' +
      '    "status": "ACTIVE",	' +
      '    "admissionDate": "2015-01-01",	' +
      '    "margin": {' +
      '        "amount": 333.9,' +
      '        "currency": "BRL"' +
      '    },' +
      '    "salary": {' +
      '        "amount": 1000.9,' +
      '        "currency": "BRL"' +
      '    }' +
      '}';
      
    Test.startTest();
      AccountEmployeeIntegrationVO VO = new AccountEmployeeIntegrationVO();
      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      
      req.requestURI = '/services/apexrest/Account/upsertEmployee';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(json);
      RestContext.request = req;
      RestContext.response = res;
      
      String lResponse = AccountEmployeeIntegration.upsertEmployee();
    Test.stopTest();

    System.assertEquals('PersonId invalido.', lResponse, 'Wrong Response');
    System.assertEquals(400, res.statusCode, 'Wrong Status Code');
    System.assertEquals(0, [SELECT Count() FROM Account], 'Não deveriam existir Accounts');
    
  }
}