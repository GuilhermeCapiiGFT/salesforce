public with sharing class SynchOpportunityDataController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getSyncInfo(Id oppId) {
      Opportunity result = [SELECT IsSynchEnabled__c, IsExternallySynched__c, name FROM Opportunity WHERE Id =:oppId][0];
        return result;       
    }
    
    @AuraEnabled
    public static void updateSynchingFields(Opportunity opp) {
        
        Opportunity oppToUpdate = new Opportunity(
           Id = opp.Id,
           IsSynchEnabled__c = 'SYNCHING',
           IsExternallySynched__c = false
        );
         
        update oppToUpdate;
    }
}