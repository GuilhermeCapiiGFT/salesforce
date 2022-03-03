trigger OpportunityRoleTrigger on OpportunityRole__c (before insert, after insert, before update, after update) 
{
    new OpportunityRoleTriggerController().run();
}