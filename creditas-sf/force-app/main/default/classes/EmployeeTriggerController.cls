public with sharing class EmployeeTriggerController extends TriggerHandler {
  private List<Employee__c> newEmployees;
  private List<Employee__c> oldEmployees;
  private Map<Id, Employee__c> newEmployeesById;
  private Map<Id, Employee__c> oldEmployeesById;

  public EmployeeTriggerController() {
    this.newEmployees = (List<Employee__c>) Trigger.new;
    this.oldEmployees = (List<Employee__c>) Trigger.old;
    this.newEmployeesById = (Map<Id, Employee__c>) Trigger.newMap;
    this.oldEmployeesById = (Map<Id, Employee__c>) Trigger.oldMap;
  }

  public override void beforeUpdate() {
    EmployeeTriggerService.updateExternallySynced(this.newEmployees);
  }

  public override void afterUpdate() {
    EmployeeTriggerService.firePlatformEventSynchEmployee(this.newEmployees);
  }
}