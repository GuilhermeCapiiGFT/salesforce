/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Default Controller for Trigger CustomQueueTrigger
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       16/02/2021      Created     Class creation
 **********************************************************************************************************************/
public with sharing class CustomQueueTriggerController extends TriggerHandler {
  private List<CustomQueue__c> lstNewCustomQueue;
  private List<CustomQueue__c> lstOldCustomQueue;
  private Map<Id, CustomQueue__c> mapNewCustomQueue;
  private Map<Id, CustomQueue__c> mapOldCustomQueue;

  public CustomQueueTriggerController() {
    this.lstNewCustomQueue = (List<CustomQueue__c>) Trigger.new;
    this.lstOldCustomQueue = (List<CustomQueue__c>) Trigger.old;
    this.mapNewCustomQueue = (Map<Id, CustomQueue__c>) Trigger.newMap;
    this.mapOldCustomQueue = (Map<Id, CustomQueue__c>) Trigger.oldMap;
  }

  public override void beforeInsert() {
  }

  public override void afterInsert() {
    OpportunityEvaluationController.evaluateByCustomQueue(lstNewCustomQueue);
  }

  public override void beforeUpdate() {
  }

  public override void afterUpdate() {
    OpportunityEvaluationController.evaluateByCustomQueue(lstNewCustomQueue);
  }

  public override void beforeDelete() {
  }

  public override void afterDelete() {
  }
}