public with sharing class DocumentApiService {
  static final String NAMED_CREDENTIAL = 'callout:mulesoftGateway';

  static Map<String, String> productTypeByRecordType = new Map<String, String>{
    'AtWork' => 'PAYROLL',
    'AutoFin' => 'AUTO_FIN',
    'Home' => 'HOME_REFIN'
  };

  String loanApplicationId;
  String recordTypeName;
  String authToken;
  HttpResponse response;
  DocumentApiResponseVO responseObject;


  public void setLoanApplicationId(String loanApplicationId) {
    this.loanApplicationId = loanApplicationId;
  }

  public void setRecordTypeName(String recordTypeName) {
    this.recordTypeName = recordTypeName;
  }

  public DocumentApiResponseVO getResponseObject() {
    return this.responseObject;
  }

  public void getAuth(){
    HTTPResponse httpAuthRes = GetMulesoftAuthController.getAuth();
    this.responseObject = this.parseResponse(httpAuthRes, false);
    if(httpAuthRes.getStatusCode() == 200){
      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpAuthRes.getBody());
  
      this.authToken = responseMap.get('token_type') + ' ' + responseMap.get('access_token');
    }
  }

  public void sendRequest() {

    if(this.authToken == null){ return; }

    String productType = productTypeByRecordType.containsKey(this.recordTypeName) ? productTypeByRecordType.get(this.recordTypeName) : '';

    String endpoint = NAMED_CREDENTIAL + '/api/documents?loanAppId=' + this.loanApplicationId + '&productType=' + productType;

    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setHeader('Authorization', this.authToken);
    request.setMethod('GET');

    this.response = new Http().send(request);
    this.responseObject = this.parseResponse(this.response, true);
  }

  DocumentApiResponseVO parseResponse(HttpResponse response, Boolean isGetDocuments) {
    DocumentApiResponseVO responseObject = new DocumentApiResponseVO();

    if (response != null) {
      Integer statusCode = response.getStatusCode();
      responseObject.hasError = statusCode == 200 ? false : true;
      if (statusCode == 200 && isGetDocuments) {
        responseObject = DocumentApiResponseVO.parse(response.getBody());
        responseObject.items.sort();
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