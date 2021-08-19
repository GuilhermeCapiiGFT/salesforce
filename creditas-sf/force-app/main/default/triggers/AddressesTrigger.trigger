trigger AddressesTrigger on Addresses__c (before insert, after insert, before update, after update)
{
  new AddressesTriggerHandler().run();
}