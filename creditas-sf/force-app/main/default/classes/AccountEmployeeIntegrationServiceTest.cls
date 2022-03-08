@istest
private class AccountEmployeeIntegrationServiceTest {
  private static final String ENDPOINT = '/services/apexrest/Account/Employee/upsertEmployee';

  @IsTest
  private static void testInsertEmployeeSuccess() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    List<Employee__c> employees = getEmployees();
    Map<Id, Account> accountsById = new Map<Id, Account>(getAccounts());

    System.assertEquals(1, employees.size(), '1 employee record should have been created');
    System.assertEquals(2, accountsById.size(), '2 account records should have been created');
    System.assert(accountsById.containsKey(employees.get(0).PersonAccount__c), 'Person account not created');
    System.assert(accountsById.containsKey(employees.get(0).Company__c), 'Company account not created');
  }

  @IsTest
  private static void testInsertEmployeeFail() {
    String json = getJsonPayload();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('"2022-02-22"', '"-"'));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    List<Employee__c> employees = getEmployees();
    List<Account> accounts = getAccounts();

    System.assertEquals(0, employees.size(), 'No employee record should\'ve been created');
    System.assertEquals(0, accounts.size(), 'No account record should\'ve been created');
  }

  @IsTest
  private static void testUpdateEmployeeSuccess() {
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

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    Employee__c employee = getEmployees().get(0);

    System.assertEquals('João da Silva - Creditas', employee.Name, 'Wrong employee Name');
    System.assertEquals(Date.newInstance(2022, 2, 22), employee.AdmissionDate__c, 'Wrong employee Admission Date');
    System.assertEquals(5555.99, employee.Margin__c, 'Wrong employee Margin');
    System.assertEquals(3333.33, employee.Salary__c, 'Wrong employee Salary');
    System.assertEquals('João da Silva', employee.PersonAccount__r.Name, 'Wrong person account Name');
    System.assertEquals('Creditas', employee.Company__r.Name, 'Wrong company account Name');
  }

  @IsTest
  private static void testUpdateEmployeeFail() {
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

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = ENDPOINT;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(json.replace('"2022-02-22"', '"-"'));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AccountEmployeeIntegrationController.upsertEmployee();

    Test.stopTest();

    Employee__c employee = getEmployees().get(0);

    System.assertNotEquals(
      Date.newInstance(2022, 2, 22),
      employee.AdmissionDate__c,
      'Employee Admission Date shouldn\'t have been updated'
    );
    System.assertNotEquals(5555.99, employee.Margin__c, 'Employee Margin shouldn\'t have been updated');
    System.assertNotEquals(3333.33, employee.Salary__c, 'Employee Salary shouldn\'t have been updated');
  }

  private static List<Employee__c> getEmployees() {
    return [
      SELECT
        Name,
        AdmissionDate__c,
        Margin__c,
        Salary__c,
        ExternalId__c,
        PersonAccount__c,
        PersonAccount__r.Name,
        Company__c,
        Company__r.Name
      FROM Employee__c
    ];
  }

  private static List<Account> getAccounts() {
    return [SELECT Id FROM Account];
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