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
}