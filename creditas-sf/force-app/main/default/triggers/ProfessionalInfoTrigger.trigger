trigger ProfessionalInfoTrigger on ProfessionalInfo__c (before insert, after insert, before update, after update)
{
  new ProfessionalInfoTriggerHandler().run();
}