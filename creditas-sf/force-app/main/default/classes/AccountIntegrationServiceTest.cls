@IsTest
public class AccountIntegrationServiceTest {
  @TestSetup
  static void makeData() {
    List<Account> relationshipAccounts = new List<Account>{
      AccountSetup.createAccount('test-001-account-002', 'Pessoa_Fisica'),
      AccountSetup.createAccount('test-001-account-003', 'Pessoa_Fisica'),
      AccountSetup.createAccount('test-002-account-002', 'Pessoa_Fisica'),
      AccountSetup.createAccount('test-002-account-003', 'Pessoa_Fisica')
    };
    relationshipAccounts[0].ExternalId__c = 'test-001-account-002';
    relationshipAccounts[1].ExternalId__c = 'test-001-account-003';
    relationshipAccounts[2].ExternalId__c = 'test-002-account-002';
    relationshipAccounts[3].ExternalId__c = 'test-002-account-003';

    insert relationshipAccounts;

    String json = AccountIntegrationMock.getUpdateMock();
    runUpsert(json);
  }

  @IsTest
  static void testInsertSuccess() {
    String json = AccountIntegrationMock.getPayloadMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);
    List<Account> accounts = [SELECT Id FROM Account];

    assertResponseSuccess(statusCode, response);
    System.assertEquals(6, accounts.size(), 'Number of existing accounts is incorrect');
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(
      3,
      account.CommunicationContacts__r.size(),
      '3 contacts should\'ve been created'
    );
    System.assertEquals(2, account.Enderecos__r.size(), '2 addresses should\'ve been created');
    System.assertEquals(
      2,
      account.Contas_Relacionadas__r.size(),
      '2 relationships should\'ve been created'
    );
    System.assertEquals(2, account.Documentos__r.size(), '2 documents should\'ve been created');
    System.assertEquals(
      4,
      account.AccountFinancialRelationships__r.size(),
      '2 financial relationships should\'ve been created'
    );
    System.assertEquals(
      2,
      account.ProfessionalInfos__r.size(),
      '2 professional infos should\'ve been created'
    );
    System.assertEquals(2, account.Filiation__r.size(), '2 filiations should\'ve been created');
  }

  @IsTest
  static void testUpdateSuccess() {
    String json = AccountIntegrationMock.getChangedDataMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);
    List<Account> accounts = [SELECT Id FROM Account];

    assertResponseSuccess(statusCode, response);
    System.assertEquals(5, accounts.size(), 'Number of existing accounts is incorrect');
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals('Itaú', account.BankName__c, 'Bank name not updated');
    System.assertEquals(
      '11999998883',
      account.CommunicationContacts__r[0].Code__c,
      'Contact code not updated'
    );
    System.assertEquals(
      'apto 33',
      account.Enderecos__r[0].Complement__c,
      'Address complement not updated'
    );
    System.assertEquals(
      '12345',
      account.Documentos__r[1].DocumentNumber__c,
      'Document number not updated'
    );
    System.assertEquals(
      'Lily Aldrin Ericksen',
      account.Filiation__r[0].Name__c,
      'Filiation name not updated'
    );
  }

  @IsTest
  static void testDeleteContactSuccess() {
    String json = AccountIntegrationMock.getDeleteContactMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(
      2,
      account.CommunicationContacts__r.size(),
      'Number of communication contacts is incorrect'
    );
  }

  @IsTest
  static void testDeleteAddressSuccess() {
    String json = AccountIntegrationMock.getDeleteAddressMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(1, account.Enderecos__r.size(), 'Number of addresses is incorrect');
  }

  @IsTest
  static void testDeleteRelationshipSuccess() {
    String json = AccountIntegrationMock.getDeleteRelationshipMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(
      1,
      account.Contas_Relacionadas__r.size(),
      'Number of relationships is incorrect'
    );
  }

  @IsTest
  static void testDeleteDocumentSuccess() {
    String json = AccountIntegrationMock.getDeleteDocumentMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(1, account.Documentos__r.size(), 'Number of documents is incorrect');
  }

  @IsTest
  static void testDeleteProfessionalInfoSuccess() {
    String json = AccountIntegrationMock.getDeleteProfessionalInfoMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(
      1,
      account.ProfessionalInfos__r.size(),
      'Number of professional infos is incorrect'
    );
    System.assertEquals(
      3,
      account.AccountFinancialRelationships__r.size(),
      'Number of financial relationships infos is incorrect'
    );
  }

  @IsTest
  static void testDeleteIncomeSuccess() {
    String json = AccountIntegrationMock.getDeleteIncomeMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(
      3,
      account.AccountFinancialRelationships__r.size(),
      'Number of financial relationships is incorrect'
    );
  }

  @IsTest
  static void testDeleteFiliationSuccess() {
    String json = AccountIntegrationMock.getDeleteFiliationMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    Integer statusCode = integration.getStatusCode();
    AccountIntegrationResponseVO response = integration.getResponse();
    Account account = selectAccount(response.accountId);

    assertResponseSuccess(statusCode, response);
    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    System.assertEquals(1, account.Filiation__r.size(), 'Number of filiations is incorrect');
  }

  @IsTest
  static void testInvalidJson() {
    String json = '(this is not json)';

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    AccountIntegrationResponseVO response = integration.getResponse();

    System.assertNotEquals(null, response, 'Response body shouldn\'t be null');
    assertResponseError(response, 500, 'Invalid JSON format.');
  }

  @IsTest
  static void testProfessionalIncomeException() {
    String json = AccountIntegrationMock.getProfessionalIncomeExceptionMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    AccountIntegrationResponseVO response = integration.getResponse();

    System.assertNotEquals(null, response, 'Response body shouldn\'t be null');
    assertResponseError(
      response,
      500,
      'Each Professional Info must have only one professional income.'
    );
  }

  @IsTest
  static void testMainDocumentNullException() {
    String json = AccountIntegrationMock.getMainDocumentNullExceptionMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    AccountIntegrationResponseVO response = integration.getResponse();

    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    assertResponseError(response, 500, 'Main Document can\'t be null.');
  }

  @IsTest
  static void testInvalidCurrencyCodeException() {
    String json = AccountIntegrationMock.getInvalidCurrencyCodeExceptionMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBlob = integration.getResponseAsBlob();
    AccountIntegrationResponseVO response = integration.getResponse();

    System.assertNotEquals(null, responseBlob, 'Response body shouldn\'t be null');
    assertResponseError(response, 500, 'Invalid currency code');
  }

  static AccountIntegrationService runUpsert(String json) {
    AccountIntegrationService integration = new AccountIntegrationService();
    integration.setRequestBody(json);
    integration.upsertData();
    return integration;
  }

  static Account selectAccount(String accountId) {
    List<Account> accounts = [
      SELECT
        Id,
        BankName__c,
        (SELECT Id, Code__c FROM CommunicationContacts__r),
        (SELECT Id, Complement__c FROM Enderecos__r),
        (SELECT Id FROM Contas_Relacionadas__r),
        (SELECT Id, DocumentNumber__c FROM Documentos__r),
        (
          SELECT
            Id,
            Recurso_Financeiro__c,
            Recurso_Financeiro__r.ExternalId__c,
            Recurso_Financeiro__r.ProfessionalInfo__c
          FROM AccountFinancialRelationships__r
        ),
        (SELECT Id FROM ProfessionalInfos__r),
        (SELECT Id, Name__c FROM Filiation__r)
      FROM Account
      WHERE Id = :accountId
    ];

    return accounts.isEmpty() ? null : accounts[0];
  }

  static void assertResponseSuccess(Integer statusCode, AccountIntegrationResponseVO response){
    System.assertEquals(200, statusCode, 'Status code is incorrect');
    System.assertEquals(statusCode, response.status, 'Response status is incorrect');
    System.assertNotEquals(null, response.accountId, 'Response accountId is incorrect');
    System.assertEquals('Account upserted.', response.message, 'Response message is incorrect');
  }

  static void assertResponseError(
    AccountIntegrationResponseVO response,
    Integer status,
    String message
  ) {
    System.assertEquals(
      null,
      response.accountId,
      'Response body field \'accountId\' should be null'
    );
    System.assertEquals(
      status,
      response.status,
      'Response body field \'status\' should be \'' +
      status +
      '\''
    );
    System.assertEquals(
      true,
      response.message.startsWith(message),
      'Response body field \'message\' should start with \'' +
      message +
      '\''
    );
  }
}