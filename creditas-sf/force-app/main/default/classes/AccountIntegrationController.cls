@RestResource(urlMapping='/IntegrationAccountIN/v2/*')
global with sharing class AccountIntegrationController {
  @HttpPut
  global static void putMethod() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    AccountIntegrationService integration = new AccountIntegrationService();
    integration.setRequestBody(request.requestBody.toString());
    integration.upsertData();

    response.statusCode = integration.getStatusCode();
    response.responseBody = integration.getResponseAsBlob();
  }
}