public with sharing class EmployeeTriggerService {
  public static void firePlatformEventSynchEmployee(List<Employee__c> employees) {
    List<SynchEmployee__e> events = new List<SynchEmployee__e>();
    for (Employee__c employee : employees) {
      if (employee.IsSynchEnabled__c == 'ENABLED') {
        SynchEmployee__e synch = new SynchEmployee__e();
        events.add(synch);
      }
    }

    Eventbus.publish(events);
  }

  public static void updateExternallySynced(List<Employee__c> employees) {
    List<String> trackedFields = Util.returnCustomMetadaDataFieldApiName('Employee__c');
    for (Employee__c employee : employees) {
      if (TriggerHelper.changedField(employee, trackedFields)) {
        employee.IsExternallySynched__c = false;
      }
    }
  }
}