public with sharing class ModalProposalComiteController {
    
    @AuraEnabled
    public static string updateOpportunity(Opportunity newOpp){

        try {
            Database.update(newOpp);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
