public with sharing class ProposalIntegrationController {
    @AuraEnabled
    public static String finishAnalysis(Id opportunityId, String status){
        try{
            ProposalIntegrationVO payload = ProposalIntegrationService.getRequest(opportunityId, status);
            System.debug(JSON.serializePretty(payload));
            return ProposalIntegrationService.sendAnalysis(JSON.serialize(payload));
        }catch(Exception e){
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}