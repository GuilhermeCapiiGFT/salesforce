public with sharing class SearchController {

    @AuraEnabled
    public static List<sObject> search(String objectName, String searchTerm){
        
        try {
            List<List<sObject>> searchRecords = new List<List<sObject>>();
            if(objectName != null && searchTerm != null){
                String searchKeyword = searchTerm;
                String returningQuery = objectName+' ( Id, Name )';
                String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 5';
                searchRecords = Search.Query(Query);
            }
            return searchRecords.isEmpty() ?  new List<sObject>() : searchRecords.get(0);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static sObject getRelatedRecord(String aRelatedObject, Id aRelatedRecordId){
        
        try {
            SObject lRelatedRecord;
            if(aRelatedObject != null && aRelatedRecordId != null){
                String query = ' SELECT Id, Name FROM ' +aRelatedObject +' WHERE Id = :aRelatedRecordId LIMIT 1';
                lRelatedRecord = Database.query( query );
        	}
            return lRelatedRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}