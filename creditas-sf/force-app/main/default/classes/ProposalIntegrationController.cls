public with sharing class ProposalIntegrationController {
    @AuraEnabled
    public static String finishAnalysis(Id opportunityId, String status){
        try{
            String payload = ProposalIntegrationService.getRequest(opportunityId, status);
            String response = ProposalIntegrationService.sendAnalysis(payload);
            System.debug('RESPONSE: '+response);

            return response;
        }catch(Exception e){
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}