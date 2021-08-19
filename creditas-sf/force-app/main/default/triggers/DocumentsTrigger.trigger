trigger DocumentsTrigger on Documents__c (before insert, after insert, before update, after update)
{
  new DocumentsTriggerHandler().run();
}