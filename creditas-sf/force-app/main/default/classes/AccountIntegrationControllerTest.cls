@IsTest
public class AccountIntegrationControllerTest {

    @IsTest
    static void testUpsertSuccess() {
      String json = AccountIntegrationMock.getPayloadMock();
  
      Test.startTest();
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();  

      req.requestURI = '/services/apexrest/IntegrationAccountIN/v2'; 
      req.httpMethod = 'PUT';
      req.requestBody = Blob.valueof(json);
      RestContext.request = req;
      RestContext.response = res;
 
      AccountIntegrationController.putMethod();       
      Test.stopTest();

      RestResponse response = RestContext.response;

      System.assertEquals(200, response.statusCode, 'Status code is incorrect');
      System.assertNotEquals(null, response.responseBody, 'Response body shouldn\'t be null');
    }
}