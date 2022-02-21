/*********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Controller para o componente da página customizada de Tasks
* ================================================================================================================================
* History
* -------
* Test Class: TaskDetailsControllerTest
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       ?                       16/12/2021      Created     Inclui os métodos responsáveis por atualizar a página de Tasks com os campos
**********************************************************************************************************************************/
public with sharing class TaskDetailsController {
    
    @AuraEnabled(cacheable=false)
    public static String getRecordType(String taskId) {
        try{
            Id taskValidId = taskId;
            return [SELECT Id, Recordtype.DeveloperName FROM Task WHERE Id =: taskId LIMIT 1]?.RecordType.DeveloperName;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getTaskDetails(String taskId) {
        try {
            Map<String, Object> mapResult = new Map<String, object>();
            Task task = [SELECT Id, TaskType__c, TaskDetails__c, Recordtype.DeveloperName FROM Task WHERE id = :taskId LIMIT 1];
            
            mapResult.put('Product',task.Recordtype.DeveloperName); 
            mapResult.put('TaskType',task.TaskType__c); 
    
            if(task != null && task.Recordtype.DeveloperName != null){
                List<TaskDetailsVO> lstTaskDetailSettingVO = getTaskDetailSettings(task.TaskType__c, task.Recordtype.DeveloperName.toUppercase());
                mapResult.put('TaskDetailSettings', lstTaskDetailSettingVO);
                
                if(task.TaskDetails__c != null){
                    List<SObject> recordTaskDetail = getRecordTaskDetails(task.TaskDetails__c);
                    mapResult.put('TaskDetails', recordTaskDetail);
                }
            }
            return mapResult;
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static void updateRecordTask(String taskId, String taskDetailsId) {
        try {
            Id validTaskId = taskId;
            Id validTaskDetailsId = taskDetailsId;
            if(validTaskId != null && validTaskDetailsId != null){
                Task updateTask = new Task(Id = validTaskId);
                updateTask.TaskDetails__c = validTaskDetailsId;

                update updateTask;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(String Id) {

        Task varTask = [SELECT Id, TaskDetails__c, WhatId, AccountId FROM Task WHERE Id =: Id];

        Opportunity varOpportunity;
        String varObjectName;
        Id recordId;
        
        if(String.isNotBlank(varTask.whatId))
        {
            recordId = (Id) varTask.whatId;
            varObjectName = Util.getSObjectNameById(recordId);
    
            if(varObjectName.equals('Opportunity'))
            {
                varOpportunity = [SELECT Id, Name, Account.name, Account.DocumentType__c, Account.DocumentNumber__c, CreatedDate 
                                    FROM Opportunity
                                    WHERE Id = :varTask.WhatId];
            }
        } 

        return varOpportunity;
    }

    @AuraEnabled(cacheable=false)
    public static List<TaskDetailsVO> getTaskDetailSettings(String taskType, String recordTypeTask) {

        List<TaskDetailsVO> resultTaskDetailsVO = new List<TaskDetailsVO>();
        
        List<TaskDetailSettings__c> lstTaskSettings = [
            SELECT Id, Name, CurrencyIsoCode, Product__c, WorkflowKey__c, FieldKey__c, 
                FieldName__c, FieldType__c, RequiredForProfiles__c, ReadOnlyForProfiles__c, 
                RelatedObject__c, NumberPrecision__c, PicklistValues__c, MappedField__c, TaskType__c,
                DisplaySequence__c, FieldMask__c, CheckboxGroupValues__c, RadioGroupValues__c
            FROM TaskDetailSettings__c 
            WHERE TaskType__c = :taskType
            AND Product__c = :recordTypeTask
            ORDER BY DisplaySequence__c
        ];
            
        for(TaskDetailSettings__c currentFieldSettings : lstTaskSettings){

            TaskDetailsVO mappedFieldVO = new TaskDetailsVO();
            
            mappedFieldVO.fieldKey       = currentFieldSettings.FieldKey__c;
            mappedFieldVO.fieldName      = currentFieldSettings.FieldName__c;
            mappedFieldVO.fieldType      = currentFieldSettings.FieldType__c;
            mappedFieldVO.Id             = currentFieldSettings.id;
            mappedFieldVO.fieldMappedKey = currentFieldSettings.MappedField__c;
            mappedFieldVO.fieldMask      = (currentFieldSettings.FieldMask__c != null) ? currentFieldSettings.FieldMask__c : '';
            
            
            mappedFieldVO.isReadOnly = actionByProfile(currentFieldSettings.ReadOnlyForProfiles__c);
            mappedFieldVO.isRequired = actionByProfile(currentFieldSettings.RequiredForProfiles__c);

            if(currentFieldSettings.FieldType__c == 'Currency'){
                mappedFieldVO.isCurrency = true;
                mappedFieldVO.numberPrecision = (currentFieldSettings.NumberPrecision__c != null) ? currentFieldSettings.NumberPrecision__c : '0.01';
            } 
            else if(currentFieldSettings.FieldType__c == 'Multi-picklist'){
                mappedFieldVO.isMultiPicklist = true;
                mappedFieldVO.picklistValues = currentFieldSettings.PicklistValues__c != null ? currentFieldSettings.PicklistValues__c : '';
            } 
            else if(currentFieldSettings.FieldType__c == 'Picklist'){
                mappedFieldVO.isPicklist = true;
                mappedFieldVO.picklistValues = currentFieldSettings.PicklistValues__c != null ? currentFieldSettings.PicklistValues__c : '';
            } 
            else if(currentFieldSettings.FieldType__c == 'Checkbox'){
                mappedFieldVO.isCheckbox = true;
            }
            else if(currentFieldSettings.FieldType__c == 'Relationship'){
                mappedFieldVO.isRelationship = true;
                mappedFieldVO.relatedObject = currentFieldSettings.RelatedObject__c;
            }
            else if(currentFieldSettings.FieldType__c == 'Header'){
                mappedFieldVO.isHeader = true;
            }            
            else if(currentFieldSettings.FieldType__c == 'Number'){
                mappedFieldVO.isNumber = true;
                mappedFieldVO.numberPrecision = (currentFieldSettings.NumberPrecision__c != null) ? currentFieldSettings.NumberPrecision__c : '0';
            }           
            else if(currentFieldSettings.FieldType__c == 'CheckboxGroup'){
                mappedFieldVO.isCheckboxGroup = true;
                mappedFieldVO.checkboxGroupValues = currentFieldSettings.CheckboxGroupValues__c != null ? currentFieldSettings.CheckboxGroupValues__c : '';
            }
            else if(currentFieldSettings.FieldType__c == 'RadioGroup'){
                mappedFieldVO.isRadioGroup = true;
                mappedFieldVO.radioGroupValues = currentFieldSettings.RadioGroupValues__c != null ? currentFieldSettings.RadioGroupValues__c : '';
            }
            else {
                mappedFieldVO.isDefault = true;         
            }

            resultTaskDetailsVO.add(mappedFieldVO);
        }
        return resultTaskDetailsVO;
    }

    @AuraEnabled(cacheable=false)
    public static List<SObject> getRecordTaskDetails(String taskDetails){
        try {
            List<SObject> recordTaskDetail = new List<SObject>();
            DescribeSObjectResult describeResult = TaskDetails__c.getSObjectType().getDescribe();
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            Id taskDetailsId = taskDetails;
            String query =
            ' SELECT ' +
            String.join( fieldNames, ',' ) +
            ' FROM ' +
            describeResult.getName() +
            ' WHERE Id = :taskDetailsId';
            query = query + ' limit 1';

            recordTaskDetail = Database.query( query );
            return recordTaskDetail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Boolean actionByProfile(String profiles){
        if(String.isBlank(profiles)){
            return false;
        }
        
        List<String> lstProfiles = profiles.split(';');
        
        Id currentProfileId = userinfo.getProfileId();
        String currentProfileName = [SELECT Id, Name FROM Profile WHERE Id =: currentProfileId]?.Name;
        
        return lstProfiles.contains(currentProfileName);
    }    
}