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
    public static void saveMethod(WarrantyDataSection__c warrantyObject, FinancialResources__c financialResource){
        SavePoint sp = Database.setSavePoint();
        try {
            ProposalWarrantyService.saveWarrantyDataSection(warrantyObject);
            ProposalWarrantyService.saveFinancialResource(financialResource);
        } catch (Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}