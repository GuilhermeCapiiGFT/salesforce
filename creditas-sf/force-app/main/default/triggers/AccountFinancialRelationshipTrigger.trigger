trigger AccountFinancialRelationshipTrigger on AccountFinancialRelationship__c (before insert, after insert, before update, after update) 
{
    new AccFinancialRelationshipTriggerHandler().run();
}