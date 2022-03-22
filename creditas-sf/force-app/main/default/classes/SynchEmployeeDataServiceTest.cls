@isTest
private class SynchEmployeeDataServiceTest {
  @TestSetup
  static void makeData() {
    insert new Employee__c(Name = 'Test');
    insert new Account(Name = 'Test');
  }

  @IsTest
  private static void testUpdateSynchingFieldsSuccess() {
    Id employeeId = [SELECT Id FROM Employee__c].Id;

    Test.startTest();

    SynchEmployeeDataService.updateSynchingFields(employeeId);

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

      SynchEmployeeDataService.updateSynchingFields(employeeId);

      Test.stopTest();
    } catch (TypeException e) {
      testException = e;
    }

    System.assertNotEquals(null, testException, 'A TypeException should\'ve been thrown');
  }
}