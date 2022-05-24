@isTest
public class AccountIntegrationMock {
  public static String getProfessionalIncomeExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getPayloadMock());
    AccountIntegrationRequestVO.ProfessionalIncome income = request.professionalInfo[0]
      .professionalIncome[0];
    request.professionalInfo[0].professionalIncome.add(income);
    return System.JSON.serialize(request);
  }

  public static String getMainDocumentNullExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getPayloadMock());
    request.mainDocument = null;
    return System.JSON.serialize(request);
  }

  public static String getIncomeCurrencyCodeExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getPayloadMock());
    request.income[0].amount.currencyCode = '';
    return System.JSON.serialize(request);
  }

  public static String getProfessionalIncomeCurrencyCodeExceptionMock() {
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(getPayloadMock());
    request.professionalInfo[0].professionalIncome[0].amount.currencyCode = '';
    return System.JSON.serialize(request);
  }

  public static String getDeleteContactMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.contacts.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteAddressMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.addresses.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteRelationshipMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.relationships.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteDocumentMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.documents.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteFiliationMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.filiation.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteProfessionalInfoMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.professionalInfo.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getDeleteIncomeMock() {
    String json = getUpdateMock();
    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.income.remove(0);
    return System.JSON.serialize(request);
  }

  public static String getChangedDataMock() {
    String json = getUpdateMock();

    AccountIntegrationRequestVO request = AccountIntegrationRequestVO.parse(json);
    request.additionalProperties.bankName = 'Itaú';
    request.contacts[0].code = '11999998883';
    request.addresses[0].complement = 'apto 33';
    request.documents[1].code = '12345';
    request.filiation[0].name = 'Lily Aldrin Ericksen';

    return System.JSON.serialize(request);
  }

  public static String getUpdateMock() {
    String json = getPayloadMock()
      .replace('test-001', 'test-002')
      .replace('50450177050', '04210259055');
    return json;
  }

  public static String getInvalidFieldDataExceptionMock() {
    String json = getPayloadMock().replace('"birthDate":"1996-05-13"', '"birthDate":"13"');
    return json;
  }

  public static String getUniqueValueExceptionMock() {
    String json = getPayloadMock().replace('50450177050', '04210259055');
    return json;
  }

  public static String getPayloadMock() {
    return '{\"id\":\"test-001-account-001\",\"mainDocument\":{\"type\":\"CPF\",\"code\":\"50450177050\"},\"fullName\":\"test-001-account-001\",\"additionalProperties\":{\"firstName\":\"Melanie\",\"secondName\":\"Martin\",\"lastName\":\"Virginia\",\"secondLastName\":\"Esteban\",\"curp\":\"EEVM960513MMCSIL01\",\"ineNumber\":\"1234567891234\",\"bankName\":\"BBVA\",\"accountNumber\":\"123445566\",\"clabe\":\"123445566\",\"politicallyExposed\":false},\"wealth\":{\"networthLowerLimit\":\"30000\",\"networthUpperLimit\":\"100000\",\"currencyCode\":\"BRL\",\"informedDate\":\"2021-08-16T14:09:42.189Z\"},\"gender\":\"FEMALE\",\"birthDate\":\"1996-05-13\",\"civilStatus\":\"MARRIED\",\"cityOfBirth\":\"Mexico\",\"countryOfBirth\":\"MX\",\"nationality\":\"MX\",\"contacts\":[{\"id\":\"test-001-contact-001\",\"channel\":\"PHONE\",\"code\":\"1155557771\",\"type\":\"PERSONAL\"},{\"id\":\"test-001-contact-002\",\"channel\":\"WHATSAPP\",\"code\":\"11999998883\",\"type\":\"COMERCIAL\"},{\"id\":\"test-001-contact-003\",\"channel\":\"EMAIL\",\"code\":\"email@email2.com\",\"type\":\"PERSONAL\"}],\"addresses\":[{\"id\":\"test-001-address-001\",\"type\":\"BILLING\",\"country\":\"BR\",\"neighborhood\":\"Centro\",\"street\":\"Avenida Marechal Deodoro\",\"streetNumber\":\"84\",\"complement\":\"\",\"zipCode\":\"68685970\"},{\"id\":\"test-001-address-002\",\"type\":\"HOME\",\"country\":\"BR\",\"neighborhood\":\"Centro\",\"street\":\"Rua Lauro de Freitas\",\"streetNumber\":\"40\",\"complement\":\"apto 23\",\"zipCode\":\"48005015\"}],\"documents\":[{\"id\":\"test-001-document-001\",\"type\":\"cpf\",\"code\":\"50450177050\",\"issueDate\":\"2020-01-01\"},{\"id\":\"test-001-document-002\",\"type\":\"rg\",\"code\":\"1234\",\"issueDate\":\"2020-01-01\"}],\"education\":{\"degree\":\"COLLEGE_DEGREE_COMPLETED\"},\"filiation\":[{\"type\":\"MOTHER\",\"name\":\"Lily Aldrin\"},{\"type\":\"FATHER\",\"name\":\"Marshall Ericksen\"}],\"income\":[{\"id\":\"test-001-income-001\",\"type\":\"MONTHLY_INCOME\",\"source\":\"SALES\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"createdAt\":\"2021-08-16T21:06:49Z\",\"updatedAt\":\"2021-08-16T21:06:49Z\"},{\"id\":\"test-001-income-002\",\"type\":\"PRESUMED_MONTHLY_INCOME\",\"source\":\"RENTS\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"createdAt\":\"2021-08-16T21:06:49Z\",\"updatedAt\":\"2021-08-16T21:06:49Z\"}],\"professionalInfo\":[{\"id\":\"test-001-info-001\",\"startDate\":{\"year\":2019,\"month\":10},\"jobTitle\":\"Seller\",\"companyName\":\"La Vivenda\",\"economicActivity\":\"AGRICULTURE\",\"status\":\"SELF_EMPLOYED\",\"category\":\"ADMINISTRATIVE\",\"current\":true,\"professionalIncome\":[{\"type\":\"MONTHLY_INCOME\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"source\":\"SALES\"}]},{\"id\":\"test-001-info-002\",\"startDate\":{\"year\":2020,\"month\":10},\"jobTitle\":\"Seller\",\"companyName\":\"La Vivenda\",\"economicActivity\":\"AGRICULTURE\",\"status\":\"SELF_EMPLOYED\",\"category\":\"MERCHANT\",\"current\":true,\"professionalIncome\":[{\"type\":\"MONTHLY_INCOME\",\"amount\":{\"currencyCode\":\"BRL\",\"amount\":\"10000\"},\"source\":\"SALES\"}]}],\"relationships\":[{\"id\":\"test-001-relationship-001\",\"type\":\"SPOUSE\",\"personId\":\"test-001-account-002\"},{\"id\":\"test-001-relationship-002\",\"type\":\"OFFSPRING\",\"personId\":\"test-001-account-003\"}],\"createdAt\":\"2021-08-16T14:09:42.206Z\",\"updatedAt\":\"2021-08-16T23:40:11.362Z\",\"version\":27}';
  }
}