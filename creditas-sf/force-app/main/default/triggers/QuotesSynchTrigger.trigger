trigger QuotesSynchTrigger on Quote (before insert, after insert, before update, after update) 
{
    new QuotesSynchTriggerHandler().run();

}