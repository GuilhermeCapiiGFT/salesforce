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
        return [SELECT Id, Recordtype.DeveloperName FROM Task WHERE Id =: taskId LIMIT 1]?.RecordType.DeveloperName;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getTaskDetails(String taskId) {
        try {
            Map<String, Object> lMapResult = new Map<String, object>();
            Task lTask = [SELECT Id, TaskType__c, TaskDetails__c  FROM task WHERE id = :taskId LIMIT 1];
            String lRecordTypeTask = getRecordType(taskId);
            
            lMapResult.put('Product',lRecordTypeTask); 
            lMapResult.put('TaskType',lTask.TaskType__c); 
    
            if(lTask != null && lRecordTypeTask != null){
                List<TaskDetailsVO> lLstTaskDetailSettingVO = getTaskDetailSettings(lTask.TaskType__c, lRecordTypeTask.toUppercase());
                lMapResult.put('TaskDetailSettings', lLstTaskDetailSettingVO);
                
                if(lTask.TaskDetails__c != null){
                    List<SObject> lRecordTaskDetail = getRecordTaskDetails(lTask.TaskDetails__c);
                    lMapResult.put('TaskDetails', lRecordTaskDetail);
                }
            }
            return lMapResult;
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static void updateRecordTask(String aTaskId, String aTaskDetailsId) {
        try {
            Id lTaskId = aTaskId;
            Id lTaskDetailsId = aTaskDetailsId;
            if(lTaskId != null && lTaskDetailsId != null){
                Task lTask = new Task(Id = lTaskId);
                lTask.TaskDetails__c = lTaskDetailsId;

                update lTask;
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
    public static List<TaskDetailsVO> getTaskDetailSettings(String aTaskType, String aRecordTypeTask) {

        List<TaskDetailsVO> lLstTaskDetailsVO = new List<TaskDetailsVO>();
        
        List<TaskDetailSettings__c> lLstTaskSettings = [
            SELECT Id, Name, CurrencyIsoCode, Product__c, WorkflowKey__c, FieldKey__c, 
                FieldName__c, FieldType__c, RequiredForProfiles__c, ReadOnlyForProfiles__c, 
                RelatedObject__c, NumberPrecision__c, PicklistValues__c, MappedField__c, TaskType__c,
                DisplaySequence__c, FieldMask__c, CheckboxGroupValues__c, RadioGroupValues__c
            FROM TaskDetailSettings__c 
            WHERE TaskType__c = :aTaskType
            AND Product__c = :aRecordTypeTask
            ORDER BY DisplaySequence__c
        ];
            
        for(TaskDetailSettings__c iTaskSettings : lLstTaskSettings){

            TaskDetailsVO lTaskDetailsVO = new TaskDetailsVO();
            
            lTaskDetailsVO.fieldKey       = iTaskSettings.FieldKey__c;
            lTaskDetailsVO.fieldName      = iTaskSettings.FieldName__c;
            lTaskDetailsVO.fieldType      = iTaskSettings.FieldType__c;
            lTaskDetailsVO.Id             = iTaskSettings.id;
            lTaskDetailsVO.fieldMappedKey = iTaskSettings.MappedField__c;
            lTaskDetailsVO.fieldMask      = (iTaskSettings.FieldMask__c != null) ? iTaskSettings.FieldMask__c : '';
            
            
            lTaskDetailsVO.isReadOnly  = actionByProfile(iTaskSettings.ReadOnlyForProfiles__c);
            lTaskDetailsVO.isRequeried = actionByProfile(iTaskSettings.RequiredForProfiles__c);

            if(lTaskDetailsVO.fieldType == 'Currency'){
                lTaskDetailsVO.isCurrency = true;
                lTaskDetailsVO.numberPrecision = (iTaskSettings.NumberPrecision__c != null) ? iTaskSettings.NumberPrecision__c : '0.01';
            } 
            else if(lTaskDetailsVO.fieldType == 'Multi-picklist'){
                lTaskDetailsVO.isMultiPicklist = true;
                lTaskDetailsVO.picklistValues = iTaskSettings.PicklistValues__c != null ? iTaskSettings.PicklistValues__c : '';
            } 
            else if(lTaskDetailsVO.fieldType == 'Picklist'){
                lTaskDetailsVO.isPicklist = true;
                lTaskDetailsVO.picklistValues = iTaskSettings.PicklistValues__c != null ? iTaskSettings.PicklistValues__c : '';
            } 
            else if(lTaskDetailsVO.fieldType == 'Checkbox'){
                lTaskDetailsVO.isCheckbox = true;
            }
            else if(lTaskDetailsVO.fieldType == 'Relationship'){
                lTaskDetailsVO.isRelationship = true;
                lTaskDetailsVO.relatedObject = iTaskSettings.RelatedObject__c;
            }
            else if(lTaskDetailsVO.fieldType == 'Header'){
                lTaskDetailsVO.isHeader = true;
            }            
            else if(lTaskDetailsVO.fieldType == 'Number'){
                lTaskDetailsVO.isNumber = true;
                lTaskDetailsVO.numberPrecision = (iTaskSettings.NumberPrecision__c != null) ? iTaskSettings.NumberPrecision__c : '0';
            }           
            else if(lTaskDetailsVO.fieldType == 'CheckboxGroup'){
                lTaskDetailsVO.isCheckboxGroup = true;
                lTaskDetailsVO.checkboxGroupValues = iTaskSettings.CheckboxGroupValues__c != null ? iTaskSettings.CheckboxGroupValues__c : '';
            }
            else if(lTaskDetailsVO.fieldType == 'RadioGroup'){
                lTaskDetailsVO.isRadioGroup = true;
                lTaskDetailsVO.radioGroupValues = iTaskSettings.RadioGroupValues__c != null ? iTaskSettings.RadioGroupValues__c : '';
            }
            else {
                lTaskDetailsVO.isDefault = true;         
            }

            lLstTaskDetailsVO.add(lTaskDetailsVO);
        }
        return lLstTaskDetailsVO;
    }

    @AuraEnabled(cacheable=false)
    public static List<SObject> getRecordTaskDetails(String aTaskDetails){
        try {
            List<SObject> lRecordTaskDetail = new List<SObject>();
            DescribeSObjectResult describeResult = TaskDetails__c.getSObjectType().getDescribe();
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            Id lTaskDetailsId = aTaskDetails;
            String query =
            ' SELECT ' +
            String.join( fieldNames, ',' ) +
            ' FROM ' +
            describeResult.getName() +
            ' WHERE Id = :lTaskDetailsId';
            query = query + ' limit 1';

            lRecordTaskDetail = Database.query( query );

            return lRecordTaskDetail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=false)
    public static Boolean actionByProfile(String aProfileRequired){
        if(String.isBlank(aProfileRequired)){
            return false;
        }
        
        List<String> lLstProfiles = aProfileRequired.split(';');
        
        Id lCurrentProfileId = userinfo.getProfileId();
        String lCurrentProfileName = [SELECT Id, Name FROM Profile WHERE Id =: lCurrentProfileId]?.Name;
        
        if( lLstProfiles.contains(lCurrentProfileName)){
            return true;
        }
        else{
            return false;
        }
    }    
}