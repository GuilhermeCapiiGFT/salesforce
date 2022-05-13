public with sharing class DocumentApiService {
  static final String NAMED_CREDENTIAL = 'callout:documentsIntegration';

  static Map<String, String> productTypeByRecordType = new Map<String, String>{
    'AtWork' => 'PAYROLL',
    'AutoFin' => 'AUTO_FIN',
    'Home' => 'HOME_REFIN'
  };

  String loanApplicationId;
  String recordTypeName;
  HttpResponse response;
  DocumentApiResponseVO responseObject;

  public void setLoanApplicationId(String loanApplicationId) {
    this.loanApplicationId = loanApplicationId;
  }

  public void setRecordTypeName(String recordTypeName) {
    this.recordTypeName = recordTypeName;
  }

  public HttpResponse getResponse() {
    return this.response;
  }

  public DocumentApiResponseVO getResponseObject() {
    return this.responseObject;
  }

  public void sendRequest() {
    String productType = productTypeByRecordType.containsKey(this.recordTypeName)
      ? productTypeByRecordType.get(this.recordTypeName)
      : '';

    String endpoint =
      NAMED_CREDENTIAL +
      '?loanAppId=' +
      this.loanApplicationId +
      '&productType=' +
      productType;

    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setMethod('GET');

    this.response = new Http().send(request);
    this.responseObject = this.parseResponse(this.response);
  }

  DocumentApiResponseVO parseResponse(HttpResponse response) {
    DocumentApiResponseVO responseObject = new DocumentApiResponseVO();

    if (response != null) {
      Integer statusCode = response.getStatusCode();
      responseObject.hasError = statusCode == 200 ? false : true;
      if (statusCode == 200) {
        responseObject = DocumentApiResponseVO.parse(response.getBody());
      } else if (statusCode == 400) {
        responseObject.errorMessage = 'Bad request';
      } else if (statusCode == 500) {
        responseObject.errorMessage = 'Server error';
      } else {
        responseObject.errorMessage = 'Unexpected error';
      }
    }

    return responseObject;
  }
}