public with sharing class SynchEmployeeDataService {
  public static void updateSynchingFields(Id employeeId) {
    update new Employee__c(Id = employeeId, IsSynchEnabled__c = 'SYNCHING', IsExternallySynched__c = false);
  }
}