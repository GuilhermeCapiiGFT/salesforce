@isTest
public class DocumentApiControllerTest {
  @IsTest
  static void testGetDocumentsSuccess() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('SUCCESS'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('test', 'AutoFin');
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items size should be 4');
  }

  @IsTest
  static void testGetDocumentsBadRequest() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('BAD_REQUEST'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('test', 'AutoFin');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Bad request');
  }

  @IsTest
  static void testGetDocumentsServerError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('SERVER_ERROR'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('test', 'AutoFin');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Server error');
  }

  @IsTest
  static void testGetDocumentsEmptyParams() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('SERVER_ERROR'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('', '');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Server error');
  }

  @IsTest
  static void testGetDocumentsUnexpectedError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('UNEXPECTED_ERROR'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('test', 'AutoFin');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testGetDocumentsInvalidJson() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock('INVALID_JSON'));

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('test', 'AutoFin');
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(true, responseObject.hasError, 'responseObject.hasError should be true');
    System.assertEquals(
      true,
      responseObject.errorMessage.startsWith('Unexpected character'),
      'result.errorMessage should start with \'Unexpected character\''
    );
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