public with sharing class formalizationAnalysisController {

    //private static final String OPP_ATWORK_RECORDTYPEID = Util.getRecordTypeIdbyName('Opportunity','AtWork');
    @AuraEnabled
    public static Opportunity getOpportunnityInfo(String aOpportunityId){
        try {
            return [SELECT AccountNumber__c, Amount, BankCode__c, Branch__c, DocumentNumber__c, DocumentType__c, Full_name__c, toLabel(ProductType__c), Account.BirthDate__c FROM Opportunity WHERE Id = :aOpportunityId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}