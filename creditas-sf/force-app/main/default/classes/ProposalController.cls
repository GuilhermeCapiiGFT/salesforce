public with sharing class ProposalController {

    @AuraEnabled
    public static String getReason(String objectReason, String fieldReason) {
        return JSON.serialize(PicklistUtils.getPickListValuesWrapped(objectReason, fieldReason));
    }

    @AuraEnabled
    public static void createNewInstance(Id accId, Id oppId) 
    {
        Savepoint sp = Database.setSavePoint();
        
        try {
            ProposalService.start(accId, oppId);    
        } catch (Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}