@RestResource(urlMapping='/Account/Employee/*')
global with sharing class AccountEmployeeIntegrationController {
  @HttpPost
  global static String upsertEmployee() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    try {
      AccountEmployeeIntegrationService service = new AccountEmployeeIntegrationService(req);
      service.upsertEmployee();

      res.statusCode = 200;
      return 'Registro criado/atualizado com sucesso';
    } catch (Exception e) {
      String returnMessage = e.getCause() == null ? e.getMessage() : e.getMessage() + ' ' + e.getCause().getMessage();
      res.statusCode = 400;
      return returnMessage;
    }
  }
}