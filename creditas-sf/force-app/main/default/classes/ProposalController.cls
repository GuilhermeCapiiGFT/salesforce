public with sharing class ProposalController {

    @AuraEnabled
    public static String getReason(String objectReason, String fieldReason){
        return JSON.serialize(PicklistUtils.getPickListValuesWrapped(objectReason, fieldReason));
    }
}