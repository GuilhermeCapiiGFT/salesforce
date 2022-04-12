trigger OpportunityProcessTrigger on OpportunityProcess__c (before insert, after insert, before update, after update) 
{
    new OpportunityProcessTriggerController().run();
}