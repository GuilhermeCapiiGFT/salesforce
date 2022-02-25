@isTest
private with sharing class AccountEmployeeIntegrationTest {
  private static final String ENDPOINT = '/services/apexrest/Account/Employee/upsertEmployee';

  @isTest
  private static void testCreateEmployee() {
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

    String accountPersonRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
    String accountCompanyRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');

    List<Employee__c> employees = getEmployees();

    System.assertEquals(false, employees.isEmpty(), 'No Employee__c record was created');
    System.assertEquals(1, employees.size(), 'Only 1 Employee__c record should have been created');

    Employee__c employee = employees.get(0);

    System.assertNotEquals(null, employee, 'Employee__c record shouldn\'t be null');
    System.assertEquals(200, res.statusCode, 'Status Code should be 200');
    System.assertEquals('Record created/updated successfully.', response, 'Wrong response');
    System.assertEquals('TEST-EMPLOYEE-001', employee.ExternalId__c, 'Wrong employee External Id');
    System.assertEquals(Date.newInstance(2022, 2, 22), employee.AdmissionDate__c, 'Wrong employee Admission Date');
    System.assertEquals(5555.99, employee.Margin__c, 'Wrong employee Margin');
    System.assertEquals(3333.33, employee.Salary__c, 'Wrong employee Salary');
    System.assertEquals(
      accountPersonRecordTypeId,
      employee.PersonAccount__r.RecordTypeId,
      'Wrong person account Record Type Id'
    );
    System.assertEquals('TEST-PERSON-001', employee.PersonAccount__r.ExternalId__c, 'Wrong person account External Id');
    System.assertEquals(
      accountCompanyRecordTypeId,
      employee.Company__r.RecordTypeId,
      'Wrong company account Record Type Id'
    );
    System.assertEquals('TEST-COMPANY-001', employee.Company__r.ExternalId__c, 'Wrong company account External Id');
  }

  @isTest
  private static void testUpdateEmployee() {
    String accountPersonRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
    String accountCompanyRecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');

    insert new List<Account>{
      new Account(Name = 'João da Silva', ExternalId__c = 'TEST-PERSON-001', RecordTypeId = accountPersonRecordTypeId),
      new Account(Name = 'Creditas', ExternalId__c = 'TEST-COMPANY-001', RecordTypeId = accountCompanyRecordTypeId)
    };

    insert new Employee__c(
      Name = 'João da Silva - Creditas',
      ExternalId__c = 'TEST-EMPLOYEE-001',
      PersonAccount__r = new Account(ExternalId__c = 'TEST-PERSON-001'),
      Company__r = new Account(ExternalId__c = 'TEST-COMPANY-001')
    );

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

    List<Employee__c> employees = getEmployees();

    System.assertEquals(false, employees.isEmpty(), 'No Employee__c record was created');
    System.assertEquals(1, employees.size(), 'Only 1 Employee__c record should have been created');

    Employee__c employee = employees.get(0);

    System.assertNotEquals(null, employee, 'Employee__c record shouldn\'t be null');
    System.assertEquals(200, res.statusCode, 'Status Code should be 200');
    System.assertEquals('Record created/updated successfully.', response, 'Wrong response');
    System.assertEquals('João da Silva - Creditas', employee.Name, 'Wrong employee Name');
    System.assertEquals('TEST-EMPLOYEE-001', employee.ExternalId__c, 'Wrong employee External Id');
    System.assertEquals(Date.newInstance(2022, 2, 22), employee.AdmissionDate__c, 'Wrong employee Admission Date');
    System.assertEquals(5555.99, employee.Margin__c, 'Wrong employee Margin');
    System.assertEquals(3333.33, employee.Salary__c, 'Wrong employee Salary');
    System.assertEquals('João da Silva', employee.PersonAccount__r.Name, 'Wrong person account Name');
    System.assertEquals(
      accountPersonRecordTypeId,
      employee.PersonAccount__r.RecordTypeId,
      'Wrong person account Record Type Id'
    );
    System.assertEquals('TEST-PERSON-001', employee.PersonAccount__r.ExternalId__c, 'Wrong person account External Id');
    System.assertEquals('Creditas', employee.Company__r.Name, 'Wrong company account Name');
    System.assertEquals(
      accountCompanyRecordTypeId,
      employee.Company__r.RecordTypeId,
      'Wrong company account Record Type Id'
    );
    System.assertEquals('TEST-COMPANY-001', employee.Company__r.ExternalId__c, 'Wrong company account External Id');
  }

  @isTest
  private static void testExceptions() {
    String json = getJsonPayload();

    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';

    // test invalid json
    req.requestBody = Blob.valueof(json.replace('"version": 1,', '"version": ,'));
    RestContext.request = req;
    RestContext.response = res;
    String jsonParseError = AccountEmployeeIntegrationController.upsertEmployee();

    // test required fields
    req.requestBody = Blob.valueof(json.replace('"TEST-EMPLOYEE-001"', '" "'));
    RestContext.request = req;
    RestContext.response = res;
    String requiredFieldsError = AccountEmployeeIntegrationController.upsertEmployee();

    // test invalid dateTime
    req.requestBody = Blob.valueof(json.replace('"2022-02-22T09:31:08.615466"', '"-"'));
    RestContext.request = req;
    RestContext.response = res;
    String dateTimeError = AccountEmployeeIntegrationController.upsertEmployee();

    // test invalid date
    req.requestBody = Blob.valueof(json.replace('"2022-02-22"', '"-"'));
    RestContext.request = req;
    RestContext.response = res;
    String dateError = AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    System.assertEquals(400, res.statusCode, 'Status Code should be 400');

    List<Employee__c> employees = getEmployees();

    System.assert(employees.isEmpty(), 'No Employee__c record should exist');
    System.assert(jsonParseError.startsWith('Error: JSON parse failed'), 'Wrong response');
    System.assert(requiredFieldsError.startsWith('Error: required field(s) missing'), 'Wrong response');
    System.assert(dateTimeError.startsWith('Error: couldn\'t parse dateTime string'), 'Wrong response');
    System.assert(dateError.startsWith('Error: couldn\'t parse date string'), 'Wrong response');
  }

  private static List<Employee__c> getEmployees() {
    return [
      SELECT
        Name,
        AdmissionDate__c,
        Margin__c,
        Salary__c,
        ExternalId__c,
        PersonAccount__r.Name,
        PersonAccount__r.RecordTypeId,
        PersonAccount__r.ExternalId__c,
        Company__r.Name,
        Company__r.RecordTypeId,
        Company__r.ExternalId__c
      FROM Employee__c
    ];
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