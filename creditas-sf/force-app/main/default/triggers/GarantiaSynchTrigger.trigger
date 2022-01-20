trigger GarantiaSynchTrigger on Garantias__c (before insert, after insert, before update, after update) 
{
    new GarantiaSynchTriggerHandler().run();
}