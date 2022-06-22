public with sharing class RecordTypeRepository extends Repository{
    public static final List<String> FIELDS = new List<String>{
        'Id',
        'Name',
        'DeveloperName',
        'NamespacePrefix',
        'Description',
        'BusinessProcessId',
        'SobjectType',
        'IsActive',
        'CreatedById',
        'CreatedDate',
        'LastModifiedById',
        'LastModifiedDate',
        'SystemModstamp'

    };
    public RecordTypeRepository(){
        super(RecordType.class, FIELDS);
    }
    public List<RecordType> getRecordTypeBySObject(String sObj){
        this.addCustomQuery('SELECT {0} FROM {1} WHERE SObjectType = {2}');
        this.addQuotedParameter(sObj);
        return (List<RecordType>) this.query();        
    }

}