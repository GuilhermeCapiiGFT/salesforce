public with sharing class formalizationAnalysisController {

    @AuraEnabled(cacheable=true)
    public static Account getInformation(String aOpportunityId){
        try {
            String lAccId = formalizationAnalysisService.getAccountIdFromOpp(aOpportunityId);
            Account lAcc = formalizationAnalysisService.getAccount(lAccId);
            return lAcc;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getMapPickList(String objApiName, String fieldApiName){
        try {
            return JSON.serialize(formalizationAnalysisService.getPickListValues(objApiName, fieldApiName));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}