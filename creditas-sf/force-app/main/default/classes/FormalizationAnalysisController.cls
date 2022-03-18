public with sharing class FormalizationAnalysisController {

    @AuraEnabled(cacheable=true)
    public static Account getInformation(String aOpportunityId){
        try {
            String AccId = formalizationAnalysisService.getAccountIdFromOpp(aOpportunityId);
            Account Acc = formalizationAnalysisService.getAccount(AccId);
            return Acc;
            
        } catch (Exception e) {
            
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled
    public static String getMapPickList(String objApiName, String fieldApiName){
        
        return JSON.serialize(PicklistUtils.getPickListValuesWrapped(objApiName, fieldApiName));
    }
}