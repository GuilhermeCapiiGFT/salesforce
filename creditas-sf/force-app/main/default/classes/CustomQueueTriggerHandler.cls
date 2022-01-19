/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto CustomQueue.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Guilherme Sampaio       18/01/2021      Created     Implementação de handler voltado para uso da Trigger do objeto CustomQueue
**********************************************************************************************************************************/
public with sharing class CustomQueueTriggerHandler extends TriggerHandler{

    private List<CustomQueue__c> lstNewCustomQueue;
    private List<CustomQueue__c> lstOldCustomQueue;
    private Map<Id, CustomQueue__c> mapNewCustomQueue;
    private Map<Id, CustomQueue__c> mapOldCustomQueue;

    public CustomQueueTriggerHandler(){
        this.lstNewCustomQueue = (List<CustomQueue__c>) Trigger.new;
        this.lstOldCustomQueue = (List<CustomQueue__c>) Trigger.old;
        this.mapNewCustomQueue = (Map<Id, CustomQueue__c>) Trigger.newMap;
        this.mapOldCustomQueue = (Map<Id, CustomQueue__c>) Trigger.oldMap;
    }

    public override void beforeInsert(){

    }

    public override void afterInsert(){
        
    }

    public override void beforeUpdate(){
        
    }

    public override void afterUpdate(){
        
    }

    public override void beforeDelete(){
        
    }

    public override void afterDelete(){
        
    }

}