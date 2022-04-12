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
}