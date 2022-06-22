public with sharing class GeneralDataController {
   @AuraEnabled
   public static string getBiometry(String opportunityid, String sectionId){
       GeneralDataService service = new GeneralDataService();
       service.setExternalId(opportunityid);
       service.getAuth();
       Map<String, SObject> response = new Map<String, SObject>();
       response.put('GeneralSection__c', service.getGeneralData(opportunityid, sectionId));
       return JSON.serialize(response);
   }
   @AuraEnabled
   public static string updateCrivoQuery(String opportunityid, String sectionId){
       GeneralDataService service = new GeneralDataService();
       Map<String, Boolean> response = new Map<String, Boolean>();
       try {
        service.updateCrivoQuery(opportunityid, sectionId);
        response.put('success', true);
       } catch (Exception e) {
        response.put('success', false);
       }
       
       return JSON.serialize(response);
   }
}