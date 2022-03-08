@isTest
public class HttpMockFactory implements HttpCalloutMock {
  protected List<Integer> code;
  protected List<String> status;
  protected List<String> body;
  protected List<Map<String, String>> responseHeaders;
  private integer count = 0;

  public HttpMockFactory(List<Integer> code, List<String> status, List<String> body, List<Map<String, String>> responseHeaders) 
  {
      
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }

  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    for (String key : this.responseHeaders[count].keySet()) {
      res.setHeader(key, this.responseHeaders[count].get(key));
    }
    res.setBody(this.body[count]);
    res.setStatusCode(this.code[count]);
    res.setStatus(this.status[count]);
    count ++;
    return res;
  }
}