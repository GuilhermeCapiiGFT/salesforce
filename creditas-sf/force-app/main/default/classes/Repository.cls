/**
 * @author Otávio Frank - GFT Brasil
 */
public abstract class Repository {

    virtual
    public SObject save(SObject record) {

        if ( record == null) return null;

        if ( record.Id == null ) {
            insert record;
        } else {
            update record ;
        } 

        return record;
    }

    virtual
    public List<SObject> save (List<SObject> records) {

        if (records == null) return new List<SObject>();

        if (records.isEmpty()) return records;

        List<SObject> recordsToCreate = filterRecordsWithoutId(records);

        if (!recordsToCreate.isEmpty()) {
            insert recordsToCreate;
        }

        List<SObject> recordsToUpdate = filterRecordsWithId(records);

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }

        return records;

    }

    virtual
    public SObject save(SObject record , Schema.SObjectField externalId) {

        if ( record == null) return null;

        Database.upsert(record, externalId);
    
        return record;
    }

    virtual
    public void remove( SObject record ) {

        if (record == null) return;

        delete record;
    }

    virtual
    public void remove( List<SObject> records ) {

        if (records == null || records.isEmpty()) return;

        delete records;
    }

    virtual
    protected List<SObject> filterRecordsWithId(List<SObject> records) {

        List<SObject> recordsToStore = new  List<SObject>();

        for (SObject record : records) {
            if (record.id != null) recordsToStore.add (record);
        }

        return recordsToStore;
    }

    virtual
    protected List<SObject> filterRecordsWithoutId(List<SObject> records) {
        List<SObject> recordsToStore = new  List<SObject>();

        for (SObject record : records) {
            if (record.id == null) recordsToStore.add (record);
        }

        return recordsToStore;
    }

}