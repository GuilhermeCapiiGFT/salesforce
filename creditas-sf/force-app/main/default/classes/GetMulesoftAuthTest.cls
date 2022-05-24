@isTest
private with sharing class GetMulesoftAuthTest {
    @IsTest
    private static void testSuccessResponse(){
        
        String mockSuccess = '{"access_token":"tOxqtBAtTEMUdeCNOlZdsUnvjO8gGmMFq01AFQeOLAtlOWglcI3lR6aXpKNvYH8i2hXgbKjqDZ6sJs8SmpQZ9g","token_type":"Bearer","expires_in":86400}';
        HttpMockFactory mock = generateMockResponse(new List<Integer>{200},new List<String>{mockSuccess});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HTTPResponse httpResp = GetMulesoftAuthController.getAuth();
        Test.stopTest();
        System.assertEquals(200, httpResp.getStatusCode(), 'Wrong status code');
        
    }

    @IsTest
    private static void testFailedAuth() {
    
    String mockFail = '{"error_description":"Invalid credentials","error":"invalid_client"}';
    HttpMockFactory mock = generateMockResponse(new List<Integer>{400}, new List<String>{mockFail});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    HTTPResponse httpResp = GetMulesoftAuthController.getAuth();
    Test.stopTest();
    System.assertEquals(400, httpResp.getStatusCode(), 'Wrong status code');
  }

  private static HttpMockFactory generateMockResponse(List<Integer> statusCode,List<String> mockResponse){
    HttpMockFactory mock = new HttpMockFactory(
                                          statusCode,
                                          new List<String>{'OK','OK'},
                                          mockResponse,
                                          new List<Map<String,String>>{new Map<String,String>(),new Map<String,String>()});
    return mock;
  }
}