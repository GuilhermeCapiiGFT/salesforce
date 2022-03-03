public with sharing class ProposalController {

    @AuraEnabled(cacheable=true)
    public static Map<String, SObject> getInfoRecords(String recordId) 
    {
        return ProposalService.getPersonalDataSectionRecord(recordId);
    }

    @AuraEnabled
    public static String getReason(String objectReason, String fieldReason){
        return JSON.serialize(PicklistUtils.getPickListValuesWrapped(objectReason, fieldReason));
    }
}