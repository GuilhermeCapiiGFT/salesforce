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
            ProposalService.changeStageName(oppId);    
        } catch (Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
    @AuraEnabled
    public static string saveSection(String section){
        Map<String, Object> records = (Map<String, Object>) JSON.deserializeUntyped(section);
        ProposalSectionService service = new ProposalSectionService();
        List<SObject> salvedRecords = service.saveSection(records);
        return JSON.serialize(salvedRecords);
    }
    @AuraEnabled
    public static string getLastSection(String opportunityId, String sobjectName, List<String> fields, String parentRelationField){
        ProposalSectionService service = new ProposalSectionService();
        List<SObject> records = service.getLastSection(opportunityId, sobjectName, fields, parentRelationField);
        if(records.isEmpty()) return null;
        Map<String, SObject> response = new Map<String, SObject>();
        response.put(sobjectName, records.get(0));
        return JSON.serialize(response);
    }
}