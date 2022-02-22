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
    public static string getAccountRecordTypeId(){
        try {
            return Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}