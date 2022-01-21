@isTest
public class TaskDetailsControllerTest {
    
    private static final Id RECORDTYPE_TASK_AUTOFIN = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AutoFin').getRecordTypeId();
    
    @testSetup
    public static void createData() {
        
        /*Schema.DescribeFieldResult taskTypeDescription = Task.TaskType__c.getDescribe();
		List<Schema.PicklistEntry> taskTypePicklistValuesList = taskTypeDescription.getPicklistValues();*/
        
        List<TaskDetailSettings__c> lLstTaskDetailSettings = new List<TaskDetailSettings__c>();
        
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 1, 'AFcpf', 'Text', '1', 'Formalização - Em análise', '','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 2, 'AFsalario', 'Currency', '2', 'Formalização - Em análise', '','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 3, 'AFampanhacomercial', 'Multi-picklist', '3', 'Formalização - Em análise', 'Sim;Não','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 4, 'AFoperacaoIQ', 'Picklist', '4', 'Formalização - Em análise', 'Sim;Não','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 5, 'AFisActive', 'Checkbox', '5', 'Formalização - Em análise','','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 6, 'AFconta', 'Relationship', '6', 'Formalização - Em análise','','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 7, 'AFtext', 'Header', '7', 'Formalização - Em análise','','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 8, 'AFnumber', 'Number', '8', 'Formalização - Em análise','','',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 9, 'AFconta', 'RadioGroup', '9', 'Formalização - Em análise','','Sim;Não',''));
        lLstTaskDetailSettings.add(createTaskDetailSettings('AUTOFIN', 'Teste', 10, 'AFconta', 'CheckboxGroup', '10', 'Formalização - Em análise','','','Sim;Não'));

        insert lLstTaskDetailSettings;

        TaskDetails__c lTaskDetails = new TaskDetails__c();
		lTaskDetails.FieldName1__c = 'CPF';
		lTaskDetails.FieldKey1__c = 'CPF';
		lTaskDetails.FieldValue1__c = '123.456.789-10';
        insert lTaskDetails;

        Opportunity lOpportunity = TestSetup.getOpportunity(null, false);
        insert lOpportunity;
            
        Task lTask = new Task();
        lTask.TaskDetails__c = lTaskDetails.Id;
        lTask.RecordTypeId = RECORDTYPE_TASK_AUTOFIN;
        lTask.TaskType__c = 'Formalização - Em análise';
        lTask.WhatId = lOpportunity.Id;
        insert lTask;
    }

    @isTest
    public static void getInfoTask(){
        Task lTask = [SELECT Id FROM Task LIMIT 1];
        
        Test.startTest();
        Map<String,Object> lresult = TaskDetailsController.getTaskDetails(lTask.Id);
        Test.stopTest();
        
        System.assert(lresult.get('TaskDetailSettings') != null);
        System.assert(lresult.get('TaskDetails') != null);
    }
    
    @isTest
    public static void updateTaskTest(){
        TaskDetails__c lTaskDetails = [SELECT Id FROM TaskDetails__c LIMIT 1];
        Task lTask = new Task();
        insert lTask;
        
        Test.startTest();
        TaskDetailsController.updateRecordTask(lTask.Id, lTaskDetails.Id);
        Test.stopTest();
        
        Task lTaskResult = [SELECT Id, TaskDetails__c FROM Task WHERE Id =:lTask.Id LIMIT 1];
        System.assertEquals(lTaskDetails.Id, lTaskResult.TaskDetails__c);
    }
    
    @isTest
    public static void getInfoTaskErro(){
        Task lTask = [SELECT Id FROM Task LIMIT 1];
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	Map<String,Object> lresult = TaskDetailsController.getTaskDetails('12345');
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
    
    @isTest
    public static void updateTaskTestErro(){
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	TaskDetailsController.updateRecordTask('12345', '1234');
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
    
    @isTest
    public static void getRecordTaskDetailsErro(){
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	TaskDetailsController.getRecordTaskDetails('12345');
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
    
    @isTest
    public static void getOpportunityTest(){
        Task lTask = [SELECT Id FROM Task LIMIT 1];
        Test.startTest();
        	TaskDetailsController.getOpportunity(lTask.Id);
        Test.stopTest();
    }
    public static TaskDetailSettings__c createTaskDetailSettings(String aProduct, String aWorkflow, Integer aDisplaySequence, String aFieldKey,  String aFieldType,  String aMappedField,  String aTaskType, String aPicklistValues, String aRadioGroupValues, String aCheckboxGroupValues){
        TaskDetailSettings__c lTaskSettings = new TaskDetailSettings__c();
        lTaskSettings.Product__c = aProduct;
        lTaskSettings.WorkflowKey__c = aWorkflow; 
        lTaskSettings.DisplaySequence__c = aDisplaySequence; 
        lTaskSettings.FieldKey__c = aFieldKey; 
        lTaskSettings.FieldType__c = aFieldType; 
        lTaskSettings.FieldName__c = aWorkflow; 
        lTaskSettings.MappedField__c = aMappedField;
        lTaskSettings.TaskType__c = aTaskType;
        lTaskSettings.PicklistValues__c = aPicklistValues;
        lTaskSettings.RadioGroupValues__c = aRadioGroupValues;
        lTaskSettings.CheckboxGroupValues__c = aCheckboxGroupValues;
        
        return lTaskSettings;
    }
}