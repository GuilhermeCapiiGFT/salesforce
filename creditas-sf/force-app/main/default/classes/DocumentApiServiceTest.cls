@isTest
public with sharing class DocumentApiServiceTest {
  @IsTest
  static void testSuccess() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiService documentApi = sendRequest('SUCCESS', 'AutoFin');
    Test.stopTest();

    HttpResponse response = documentApi.getResponse();
    DocumentApiResponseVO responseObject = documentApi.getResponseObject();

    assertResponse(response, 200);
    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items size should be 4');
  }

  @IsTest
  static void testBadRequest() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiService documentApi = sendRequest('BAD_REQUEST', 'AutoFin');
    Test.stopTest();

    HttpResponse response = documentApi.getResponse();
    DocumentApiResponseVO responseObject = documentApi.getResponseObject();

    assertResponse(response, 400);
    assertResponseObjectError(responseObject, 'Bad request');
  }

  @IsTest
  static void testServerError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiService documentApi = sendRequest('SERVER_ERROR', 'AutoFin');
    Test.stopTest();

    HttpResponse response = documentApi.getResponse();
    DocumentApiResponseVO responseObject = documentApi.getResponseObject();

    assertResponse(response, 500);
    assertResponseObjectError(responseObject, 'Server error');
  }

  @IsTest
  static void testUnexpectedError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiService documentApi = sendRequest('UNEXPECTED_ERROR', 'AutoFin');
    Test.stopTest();

    HttpResponse response = documentApi.getResponse();
    DocumentApiResponseVO responseObject = documentApi.getResponseObject();

    assertResponse(response, 404);
    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testEmptyParams() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiService documentApi = sendRequest('', '');
    Test.stopTest();

    HttpResponse response = documentApi.getResponse();
    DocumentApiResponseVO responseObject = documentApi.getResponseObject();

    assertResponse(response, 404);
    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  static DocumentApiService sendRequest(String mockConfig, String recordTypeName) {
    DocumentApiService documentApi = new DocumentApiService();
    documentApi.setLoanApplicationId(mockConfig);
    documentApi.setRecordTypeName(recordTypeName);
    documentApi.sendRequest();
    return documentApi;
  }

  static void assertResponse(HttpResponse response, Integer statusCode) {
    System.assertNotEquals(null, response, 'response shouldn\'t be null');
    System.assertEquals(statusCode, response.getStatusCode(), 'Unexpected response status code');
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
}