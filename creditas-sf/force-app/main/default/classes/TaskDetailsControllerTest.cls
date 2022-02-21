@isTest
public class TaskDetailsControllerTest {
    
    private static final Id RECORDTYPE_TASK_AUTOFIN = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AutoFin').getRecordTypeId();
    public static String profiles; 
        
    @testSetup
    public static void createData() {
        
        String lstProfile = getProfiles();
        List<TaskDetailSettings__c> lstTaskDetailSettings = new List<TaskDetailSettings__c>();
        lstTaskDetailSettings.add(createTaskDetailSettings('Text', 1, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Picklist', 2, 'Sim;Não;N/A',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Currency', 3, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Multi-picklist', 4, 'Sim;Não',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Checkbox', 5, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Relationship', 6, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Header', 7, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('Number', 8, '',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('RadioGroup', 9, 'Sim;Não',lstProfile));
        lstTaskDetailSettings.add(createTaskDetailSettings('CheckboxGroup', 10, 'Sim;Não',lstProfile));

        insert lstTaskDetailSettings;

        TaskDetails__c taskDetails = new TaskDetails__c();
		taskDetails.FieldName1__c = 'CPF';
		taskDetails.FieldKey1__c = 'CPF';
		taskDetails.FieldValue1__c = '123.456.789-10';
        insert taskDetails;
        
        Opportunity opportunity = TestSetup.getOpportunity(null, false);
        insert opportunity;
            
        Task task = new Task();
        task.TaskDetails__c = taskDetails.Id;
        task.RecordTypeId = RECORDTYPE_TASK_AUTOFIN;
        task.TaskType__c = 'Formalização - Em análise';
        task.WhatId = opportunity.Id;
        insert task;
    }

    @isTest
    public static void getInfoTask(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        
        Test.startTest();
        Map<String,Object> result = TaskDetailsController.getTaskDetails(task.Id);
        Test.stopTest();
        
        System.assert(result.get('TaskDetailSettings') != null);
        System.assert(result.get('TaskDetails') != null);
    }
    
    @isTest
    public static void updateTaskTest(){
        TaskDetails__c taskDetails = [SELECT Id FROM TaskDetails__c LIMIT 1];
        Task task = new Task();
        insert task;
        
        Test.startTest();
        TaskDetailsController.updateRecordTask(task.Id, taskDetails.Id);
        Test.stopTest();
        
        Task taskResult = [SELECT Id, TaskDetails__c FROM Task WHERE Id =:task.Id LIMIT 1];
        System.assertEquals(taskDetails.Id, taskResult.TaskDetails__c);
    }
    
    @isTest
    public static void getInfoTaskErro(){
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	Map<String,Object> result = TaskDetailsController.getTaskDetails('12345');
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
        Task task = [SELECT Id FROM Task LIMIT 1];
        Opportunity opportunity = new Opportunity();
        Test.startTest();
        opportunity = TaskDetailsController.getOpportunity(task.Id);
        Test.stopTest();
        System.assertNotEquals(null, opportunity.Id);
    }
    
    @isTest
    public static void getTaskSettingsByProfile(){
        
        List<String> lstProfile = getProfiles().split(';');
    	
    	Profile profile = [SELECT Id FROM Profile WHERE Name in :lstProfile LIMIT 1];
        Task task = [SELECT Id FROM Task LIMIT 1];
		Map<String,Object> result = new Map<String,Object>();        
        
        Test.startTest();
        
        User newUser = TestSetup.getUser(true);
		newUser.ProfileId = profile.Id;
        newUser.LastName = 'UsuarioTeste';
		update newUser;
        
        System.runAs(newUser){
        	result = TaskDetailsController.getTaskDetails(task.Id);    
        }
        
        Test.stopTest();
        
        System.assert(result.get('TaskDetailSettings') != null);
        System.assert(result.get('TaskDetails') != null);
    }
    
        
    @isTest
    public static void getTaskSettingsByProfileError(){
        Boolean result = false;
        
        Test.startTest();
        result = TaskDetailsController.actionByProfile('PROFILE1');  
        Test.stopTest();
        
		System.assertEquals(false, result);
    }
    
    @isTest
    public static void getRecordType(){
        Task task = [SELECT ID FROM Task LIMIT 1]; 
        String result = '';
        Test.startTest();
        result = TaskDetailsController.getRecordType(task.Id);  
        Test.stopTest();
        
		System.assert(result != null);
    }
    
    @isTest
    public static void getRecordTypeError(){ 
        Boolean exceptionOccurred = false;
        
        Test.startTest();
        try{
        	TaskDetailsController.getRecordType('123432');  
        }catch(Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionOccurred);
    }
    
    public static TaskDetailSettings__c createTaskDetailSettings(String fieldType,  Integer indexField, String optionValues, String lstProfiels){
        TaskDetailSettings__c taskSettings = new TaskDetailSettings__c();
        taskSettings.Product__c = 'AUTOFIN';
        taskSettings.WorkflowKey__c = 'teste'; 
        taskSettings.DisplaySequence__c = indexField; 
        taskSettings.FieldKey__c = 'test_field'; 
        taskSettings.FieldType__c = fieldType; 
        taskSettings.FieldName__c = 'teste field'; 
        taskSettings.MappedField__c = String.valueOf(indexField);
        taskSettings.TaskType__c = 'Formalização - Em análise';
        taskSettings.PicklistValues__c =  (fieldType == 'Picklist' || fieldType == 'Multi-picklist') ? optionValues : '';
        taskSettings.RadioGroupValues__c = (fieldType == 'RadioGroup') ? optionValues : '';
        taskSettings.CheckboxGroupValues__c = (fieldType == 'CheckboxGroup') ? optionValues : '';
        taskSettings.RequiredForProfiles__c = lstProfiels;
        
        return taskSettings;
    }
    
    public static string getProfiles(){
        Schema.DescribeFieldResult taskTypeDescription = TaskDetailSettings__c.RequiredForProfiles__c.getDescribe();
        List<Schema.PicklistEntry> taskTypePicklistValuesList = taskTypeDescription.getPicklistValues();
     
        String resultProfiles = '';
        for(Schema.PicklistEntry iValue : taskTypePicklistValuesList){
            if(String.isNotBlank(iValue.getValue())){
            	resultProfiles += iValue.getValue() +';';
           }
        }
        return resultProfiles;
    }
}