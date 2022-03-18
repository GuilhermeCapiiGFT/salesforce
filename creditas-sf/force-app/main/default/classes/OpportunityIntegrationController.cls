@RestResource(urlMapping='/IntegrationOpportunity/*')
global with sharing class OpportunityIntegrationController {

    public static OpportunityIntegrationVO requestBodyObj;
    public static Id opportunityId;
    
	@HttpPut
    global static void putMethod() 
    {
        String requestBody = RestContext.request.requestBody.toString();
        requestBodyObj = OpportunityIntegrationVO.parse(requestBody);

        if (requestBodyObj.hasError){
            buildErrorResponse('Payload parse Error.');
            return;
        }

        if(requestBodyObj.participants == null || requestBodyObj.participants.isEmpty()){
            buildErrorResponse('No participants found.');
            return;
        }

        Map<String, String> mapPersonAccount = OpportunityIntegrationService.getPersonIdAndAccountName( requestBodyObj.participants );

        if(mapPersonAccount.isEmpty()){
            buildErrorResponse('Proponent not found in Salesforce.');
            return;
        }        
        
        Boolean isTransactionSucess = commitTransactions();

        if(isTransactionSucess){
            RestContext.response = OpportunityIntegrationService.setResponse(new OpportunityIntegrationService.Response(200,opportunityId,'Opportunity successfully upserted.'),200);
        }        
    }   
    
    private static Boolean commitTransactions(){
        String errorOpp = '';
        String errorQuote = '';
        String errorOppRole = '';
        
        Savepoint sp = Database.setSavepoint();
    
        Database.upsertResult upsertResultOpp = OpportunityIntegrationService.upsertOpportunity(requestBodyObj);

        if(upsertResultOpp.isSuccess()){
        opportunityId = upsertResultOpp.getId();
        OpportunityIntegrationService.opportunityId = upsertResultOpp.getId();
        } else {
            errorOpp = buildErrorMessage(upsertResultOpp.getErrors());
        }
    
        Database.UpsertResult upsertResultQuote = OpportunityIntegrationService.upsertQuote(requestBodyObj);
        if(!upsertResultQuote.isSuccess()){
            errorQuote = buildErrorMessage(upsertResultQuote.getErrors());
        }
        
        List<Database.upsertResult> upsertOppRoleList = OpportunityIntegrationService.upsertOpportunityRoles(requestBodyObj);
        Boolean upsertOppRoles = true;
        for(Database.upsertResult upsertOppRole : upsertOppRoleList){
            if(!upsertOppRole.isSuccess()){
                upsertOppRoles = upsertOppRole.isSuccess();
                errorOppRole = buildErrorMessage(upsertOppRole.getErrors());
                break;
            }     
        }

        Boolean commitsSuccessfull = upsertResultOpp.isSuccess() && upsertResultQuote.isSuccess() && upsertOppRoles;
        if(!commitsSuccessfull){
            Database.rollback(sp);
            buildErrorResponse(errorOpp + ' ' + errorQuote + ' ' + errorOppRole);
        }
        return commitsSuccessfull;    
    }

    private static void buildErrorResponse(String errorMessage){
        RestContext.response = OpportunityIntegrationService.setResponse(new OpportunityIntegrationService.Response(500,null,errorMessage),500);
        InsertLogUtils.insertErrorLog('apex/services/IntegrationOpportunity', JSON.serialize(requestBodyObj), 500, errorMessage);
        return;
    }   

    private static String buildErrorMessage(List<Database.Error> errorList){
        String stringResponse;
        for(Database.error error : errorList){
            String errorMessage = ' Fields error: ' + error.getFields() + ' Message error: ' + error.getMessage();
            stringResponse += errorMessage;
        }
        return stringResponse;
    }
}