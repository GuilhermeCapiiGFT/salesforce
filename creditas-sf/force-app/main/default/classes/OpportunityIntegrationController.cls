@RestResource(urlMapping='/IntegrationOpportunity/*')
global with sharing class OpportunityIntegrationController {

    public static OpportunityIntegrationVO requestBodyObj;
    public static Id opportunityId;
    
	@HttpPut
    global static void putMethod() 
    {
        String requestBody = RestContext.request.requestBody.toString();
        OpportunityIntegrationVO requestBodyObj = OpportunityIntegrationVO.parse(requestBody);

        if (requestBodyObj.hasError){
            buildErrorResponse('Payload parse Error.');
        }

        if(requestBodyObj.participants == null){
            buildErrorResponse('No participants found.');
        }

        Map<String, String> mapPersonAccount = OpportunityIntegrationService.getPersonIdAndAccountName( requestBodyObj.participants );

        if(mapPersonAccount.isEmpty()){
            buildErrorResponse('Proponent not found in Salesforce');
        }        
        
        commitTransactions();

        if(isOperationSucess){
            OpportunityIntegrationService.setResponse(new OpportunityIntegrationService.Response(200,opportunityId,'Opportunity successfully upserted.'),200);
        } else {
            buildErrorResponse('Operation Failed.');
        }
            
    }   
    
    public static Boolean commitTransactions(){
        
        Savepoint sp = Database.setSavepoint();
        
        Database.upsertResult upsertOpp = OpportunityIntegrationService.upsertOpportunity();
        if(upsertOpp.isSuccess()){
            opportunityId = upsertOpp.getId();
        } else {
            String errorOpp = buildErrorMessage(upsertOpp.getErrors());
            Database.rollback(sp);
            buildErrorResponse(errorOpp);
        }
        
        Database.UpsertResult upsertQuote = OpportunityIntegrationService.upsertQuote();
        if(!upsertQuote.isSuccess()){
            String errorQuote = buildErrorMessage(upsertQuote.getErrors());
            Database.rollback(sp);
            buildErrorResponse(errorQuote);
        }

        Database.UpsertResult upsertOppRole = OpportunityIntegrationService.upsertOpportunityRoles();
        if(!upsertOppRole.isSuccess()){
            String errorOppRole = buildErrorMessage(upsertOppRole.getErrors());
            Database.rollback(sp);
            buildErrorResponse(errorOppRole);
        }     
        return upsertOpp.isSuccess() && upsertQuote.isSuccess() && upsertOppRole.isSuccess();
    }

    private static void buildErrorResponse(String errorMessage){
        OpportunityIntegrationService.setResponse(new OpportunityIntegrationService.Response(500,null,errorMessage),500);
        insertLogUtils.insertErrorLog('apex/services/IntegrationOpportunity', requestBody, 500, errorMessage);
        return;
    }   

    private static String buildErrorMessage(List<Database.Error> errorList){
        String response;
        for(Database.error error : errorList){
            String errorMessage = 'Fields error: ' + error.getFields() + ' Message error: ' + error.getMessage();
            response += errorMessage;
        }
        return response;
    }
    
   
}
