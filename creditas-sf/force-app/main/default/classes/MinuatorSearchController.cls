public with sharing class MinuatorSearchController {    
    @AuraEnabled
    public static String getLead(String friendlyId){
        return MinuatorSearchService.getLead(friendlyId);        
    }          
}