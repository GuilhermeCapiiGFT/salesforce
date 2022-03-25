public with sharing class ProposalWarrantyController {
    
    @AuraEnabled
    public static FinancialResources__c getFinancialResource(String opportunityId){
        try {
            return ProposalWarrantyService.getGuarantee(opportunityId);
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}
