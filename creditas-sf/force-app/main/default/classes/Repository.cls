/**
 * @author Otávio Frank - GFT Brasil
 */
public abstract class Repository {
    public static final String DEFAULT_QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE Id = {2}';
    public String customQueryTemplate;
    public List<String> parameters;
    public String sobjectName;
    public Repository(){
        this.parameters = new List<String>();
    }
    public Repository(System.Type sobjectType, List<String> fields){
        this.sobjectName = String.valueOf(sobjectType);
        this.parameters = new List<String>();
        this.parameters.add( String.join( fields, ', ') );
        this.parameters.add( this.sobjectName );
        
    }

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
    public virtual void addParameter(String parameter){
        this.parameters.add(parameter);
    }
    public virtual void addQuotedParameter(String parameter){
        this.parameters.add('\''+parameter+'\'');
    }
    public virtual void addCustomQuery(String customQueryTemplate){
        this.customQueryTemplate = customQueryTemplate;
    }
    public List<SObject> selectById(){
        if(this.parameters.size() < 3) {
            throw new RepositoryException('Insufficient Arguments, please define Sobject, fields and Id');
        }
        return Database.query(this.resolveDefaultQuery());

    }
    public List<SObject> query(){
        return Database.query(this.resolveQuery());
    }
    protected virtual String resolveQuery(){
        String query = this.customQueryTemplate == null 
                       ? DEFAULT_QUERY_TEMPLATE 
                       : this.customQueryTemplate;
        String q = String.format(query,  this.parameters);  
        return q;
    }
    private virtual String resolveDefaultQuery(){
        String query = DEFAULT_QUERY_TEMPLATE;
        return String.format(query,  this.parameters);
    }
    public class RepositoryException extends Exception{}
}