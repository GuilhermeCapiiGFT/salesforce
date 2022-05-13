@IsTest
public class AccountIntegrationServiceTest {
  @IsTest
  static void testInsertSuccess() {
    String json = getNewAccountMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBodyBlob = integration.getResponseBodyAsBlob();
    AccountIntegrationResponseVO responseBodyObject = parseBlob(responseBodyBlob);

    System.assertNotEquals(null, responseBodyBlob, 'Response body (Blob) shouldn\'t be null');
    System.assertNotEquals(
      null,
      responseBodyObject.accountId,
      'Response body field \'accountId\' shouldn\'t be null'
    );
    System.assertEquals(
      200,
      responseBodyObject.status,
      'Response body field \'status\' should be 200'
    );
    System.assertEquals(
      'Account upserted.',
      responseBodyObject.message,
      'Response body field \'message\' should be \'Account upserted\''
    );
  }

  @IsTest
  static void testInvalidJson() {
    String json = '(this is not json)';

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBodyBlob = integration.getResponseBodyAsBlob();
    AccountIntegrationResponseVO responseBodyObject = parseBlob(responseBodyBlob);

    System.assertNotEquals(null, responseBodyBlob, 'Response body (Blob) shouldn\'t be null');
    assertErrorResponse(responseBodyObject, 500, 'Invalid JSON format.');
  }

  @IsTest
  static void testUnexpectedException() {
    String json = getNewAccountMock();

    Test.startTest();
    AccountIntegrationService.isExceptionTest = true;
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBodyBlob = integration.getResponseBodyAsBlob();
    AccountIntegrationResponseVO responseBodyObject = parseBlob(responseBodyBlob);

    System.assertNotEquals(null, responseBodyBlob, 'Response body (Blob) shouldn\'t be null');
    assertErrorResponse(
      responseBodyObject,
      500,
      'An unexpected error has occurred. Please, contact a Salesforce administrator.'
    );
  }

  @IsTest
  static void testProfessionalIncomeException() {
    String json = getProfessionalIncomeExceptionMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBodyBlob = integration.getResponseBodyAsBlob();
    AccountIntegrationResponseVO responseBodyObject = parseBlob(responseBodyBlob);

    System.assertNotEquals(null, responseBodyBlob, 'Response body (Blob) shouldn\'t be null');
    assertErrorResponse(
      responseBodyObject,
      500,
      'Each Professional Info must have only one professional income.'
    );
  }

  @IsTest
  static void testMainDocumentNullException() {
    String json = getMainDocumentNullExceptionMock();

    Test.startTest();
    AccountIntegrationService integration = runUpsert(json);
    Test.stopTest();

    Blob responseBodyBlob = integration.getResponseBodyAsBlob();
    AccountIntegrationResponseVO responseBodyObject = parseBlob(responseBodyBlob);

    System.assertNotEquals(null, responseBodyBlob, 'Response body (Blob) shouldn\'t be null');
    assertErrorResponse(responseBodyObject, 500, 'Main Document can\'t be null.');
  }

  static AccountIntegrationService runUpsert(String json) {
    AccountIntegrationService integration = new AccountIntegrationService();
    integration.setRequestBody(json);
    integration.upsertData();
    return integration;
  }

