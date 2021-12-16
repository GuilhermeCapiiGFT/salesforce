public with sharing class TaskDetailsController {

    @AuraEnabled(cacheable=true)
    public static List<TaskDetailsVO> getTaskDetails(String taskId) {
        List<TaskDetailsVO> VO = new List<TaskDetailsVO>();

        String taskType = [SELECT TaskType__c, id  FROM task WHERE id = :taskId]?.TaskType__c;

        List<TaskDetailSettings__c> taskSettings = [
            SELECT Id, 
                   Name, 
                   CurrencyIsoCode, 
                   Product__c, 
                   WorkflowKey__c, 
                   FieldKey__c, 
                   FieldName__c, 
                   FieldType__c, 
                   RequiredForProfiles__c, 
                   ReadOnlyForProfiles__c, 
                   RelatedObject__c, 
                   NumberPrecision__c, 
                   PicklistValues__c, 
                   MappedField__c, 
                   TaskType__c,
                   DisplaySequence__c
            FROM TaskDetailSettings__c WHERE TaskType__c = :TaskType ORDER BY DisplaySequence__c
        ];
        
        for(TaskDetailSettings__c lista : taskSettings){
            TaskDetailsVO obj = new TaskDetailsVO();
            obj.fieldKey  = lista.FieldKey__c;
            obj.fieldName = lista.FieldName__c;
            obj.fieldType = lista.FieldType__c;
            obj.Id        = lista.id;
            obj.fieldMappedKey = lista.MappedField__c;
            
            if(obj.fieldType == 'Currency'){
                obj.isCurrency = true;
            } 
            else if(obj.fieldType == 'Multi-picklist'){
                obj.isMultiPicklist = true;
                obj.picklistValues = lista.PicklistValues__c;
            } 
            else if(obj.fieldType == 'Picklist'){
                obj.isPicklist = true;
                obj.picklistValues = lista.PicklistValues__c;
            } 
            else if(obj.fieldType == 'Relationship'){
                obj.isRelationShip = true;
                obj.relatedObject = lista.RelatedObject__c;
            }
            else {
                obj.isDefault = true;         
            }

            VO.add(obj);
        }
        return VO;
    }
}