public with sharing class SObjectUtils {
    
    public static void upsertRecords(List<SObject> records)
    {
        if(!records.isEmpty())
        {
            upsert records;
        } 
    }

    public static void upsertRecord(SObject record)
    {
        upsert record;   
    }
    public static boolean hasRecordType(System.Type sobj){
        RecordTypeRepository repo = new RecordTypeRepository();
        List<RecordType> recTypes = repo.getRecordTypeBySObject(String.valueOf(sObj));
        return !recTypes.isEmpty();
    }
}