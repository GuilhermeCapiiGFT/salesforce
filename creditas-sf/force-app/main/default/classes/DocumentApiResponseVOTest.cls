@isTest
public class DocumentApiResponseVOTest {
  @IsTest
  static void testExpectedJson() {
    String successJson = DocumentApiResponseVO.getSuccessResponse();

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(successJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items should be 4');
    System.assertEquals(
      '2021-01-01 15:20:35',
      responseObject.items[0].details.createdAt.formatGmt('yyyy-MM-dd HH:mm:ss'),
      'Incorrect order of items'
    );
    System.assertEquals(
      '2020-06-01 15:20:35',
      responseObject.items[3].details.createdAt.formatGmt('yyyy-MM-dd HH:mm:ss'),
      'Incorrect order of items'
    );
  }

  @IsTest
  static void testUnexpectedJson() {
    String successJson = '{ "message": "unexpected" }';

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(successJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(null, responseObject.items, 'responseObject.items should be null');
  }

  @IsTest
  static void testInvalidJson() {
    String invalidJson = '{ "key": ,}';

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(invalidJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(true, responseObject.hasError, 'responseObject.hasError should be true');
    System.assertNotEquals(
      null,
      responseObject.errorMessage,
      'responseObject.errorMessage shouldn\'t be null'
    );
  }
}