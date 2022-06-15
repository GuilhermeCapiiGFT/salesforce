@IsTest
public class ProposalContractControllerTest {
  @IsTest
  private static void testSuccessSendContract() {
    Test.setMock(HttpCalloutMock.class, createMock(200));
    Test.startTest();
    Integer statusCode = ProposalContractController.sendContract('test');
    Test.stopTest();

    System.assertEquals(200, statusCode, 'Status code is incorrect');
  }

  @isTest
  private static void testSuccessGenerateContract() {
    Test.setMock(HttpCalloutMock.class, createMock(201));
    Test.startTest();
    Integer statusCode = ProposalContractController.generateContract('test');
    Test.stopTest();
    System.assertEquals(201, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testSuccessViewContract() {
    Test.setMock(HttpCalloutMock.class, createMock(200));
    Test.startTest();
    String body = ProposalContractController.viewContract('test');
    Test.stopTest();
    System.assert(body != null, 'Body is incorrect');
  }

  @IsTest
  private static void testNullParameter() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    Integer statusCode = ProposalContractController.sendContract(null);
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testEmptyParameter() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    Integer statusCode = ProposalContractController.sendContract('');
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testExceptionSendContract() {
    Exception testException;
    Test.startTest();
    try {
      Integer statusCode = ProposalContractController.sendContract('test');
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assertEquals(true, testException != null, 'An exception should\'ve been thrown');
  }

  @IsTest
  private static void testExceptionGenerateContract() {
    Exception testException;
    Test.startTest();
    try {
      Integer statusCode = ProposalContractController.generateContract('test');
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assertEquals(true, testException != null, 'An exception should\'ve been thrown');
  }

  @IsTest
  private static void testExceptionViewContract() {
    Exception testException;
    Test.startTest();
    try {
      String body = ProposalContractController.viewContract('test');
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assertEquals(true, testException != null, 'An exception should\'ve been thrown');
  }

  private static HttpMockFactory createMock(Integer statusCode) {
    return new HttpMockFactory(
      new List<Integer>{ 200, statusCode },
      new List<String>{ '', '' },
      new List<String>{ '{"access_token": "some_token", "token_type": "Bearer"}', '' },
      new List<Map<String, String>>{
        new Map<String, String>{ '' => '' },
        new Map<String, String>{ '' => '' }
      }
    );
  }
}