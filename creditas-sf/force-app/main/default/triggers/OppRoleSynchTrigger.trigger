trigger OppRoleSynchTrigger on OpportunityRole__c (before insert, after insert, before update, after update) 
{
    new OppRoleSynchTriggerHandler().run();
}