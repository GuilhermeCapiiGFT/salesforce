@RestResource(urlMapping='/Account/Employee/*')
global with sharing class AccountEmployeeIntegrationController {
  @HttpPost
  global static String upsertEmployee() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    AccountEmployeeIntegrationService service = new AccountEmployeeIntegrationService(request);
    service.processRequest();
    response.statusCode = service.getStatusCode();
    
    return service.getMessage();
  }
}