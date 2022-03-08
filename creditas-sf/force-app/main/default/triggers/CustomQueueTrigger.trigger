/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Trigger on CustomQueue__c
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Guilherme Sampaio                       Created     Trigger creation
 * 1.1       Matheus Fernandes       16/02/2021      Changed     Now calling CustomQueueTriggerController
 **********************************************************************************************************************/
trigger CustomQueueTrigger on CustomQueue__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  new CustomQueueTriggerController().run();

}
