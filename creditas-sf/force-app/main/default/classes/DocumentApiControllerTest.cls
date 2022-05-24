@isTest
private class DocumentApiControllerTest {
  private static String authMockSuccess = '{"access_token":"tOxqtBAtTEMUdeCNOlZdsUnvjO8gGmMFq01AFQeOLAtlOWglcI3lR6aXpKNvYH8i2hXgbKjqDZ6sJs8SmpQZ9g","token_type":"Bearer","expires_in":86400}';
  private static String getSuccessResponse = '{\"items\":[{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"ZéJãodasilva\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://i0.wp.com/trucao.com.br/wp-content/uploads/2017/12/cnh_cartao_destaque.jpg?fit=1920%2C1080&ssl=1\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-02T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2021-01-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-08-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"}],\"cursors\":{\"self\":\"/?productName=AUTO_FIN&externalIds=LAP-FE39B452-337B-4BC9-95FD-619AD8C5BD38&getUrl=true&page=0&size=20\"}}';
  private static String getBadRequestResponse = '{\"code\":400,\"message\":\"BadRequest\",\"description\":[\"RequiredqueryparameterproductTypenotspecified\"],\"datetime\":\"2022-05-05T17:08:02\",\"transactionId\":\"ec19f400-cc95-11ec-8cf6-129098f9b76b\"}';
  private static String getServerErrorResponse ='{\"error\":{\"parentErrorType\":{\"parentErrorType\":null,\"identifier\":\"ANY\",\"namespace\":\"MULE\"},\"identifier\":\"NOT_FOUND\",\"namespace\":\"HTTP\"},\"message\":\"HTTPGETonresource\'http://loan-app-sync-develop.us-e1.cloudhub.io:80/api/loan-applications/documents\'failed:notfound(404).\"}';

  @isTest
  private static void testGetDocumentsSuccess() {

    HttpMockFactory mock = generateMockResponse(new List<Integer>{200,200}, new List<String>{authMockSuccess, getSuccessResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('SUCCESS', 'AUTO_FIN');
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items size should be 4');
  }

  @IsTest
  static void testGetDocumentsBadRequest() {

    HttpMockFactory mock = generateMockResponse(new List<Integer>{200,400}, new List<String>{authMockSuccess, getBadRequestResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('BAD_REQUEST', 'AUTO_FIN');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Bad request');
  }

  @IsTest
  static void testGetDocumentsServerError() {

    HttpMockFactory mock = generateMockResponse(new List<Integer>{200,500}, new List<String>{authMockSuccess, getServerErrorResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('SERVER_ERROR', 'AUTO_FIN');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Server error');
  }

  @IsTest
  static void testGetDocumentsUnexpectedError() {

    String mockResponse = '{ "error": "unexpected" }';
    HttpMockFactory mock = generateMockResponse(new List<Integer>{200,404}, new List<String>{authMockSuccess, mockResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('UNEXPECTED_ERROR', 'AUTO_FIN');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testEmptyParams() {
    
    String mockResponse = '';
    HttpMockFactory mock = generateMockResponse(new List<Integer>{200,404}, new List<String>{authMockSuccess, mockResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('', '');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testFailedAuth() {
    
    String mockResponse = '{"error_description":"Invalid credentials","error":"invalid_client"}';
    HttpMockFactory mock = generateMockResponse(new List<Integer>{400}, new List<String>{mockResponse});
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('', '');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Bad request');
  }

  @IsTest
  static void testException() {
    Exception testException;
    Test.startTest();
    try {
      DocumentApiResponseVO responseObject = DocumentApiController.getDocuments(null, null);
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assertNotEquals(null, testException, 'An exception should\'ve been thrown');
    String message = 'Methods defined as TestMethod do not support Web service callouts';
    System.assertEquals(message, testException.getMessage(), 'Expected exception message:' + message );
    System.assertEquals('System.AuraHandledException', testException.getTypeName(), 'Expected exception type to be \'System.AuraHandledException\'' );
  }

  static void assertResponseObjectError(DocumentApiResponseVO responseObject, String errorMessage) {
    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(true, responseObject.hasError, 'responseObject.hasError should be true');
    System.assertEquals(
      errorMessage,
      responseObject.errorMessage,
      'result.errorMessage should be \'' +
      errorMessage +
      '\''
    );
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