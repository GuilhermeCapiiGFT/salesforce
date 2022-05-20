public with sharing class ProposalOperationController {
    
    @AuraEnabled(Cacheable=true)
    public static OperationSection__c getOperationDetails(Id opportunityId){
        try {
            return ProposalOperationService.getOperationSectionFromOpp(opportunityId);
        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveOperationDetails(SObject record){
        SavePoint sp = Database.setSavePoint();
        try {
            ProposalOperationService.saveRecord((OperationSection__c) record);
        } catch(Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}