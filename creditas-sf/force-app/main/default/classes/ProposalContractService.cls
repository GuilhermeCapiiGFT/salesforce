public with sharing class ProposalContractService {

  private static final String ENDPOINT = 'callout:mulesoftGateway/api/autofin-backend/applications/';
  private static String token;

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
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setHeader('Authorization', getToken());
    request.setMethod('POST');
    this.response = new Http().send(request);
  }

  public String viewContract(String loanApplicationId) {

    String url = ENDPOINT + loanApplicationId + '/contract/picture';

    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setHeader('Authorization', getToken());
    request.setMethod('GET');

    this.response = new Http().send(request);
    System.debug('viewContract response: ' + this.response.getBody()) ;
    return this.response.getBody();
  }
}