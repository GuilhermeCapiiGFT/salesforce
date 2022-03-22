@isTest
private class SynchEmployeeDataControllerTest {
  @TestSetup
  static void makeData() {
    insert new Employee__c(Name = 'Test');
    insert new Account(Name = 'Test');
  }

  @IsTest
  private static void testUpdateSynchingFieldsSuccess() {
    Id employeeId = [SELECT Id FROM Employee__c].Id;

    Test.startTest();

    SynchEmployeeDataController.updateSynchingFields(employeeId);

    Test.stopTest();

    Employee__c employee = [SELECT IsSynchEnabled__c, IsExternallySynched__c FROM Employee__c];

    System.assertEquals('SYNCHING', employee.IsSynchEnabled__c, 'Incorrect field value');
    System.assertEquals(false, employee.IsExternallySynched__c, 'Incorrect field value');
  }

  @IsTest
  private static void testUpdateSynchingFieldsFail() {
    Id employeeId = [SELECT Id FROM Account].Id;
    Exception testException;

    try {
      Test.startTest();

      SynchEmployeeDataController.updateSynchingFields(employeeId);

      Test.stopTest();
    } catch (Exception e) {
      testException = e;
    }

    System.assertNotEquals(null, testException, 'An exception should\'ve been thrown');
    System.assertEquals(
      'System.AuraHandledException',
      testException.getTypeName(),
      'An AuraHandledException should\'ve been thrown'
    );
    System.assertEquals(
      'System.TypeException',
      testException.getCause().getTypeName(),
      'A TypeException should\'ve been the cause'
    );
  }
}