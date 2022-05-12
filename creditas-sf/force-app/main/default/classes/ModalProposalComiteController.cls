public with sharing class ModalProposalComiteController {
    
    @AuraEnabled
    public static Boolean updateOpportunityCommitee(Opportunity newOpp){

        try {
            Database.SaveResult sr = Database.update(newOpp,false);
            return sr.isSuccess();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getMyOpportunitiesListView(){
        return [SELECT Id FROM ListView WHERE SobjectType = 'Opportunity' AND DeveloperName = 'MyOpportunities']?.Id;
    }
}
