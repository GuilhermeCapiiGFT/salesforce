@IsTest
public class AccountIntegrationControllerTest {
  @IsTest
  private static void testUpsertSuccess() {
    String json = AccountIntegrationMock.getPayloadMock();

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/IntegrationAccountIN';
    req.httpMethod = 'PUT';
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response = res;

    AccountIntegrationController.putMethod();
    Test.stopTest();

    RestResponse response = RestContext.response;
    AccountIntegrationResponseVO responseVO = (AccountIntegrationResponseVO) System.JSON.deserialize(
      response.responseBody.toString(),
      AccountIntegrationResponseVO.class
    );

    System.assertEquals(200, response.statusCode, 'Status code is incorrect');
    System.assertNotEquals(null, response.responseBody, 'Response body shouldn\'t be null');
    System.assertEquals(
      response.statusCode,
      responseVO.status,
      'Response body status is incorrect'
    );
    System.assertNotEquals(
      null,
      responseVO.accountId,
      'Response body accountId shouldn\'t be null'
    );
    System.assertEquals(
      'Account upserted.',
      responseVO.message,
      'Response body message is incorrect'
    );
  }

  @IsTest
  private static void testUpsertFailure() {
    String json = AccountIntegrationMock.getProfessionalIncomeExceptionMock();

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/IntegrationAccountIN';
    req.httpMethod = 'PUT';
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response = res;

    AccountIntegrationController.putMethod();
    Test.stopTest();

    RestResponse response = RestContext.response;
    AccountIntegrationResponseVO responseVO = (AccountIntegrationResponseVO) System.JSON.deserialize(
      response.responseBody.toString(),
      AccountIntegrationResponseVO.class
    );

    System.assertEquals(500, response.statusCode, 'Status code is incorrect');
    System.assertNotEquals(null, response.responseBody, 'Response body shouldn\'t be null');
    System.assertEquals(
      response.statusCode,
      responseVO.status,
      'Response body status is incorrect'
    );
    System.assertEquals(null, responseVO.accountId, 'Response body accountId should be null');
    System.assertEquals(
      'Each Professional Info must have only one professional income.',
      responseVO.message,
      'Response body message is incorrect'
    );
  }
}