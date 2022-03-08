trigger CommunicationContactTrigger on CommunicationContacts__c (before insert, after insert, before update, after update) 
{
  new CommunicationContactTriggerController().run();
}