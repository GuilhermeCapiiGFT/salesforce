@isTest
private class EmployeeTriggerTest {
  @IsTest
  private static void testUpdateSingle() {
    Employee__c employee = new Employee__c(
      Name = 'Test',
      IsSynchEnabled__c = 'ENABLED',
      IsExternallySynched__c = true,
      Margin__c = 5000
    );

    insert employee;

    employee.Margin__c = 6000;

    Test.startTest();

    update employee;

    Test.stopTest();

    Boolean isExternallySynched = [SELECT Margin__c, IsExternallySynched__c FROM Employee__c].IsExternallySynched__c;

    Set<String> trackedFieds = new Set<String>(Util.returnCustomMetadaDataFieldApiName('Employee__c'));

    if (trackedFieds.contains('Margin__c')) {
      System.assertEquals(false, isExternallySynched, 'IsExternallySynched field value should be \'false\'');
    } else {
      System.assertEquals(true, isExternallySynched, 'IsExternallySynched field value should be \'true\'');
    }
  }

  @IsTest
  private static void testUpdateBulk() {
    List<Employee__c> employees = new List<Employee__c>();

    for (Integer i = 1; i <= 200; i++) {
      employees.add(
        new Employee__c(Name = 'Test', IsSynchEnabled__c = 'ENABLED', IsExternallySynched__c = true, Margin__c = 5000)
      );
    }

    insert employees;

    for (Employee__c employee : employees) {
      employee.Margin__c = 6000;
    }

    Test.startTest();

    update employees;

    Test.stopTest();

    employees = [SELECT Margin__c, IsExternallySynched__c FROM Employee__c];

    Set<String> trackedFieds = new Set<String>(Util.returnCustomMetadaDataFieldApiName('Employee__c'));

    System.assertEquals(200, employees.size(), 'There should be 200 records');

    for (Employee__c employee : employees) {
      System.assertEquals(6000, employee.Margin__c, 'Margin__c field value should be \'6000\'');

      if (trackedFieds.contains('Margin__c')) {
        System.assertEquals(
          false,
          employee.IsExternallySynched__c,
          'IsExternallySynched__c field value should be \'false\''
        );
      } else {
        System.assertEquals(
          true,
          employee.IsExternallySynched__c,
          'IsExternallySynched__c field value should be \'true\''
        );
      }
    }
  }
}