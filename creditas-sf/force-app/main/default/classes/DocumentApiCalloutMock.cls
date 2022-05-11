@isTest
public class DocumentApiCalloutMock implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    String endpoint = req.getEndpoint();
    String body;
    Integer statusCode;

    if (endpoint.contains('SUCCESS')) {
      body = DocumentApiResponseVO.getSuccessResponse();
      statusCode = 200;
    } else if (endpoint.contains('BAD_REQUEST')) {
      body = DocumentApiResponseVO.getBadRequestResponse();
      statusCode = 400;
    } else if (endpoint.contains('SERVER_ERROR')) {
      body = DocumentApiResponseVO.getServerErrorResponse();
      statusCode = 500;
    } else if (endpoint.contains('UNEXPECTED_ERROR')) {
      body = '{ "error": "unexpected" }';
      statusCode = 404;
    } else {
      body = '';
      statusCode = 404;
    }

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(body);
    res.setStatusCode(statusCode);
    return res;
  }
}