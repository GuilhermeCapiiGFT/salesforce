@isTest
public class DocumentApiControllerTest {
  @IsTest
  static void testGetDocumentsSuccess() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments(
      'SUCCESS',
      'AUTO_FIN'
    );
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items size should be 4');
  }

  @IsTest
  static void testGetDocumentsBadRequest() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments(
      'BAD_REQUEST',
      'AUTO_FIN'
    );
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Bad request');
  }

  @IsTest
  static void testGetDocumentsServerError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments(
      'SERVER_ERROR',
      'AUTO_FIN'
    );
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Server error');
  }

  @IsTest
  static void testGetDocumentsUnexpectedError() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments(
      'UNEXPECTED_ERROR',
      'AUTO_FIN'
    );
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testEmptyParams() {
    Test.setMock(HttpCalloutMock.class, new DocumentApiCalloutMock());

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('', '');
    Test.stopTest();

    assertResponseObjectError(responseObject, 'Unexpected error');
  }

  @IsTest
  static void testException() {
    Exception testException;
    DocumentApiController.isExceptionTest = true;

    Test.startTest();
    try {
      DocumentApiResponseVO responseObject = DocumentApiController.getDocuments('', '');
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assertNotEquals(null, testException, 'An exception should\'ve been thrown');
    System.assertEquals(
      'Test exception thrown',
      testException.getMessage(),
      'Expected exception message to be \'Test exception thrown\''
    );
    System.assertEquals(
      'System.AuraHandledException',
      testException.getTypeName(),
      'Expected exception type to be \'System.AuraHandledException\''
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