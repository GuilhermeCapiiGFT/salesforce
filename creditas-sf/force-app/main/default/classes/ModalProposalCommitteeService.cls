public with sharing class ModalProposalCommitteeService {
    
    public static Boolean updateOpportunity(Opportunity opp){
        Database.SaveResult sr = Database.update(opp,false);
        return sr.isSuccess();
    }

    public static String getMyOpportunitiesListView(){
        return [SELECT Id FROM ListView WHERE SobjectType = 'Opportunity' AND DeveloperName = 'MyOpportunities']?.Id;
    }
}