  static void assertErrorResponse(
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
      message,
      response.message,
      'Response body field \'message\' should be \'' +
      message +
      '\''
    );
  }

  static AccountIntegrationResponseVO parseBlob(Blob responseBodyBlob) {
    AccountIntegrationResponseVO responseBodyObject = (AccountIntegrationResponseVO) System.JSON.deserialize(
      responseBodyBlob.toString(),
      AccountIntegrationResponseVO.class
    );

    return responseBodyObject;
  }

  static String getProfessionalIncomeExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getNewAccountMock());
    AccountIntegrationRequestVO.ProfessionalIncome income = request.professionalInfo[0]
      .professionalIncome[0];
    request.professionalInfo[0].professionalIncome.add(income);
    return JSON.serialize(request);
  }

  static String getMainDocumentNullExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getNewAccountMock());
    request.mainDocument = null;
    return JSON.serialize(request);
  }

  static String getNewAccountMock() {
    return '{\"id\":\"person-001\",\"mainDocument\":{\"type\":\"CPF\",\"code\":\"50450177050\"},\"fullName\":\"testaccount\",\"additionalProperties\":{\"firstName\":\"Melanie\",\"secondName\":\"Martin\",\"lastName\":\"Virginia\",\"secondLastName\":\"Esteban\",\"curp\":\"EEVM960513MMCSIL01\",\"ineNumber\":\"1234567891234\",\"bankName\":\"BBVA\",\"accountNumber\":\"123445566\",\"clabe\":\"123445566\",\"politicallyExposed\":false},\"wealth\":{\"networthLowerLimit\":\"30000\",\"networthUpperLimit\":\"100000\",\"currencyCode\":\"BRL\",\"informedDate\":\"2021-08-16T14:09:42.189Z\"},\"gender\":\"FEMALE\",\"birthDate\":\"1996-05-13\",\"civilStatus\":\"MARRIED\",\"cityOfBirth\":\"Mexico\",\"countryOfBirth\":\"MX\",\"nationality\":\"MX\",\"contacts\":[{\"id\":\"contacts-001\",\"channel\":\"PHONE\",\"code\":\"1155557771\",\"type\":\"PERSONAL\"},{\"id\":\"contacts-002\",\"channel\":\"WHATSAPP\",\"code\":\"11999998883\",\"type\":\"COMERCIAL\"},{\"id\":\"contacts-003\",\"channel\":\"EMAIL\",\"code\":\"email@email2.com\",\"type\":\"PERSONAL\"}],\"addresses\":[{\"id\":\"addresses-001\",\"type\":\"BILLING\",\"country\":\"MX\",\"neighborhood\":\"ARBOLEDASDELSUR\",\"street\":\"CERRADABETIS\",\"streetNumber\":\"30\",\"complement\":\"14388\",\"zipCode\":\"14376\"},{\"id\":\"addresses-002\",\"type\":\"HOME\",\"country\":\"MX\",\"neighborhood\":\"ARBOLEDASDELSUR\",\"street\":\"CERRADABETIS\",\"streetNumber\":\"40\",\"complement\":\"14388\",\"zipCode\":\"14376\"}],\"documents\":[{\"id\":\"documents-001\",\"type\":\"cpf\",\"code\":\"HEVP260702QA3\",\"issueDate\":\"2023-01-01\"}],\"education\":{\"degree\":\"COLLEGE_DEGREE_COMPLETED\"},\"filiation\":[{\"type\":\"MOTHER\",\"name\":\"LilyAldrin\"},{\"type\":\"FATHER\",\"name\":\"MarshallEricksen\"}],\"income\":[{\"id\":\"income-001\",\"type\":\"MONTHLY_INCOME\",\"source\":\"SALES\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"createdAt\":\"2021-08-16T21:06:49Z\",\"updatedAt\":\"2021-08-16T21:06:49Z\"},{\"id\":\"income-002\",\"type\":\"PRESUMED_MONTHLY_INCOME\",\"source\":\"RENTS\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"createdAt\":\"2021-08-16T21:06:49Z\",\"updatedAt\":\"2021-08-16T21:06:49Z\"}],\"professionalInfo\":[{\"id\":\"professionalInfo-001\",\"startDate\":{\"year\":2019,\"month\":10},\"jobTitle\":\"Seller\",\"companyName\":\"LaVivenda\",\"economicActivity\":\"AGRICULTURE\",\"status\":\"SELF_EMPLOYED\",\"category\":\"ADMINISTRATIVE\",\"current\":true,\"professionalIncome\":[{\"type\":\"MONTHLY_INCOME\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"source\":\"SALES\"}]},{\"id\":\"professionalInfo-002\",\"startDate\":{\"year\":2019,\"month\":10},\"jobTitle\":\"Seller\",\"companyName\":\"LaVivenda\",\"economicActivity\":\"AGRICULTURE\",\"status\":\"SELF_EMPLOYED\",\"category\":\"MERCHANT\",\"current\":true,\"professionalIncome\":[{\"type\":\"MONTHLY_INCOME\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"8000\"},\"source\":\"SALES\"}]}],\"relationships\":[{\"id\":\"relationship-001\",\"type\":\"SPOUSE\",\"personId\":\"person-002\"},{\"id\":\"relationship-002\",\"type\":\"OFFSPRING\",\"personId\":\"person-003\"}],\"createdAt\":\"2021-08-16T14:09:42.206Z\",\"updatedAt\":\"2021-08-16T23:40:11.362Z\",\"version\":27}';
  }
}