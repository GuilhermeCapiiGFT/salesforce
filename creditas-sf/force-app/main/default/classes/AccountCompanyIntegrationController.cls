@RestResource(urlMapping='/Account/Company/*')
global with sharing class AccountCompanyIntegrationController {
    
    @HttpPost
    global static void upsertCompany(){
        
    	RestRequest req = RestContext.request;
    	RestResponse response = RestContext.response;

        AccountCompanyIntegrationVO request = AccountCompanyIntegrationVO.parse(req.requestBody.toString());
        if(request.hasError){
            buildResponse(response, 'Payload parse Error.', 500);
            return;
        }
        
        if(String.isBlank(request.Id)){
            buildResponse(response, 'CompanyId cannot be null.', 500);
            return;
        }

        Database.upsertResult result = AccountCompanyIntegrationService.upsertCompany(request);
        if(result.isSuccess()){
            buildResponse(response, 'Company successfully upserted.', 200);
        } else {
            string errorResponse;
            for(Database.error error : result.getErrors()){
                errorResponse = 'Fields: ' + error.getFields();
                errorResponse += ' Message: ' + error.getMessage();
            }
            buildResponse(response, errorResponse, 500);
        }
	}

    private static void buildResponse(RestResponse restResponse, String message, Integer statusCode){
        restResponse.statusCode = statusCode;
        restResponse.responseBody = Blob.valueOf(message);
    }
    
}