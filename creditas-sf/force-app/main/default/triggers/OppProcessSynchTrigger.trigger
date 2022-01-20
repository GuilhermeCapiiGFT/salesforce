trigger OppProcessSynchTrigger on OpportunityProcess__c (before insert, after insert, before update, after update) 
{
    new OppProcessSynchTriggerHandler().run();
}