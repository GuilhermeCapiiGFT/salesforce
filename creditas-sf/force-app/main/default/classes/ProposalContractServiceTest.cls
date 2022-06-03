@IsTest
public class ProposalContractServiceTest {
  @IsTest
  private static void testSuccess() {
    Test.setMock(HttpCalloutMock.class, createMock(200));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract('test');
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(200, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testNullParameter() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract(null);
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testEmptyParameter() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract('');
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
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