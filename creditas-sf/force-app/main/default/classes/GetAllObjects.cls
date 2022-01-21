public with sharing class GetAllObjects {
    
    @AuraEnabled(cacheable=true)

    Public static List<String> objects(){
        
        List<string> allObjects = new List<string>();

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
           String name = objTyp.getDescribe().getName();
        
         if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
            !name.containsignorecase('share') && !name.containsignorecase('feed')){      
                allObjects.add(name);
              System.debug( 'Name : ' + name);
          }
        
        }
        return allObjects;
    }    
  

    
    @AuraEnabled(cacheable=true)
    Public static List<String> profiles(){
        
        List<String> allProfiles = new List<String>();
        
        for(Profile profile :  [SELECT Name FROM Profile ORDER BY Name ASC]){
            allProfiles.add(profile.name);
        }
        
        //List<Profile> allProfiles = [SELECT Name FROM Profile ORDER BY Name ASC];
          
        return allProfiles;
        
    }

    @AuraEnabled(cacheable=true)
    public static String getPicklistMethod(Id recordId) {
        TaskDetailSettings__c pickListValues = [SELECT PicklistValues__c FROM TaskDetailSettings__c WHERE Id = :recordId];
        return pickListValues.PicklistValues__c; //{English;English123}
}

}