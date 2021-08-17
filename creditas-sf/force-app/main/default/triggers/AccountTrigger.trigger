trigger AccountTrigger on Account (before insert, after insert, before update, after update)
{
  new AccountTriggerHandler().run();
}