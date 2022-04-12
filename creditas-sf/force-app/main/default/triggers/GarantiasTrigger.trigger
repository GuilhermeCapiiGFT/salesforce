trigger GarantiasTrigger on Garantias__c (before insert, after insert, before update, after update) 
{
    new GarantiasTriggerController().run();
}