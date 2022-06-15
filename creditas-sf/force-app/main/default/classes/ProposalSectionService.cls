public with sharing class ProposalSectionService {

    public List<SObject> getLastSection(String parentId, String sobjectName, List<String> fields, String parentRelationField){

        List<RecordType> recType = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :sobjectName LIMIT 1
        ];
        fields.add('Id');
        if(!recType.isEmpty()){ fields.add('RecordTypeId'); }

        String query = 'SELECT ' + String.join(fields, ', ')+
                       ' FROM ' + sobjectName +
                       ' WHERE ' + parentRelationField + '= \'' + String.escapeSingleQuotes(parentId) + '\''+
                       ' ORDER BY CreatedDate DESC LIMIT 1';
        System.debug(query);
        List<SObject> records = Database.query(query);
        return records;
    }
    public List<SObject> saveSection(Map<String, Object> objects){
        List<SObject> records = new List<SObject>();
        for(String sobjectName : objects.keySet()){
            System.Type tp = Type.forName(sObjectName);
            SObject sobj = (SObject) tp.newInstance();
            Map<String, Object> fields = (Map<String, Object>)objects.get(sObjectName);
            for(String field : fields.keySet()){
                sobj.put(field, fields.get(field));
            }
            records.add(sobj);
        }
        update records;
        return records;
    }
}