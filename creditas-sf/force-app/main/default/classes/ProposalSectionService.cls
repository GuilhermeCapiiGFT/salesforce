public with sharing class ProposalSectionService {

    public List<SObject> getLastSection(String parentId, String sobjectName, List<String> fields, String parentRelationField){
        
        fields.add('Id');
        Type tp = Type.forName(sobjectName);
        RecordTypeRepository repo = new RecordTypeRepository();
        Boolean hasRecordType = SObjectUtils.hasRecordType(tp);

        if(hasRecordType){ 
            fields.add('RecordTypeId'); 
        }
        String query = 'SELECT ' + String.join(fields, ', ')+
                       ' FROM ' + sobjectName +
                       ' WHERE ' + parentRelationField + '= \'' + String.escapeSingleQuotes(parentId) + '\''+
                       ' ORDER BY CreatedDate DESC LIMIT 1';
        List<SObject> records = Database.query(query);
        if(records.size() == 0) records = new List<SObject>();
        return records;
    }
    public List<SObject> saveSection(Map<String, Object> objects){
        List<SObject> records = new List<SObject>();
        for(String sobjectName : objects.keySet()){
            System.Type tp = Type.forName(sObjectName);
            SObject sobj = (SObject) tp.newInstance();
            String jsonString = JSON.serialize(objects.get(sObjectName));
            SObject refactoredSObject = (SObject) JSON.deserialize(jsonString, tp);
            records.add(refactoredSObject);
        }
        update records;
        return records;
    }
}