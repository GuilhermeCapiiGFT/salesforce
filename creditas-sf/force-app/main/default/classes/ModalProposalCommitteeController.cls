public with sharing class ModalProposalCommitteeController {

    @AuraEnabled
    public static Boolean updateOpportunityCommittee(Opportunity newOpp){
        return ModalProposalCommitteeService.updateOpportunity(newOpp);
    }

    @AuraEnabled
    public static String getMyOpportunitiesListView(){
        return ModalProposalCommitteeService.getMyOpportunitiesListView();
    }
}