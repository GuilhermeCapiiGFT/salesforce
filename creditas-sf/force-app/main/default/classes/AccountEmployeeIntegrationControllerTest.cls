@IsTest
private class AccountEmployeeIntegrationControllerTest {
  private static final String ENDPOINT = '/services/apexrest/Account/Employee/upsertEmployee';

  @TestSetup
  private static void makeData() {
    String accountPersonRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
    String accountCompanyRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');

    insert new List<Account>{
      new Account(Name = 'João da Silva', ExternalId__c = 'TEST-PERSON-001', RecordTypeId = accountPersonRecordTypeId),
      new Account(Name = 'Creditas', ExternalId__c = 'TEST-COMPANY-001', RecordTypeId = accountCompanyRecordTypeId)
    };
  }

  @IsTest
  private static void testSuccessfullRequest() {
    String json = getJsonPayload();

    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response = res;

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(200, res.statusCode, 'Status Code should be 200');
    System.assertEquals('Record created/updated successfully.', response, 'Wrong response');
  }

  @IsTest
  private static void testJsonParseException() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('"version": 1,', '"version": ,'));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(400, res.statusCode, 'Status Code should be 400');
    System.assert(response.startsWith('Error: JSON parse failed'), 'Wrong response');
  }

  @IsTest
  private static void testRequiredFieldsMissingException() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('"TEST-EMPLOYEE-001"', '" "'));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(400, res.statusCode, 'Status Code should be 400');
    System.assert(response.startsWith('Error: required field(s) missing'), 'Wrong response');
  }

  @IsTest
  private static void testInvalidDateException() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('"2022-02-22"', '"-"'));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(400, res.statusCode, 'Status Code should be 400');
    System.assert(response.startsWith('Error: couldn\'t parse date string'), 'Wrong response');
  }

  @IsTest
  private static void testPersonAccountNotFoundException() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('TEST-PERSON-001', 'NOT-CREATED-PERSON'));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(500, res.statusCode, 'Status Code should be 500');
    System.assert(response.startsWith('Error: account record not found for the provided personId.'), 'Wrong response');
  }

  @IsTest
  private static void testCompanyAccountNotFoundException() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('TEST-COMPANY-001', 'NOT-CREATED-COMPANY'));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    String response = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(500, res.statusCode, 'Status Code should be 500');
    System.assert(response.startsWith('Error: account record not found for the provided companyId.'), 'Wrong response');
  }

  private static String getJsonPayload() {
    return '{' +
      '  "version": 1,' +
      '  "createdAt": "2022-02-22T09:31:08.615466",' +
      '  "updatedAt": "2022-02-22T09:31:08.615466",' +
      '  "employeeCode": "5856",' +
      '  "companyId": "TEST-COMPANY-001",' +
      '  "employeeType": "STANDARD_CONTRACT",' +
      '  "personId": "TEST-PERSON-001",' +
      '  "personVersion": "1",' +
      '  "id": "TEST-EMPLOYEE-001",' +
      '  "mainDocument": {' +
      '    "code": "45106105803",' +
      '    "type": "CPF"' +
      '  },' +
      '  "tenant": "creditasbr",' +
      '  "status": "ACTIVE",' +
      '  "admissionDate": "2022-02-22",' +
      '  "margin": {' +
      '    "amount": 5555.99,' +
      '    "currency": "BRL"' +
      '  },' +
      '  "salary": {' +
      '    "amount": 3333.33,' +
      '    "currency": "BRL"' +
      '  }' +
      '}';
  }
}