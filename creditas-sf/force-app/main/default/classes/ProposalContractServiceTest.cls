@IsTest
public class ProposalContractServiceTest {
  @IsTest
  private static void testSuccessSendContract() {
    Test.setMock(HttpCalloutMock.class, createMock(200));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract('test');
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(200, statusCode, 'Status code is incorrect');
  }
    
   @IsTest
    private static void testSuccessGenerateContract() {
        Test.setMock(HttpCalloutMock.class, createMock(201));
        Test.startTest();
        ProposalContractService request = new ProposalContractService();
        request.generateContract('test');
        Integer statusCode = request.getStatusCode();
        Test.stopTest();
        
        System.assertEquals(201, statusCode, 'Status code is incorrect');
    } 
    
    @IsTest
    private static void testSuccessViewContract() {
        Test.setMock(HttpCalloutMock.class, createMock(201));
        Test.startTest();
        ProposalContractService request = new ProposalContractService();
        request.viewContract('test');
        Integer statusCode = request.getStatusCode();
        Test.stopTest();
        
        System.assertEquals(201, statusCode, 'Status code is incorrect');
    }
    
  @IsTest
  private static void testNullParameterSendContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract(null);
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testNullParameterGenerateContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.generateContract(null);
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testNullParameterViewContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.viewContract(null);
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testEmptyParameterSendContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.sendContract('');
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testEmptyParameterGenerateContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.generateContract('');
    Integer statusCode = request.getStatusCode();
    Test.stopTest();

    System.assertEquals(404, statusCode, 'Status code is incorrect');
  }

  @IsTest
  private static void testEmptyParameterViewContract() {
    Test.setMock(HttpCalloutMock.class, createMock(404));
    Test.startTest();
    ProposalContractService request = new ProposalContractService();
    request.viewContract('');
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