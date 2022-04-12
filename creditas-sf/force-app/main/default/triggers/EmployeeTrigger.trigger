trigger EmployeeTrigger on Employee__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
    new EmployeeTriggerController().run();
}