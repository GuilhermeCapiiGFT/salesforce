public with sharing class ProposalContractService {

  private static final String ENDPOINT = 'callout:mulesoftGateway/api/autofin-backend/applications/';
  private static String token;

  private HttpResponse buildRequest(String url, String method){
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setHeader('Authorization', getToken());
    request.setMethod(method);
    this.response = new Http().send(request);
    return this.response;
  }

  private static String getToken() {
    if (token != null) {
      return token;
    }

    HttpResponse authentication = GetMulesoftAuthController.getAuth();
    if (authentication.getStatusCode() == 200) {
      Map<String, Object> authParameters = (Map<String, Object>) JSON.deserializeUntyped(
        authentication.getBody()
      );
      token = authParameters.get('token_type') + ' ' + authParameters.get('access_token');
    }

    return token;
  }

  private HttpResponse response;

  public Integer getStatusCode() {
    return this.response.getStatusCode();
  }

  public void sendContract(String loanApplicationId) {
    String url = ENDPOINT + loanApplicationId + '/contract/signature';
    buildRequest(url, 'POST');
  }

  public void generateContract(String loanApplicationId) {
    String url = ENDPOINT + loanApplicationId + '/contract';
    buildRequest(url, 'POST');
  }

  public String viewContract(String loanApplicationId) {

    String url = ENDPOINT + loanApplicationId + '/contract/picture';
    buildRequest(url, 'GET');
    Blob responseBlob = this.response.getBodyAsBlob();
    String base64 = EncodingUtil.base64Encode(responseBlob);
    return base64;
    
  }
}