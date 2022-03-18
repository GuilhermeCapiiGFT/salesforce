/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Test class for CustomSetupController
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       17/02/2021      Created     Class creation
 **********************************************************************************************************************/
@isTest
public class CustomSetupTest {

    @TestSetup
    static void makeData(){
        Id recordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', 'AtWork');

        CustomSetup__c cSetup = new CustomSetup__c(RecordTypeId=recordTypeId, Name = 'Test', DateFilter__c = 'CreatedDate');
    
        insert cSetup;

        insert new List<CustomQueue__c>{
            new CustomQueue__c(Name = 'DISCHARGING', ProductType__c = 'DISCHARGING', CustomSetup__c = cSetup.Id, Points__c = 10),
            new CustomQueue__c(
              Name = 'REFINANCING',
              ProductType__c = 'REFINANCING',
              CustomSetup__c = cSetup.Id,
              Points__c = 20
            ),
            new CustomQueue__c(Name = 'STORE', ProductType__c = 'STORE', CustomSetup__c = cSetup.Id, Points__c = 30),
            new CustomQueue__c(
              Name = 'PAYROLL_LOAN',
              ProductType__c = 'PAYROLL_LOAN',
              CustomSetup__c = cSetup.Id,
              Points__c = 40
            ),
            new CustomQueue__c(
              Name = 'SALARY_ADVANCE',
              ProductType__c = 'SALARY_ADVANCE',
              CustomSetup__c = cSetup.Id,
              Points__c = 50
            ),
            new CustomQueue__c(
              Name = 'PENDENCY_RETURN',
              ProductType__c = 'PENDENCY_RETURN',
              CustomSetup__c = cSetup.Id,
              Points__c = 100
            )
          };
    }

    @isTest
    private static void testGetPendencyReturnApiName(){

        String pendencyReturnApiName = CustomSetupController.getPendencyReturnApiName();

        System.assert(String.isNotBlank(pendencyReturnApiName), 'Pendency Return ApiName should have a value');
    }

    @isTest
    private static void testGetCustomSetupByRecordType() {
        
        Test.startTest();

        CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType('AtWork');

        Test.stopTest();

        System.assertNotEquals(null, customSetup, 'Custom Setup shouldn\'t be null.');
        System.assertEquals('Test', customSetup.Name, 'Incorrect Custom Setup Name');
    }

    @IsTest
    private static void testSelectCustomQueues(){
       
        Test.startTest();
        
        List<CustomQueue__c> allQueues = CustomSetupController.selectCustomQueues();

        Test.stopTest();

        System.assertEquals(6, allQueues.size(), 'Expected 6 itens in CustomQueue__c list');
    }
}