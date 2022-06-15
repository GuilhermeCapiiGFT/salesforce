public with sharing class CustomNotificationController {
    
    public static void createCustomNotification(Map<String,List<sObject>> typeObjectListMap){
        Set<Id> sObjectIdSet = new Set<Id>();
        for(String type : typeObjectListMap.keySet()){
            if(type == 'Opportunity'){
                for(Opportunity opp : (List<Opportunity>) typeObjectListMap.get('Opportunity')){
                    sObjectIdSet.add(opp.Id);
                }
                CustomNotificationService.sendCustomNotificationAssignedOpportunity(sObjectIdSet);
            }
        }
    }
    
    public static void createCustomNotificationBatch(Set<String> recipientIds, String process, String targetId){
    
        CustomNotificationService.sendCustomNotificationBatch(recipientIds, process, targetId); 
        
    }
}