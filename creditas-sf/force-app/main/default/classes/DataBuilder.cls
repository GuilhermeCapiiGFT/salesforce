public virtual with sharing class DataBuilder {

    protected Set<String> iterableFieldNames = new Set<String>();
    protected SObject record { get; private set; }

    private Map<String,Object> populatedFields = new Map<String, Object>();
    private List<String> sobjectFieldNames = new List<String>();
    private Map<String, Schema.SObjectField> sobjectFields;

    private List<String> warnings = new List<String>();

    public SObject createSObject( Boolean doInsert ){
        if(doInsert){
            insert record;
        }
        return record;
    }
    public SObject createSObject(Map<String, Object> sobjectOpts, Boolean doInsert){
        if(sobjectOpts != null){
            for(string field : sobjectOpts.keySet()){
                if(sobjectFieldNames.contains(field)){
                    record.put(field, sobjectOpts.get(field));
                }
                else{
                    this.warnings.add('Field ' + field +' does not exists in this organization');
                }
            }
        }

        if(doInsert){
            insert record;
        }
        return record;
    }
    /* Dizer para a classe quais os campos que receberão + i */
    public virtual void setIterableFields(List<String> fields){
        iterableFieldNames.addAll( fields );
    }
    public virtual void setIterableFields(Set<String> fields){
        iterableFieldNames.addAll( fields );
    }
    public virtual void addIterableField(String fieldName){
        iterableFieldNames.add(fieldName);
    }
    public List<SObject> createSObjects(Map<String, Object> sobjectOpts, Integer qtd, Boolean doInsert){

        List<SObject> sobjects = new List<SObject>();

        if( this.iterableFieldNames.isEmpty() ){
            return null;
        }
         Map<String, Object> allFields = new Map<String, Object>();
         allFields.putAll(populatedFields);
         if( sobjectOpts != null ) allFields.putAll(sobjectOpts);

        for(Integer i = 0; i< qtd; i++){
            Sobject newRecord = this.record.clone();

            for(String field : allFields.keySet()){

                if( !sobjectFieldNames.contains(field) ) { continue; } 
                
                Object fieldValue = allFields.get(field);
                if(iterableFieldNames.contains(field)){
                    String newIterableValue = String.valueOf(fieldValue);
                    newIterableValue = i > 0 ? newIterableValue + (i + 1) : newIterableValue;
                    newRecord.put(field, newIterableValue);
                }else{
                    newRecord.put(field, fieldValue);
                }
            }
            sobjects.add(newRecord);            
        }
        if( doInsert ) { insert sobjects; }
        return sobjects;
    }

    public void setRecord(SObject record){
        this.populatedFields = record.getPopulatedFieldsAsMap();

        this.record = record;

        SObjectType sobjType = Schema.getGlobalDescribe().get(String.valueOf(record.getSObjectType()));
        sobjectFields = sobjType.getDescribe().fields.getMap();

        for(SObjectField field: sobjectFields.values()){
            sobjectFieldNames.add( String.valueOf(field));
        }
    }
    public List<String> getWarnings(){
        return this.warnings;
    }
}