trigger FinancialResourcesTrigger on FinancialResources__c (before insert, after insert, before update, after update)
{
  new FinancialResourcesTriggerController().run();
}