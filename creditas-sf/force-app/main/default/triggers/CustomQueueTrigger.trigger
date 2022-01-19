trigger CustomQueueTrigger on CustomQueue__c (before insert, after insert, before update, after update, before delete, after delete) {

new CustomQueueTriggerHandler().run();

}