public with sharing class ProposalWarrantyController {
    
    @AuraEnabled(cacheable=true)
    public static FinancialResources__c getFinancialResource(String opportunityId){
        try {
            Id validateId = opportunityId;
            return ProposalWarrantyService.getGuarantee(validateId);
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled
    public static Boolean saveFinancialResource(FinancialResources__c financialResource){
       
        return ProposalWarrantyService.saveFinancialResource(financialResource);
    }

    @AuraEnabled(cacheable=true)
    public static WarrantyDataSection__c getWarrantyDataSection(String opportunityId){
        try {
            Id validateId = opportunityId;
            return ProposalWarrantyService.getWarrantyDataSection(validateId);
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled
    public static Boolean saveWarrantyDataSection(WarrantyDataSection__c warrantyObject){
        
        return ProposalWarrantyService.saveWarrantyDataSection(warrantyObject);
    }
}