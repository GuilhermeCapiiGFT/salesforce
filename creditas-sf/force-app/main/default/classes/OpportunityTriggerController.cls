/***********************************************************************************************************************************
 * Copyright © 2021 Creditas
 * ================================================================================================================================
 * @description Default Controller for trigger OpportunityTrigger
 * ================================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Nathalia Rosa           17/12/2021      Created     Default Controller for trigger OpportunityTrigger
 * 1.1       Matheus Fernandes       17/02/2021      Changed     Calling OpportunityEvaluationController on beforeInsert
 **********************************************************************************************************************************/
public without sharing class OpportunityTriggerController extends TriggerHandler {
    private List<Opportunity> lstNewOpportunity;
    private List<Opportunity> lstOldOpportunity;
    private Map<Id, Opportunity> mapNewOpportunity;
    private Map<Id, Opportunity> mapOldOpportunity;
  
    public OpportunityTriggerController() {
      this.lstNewOpportunity = (List<Opportunity>) Trigger.new;
      this.lstOldOpportunity = (List<Opportunity>) Trigger.old;
      this.mapNewOpportunity = (Map<Id, Opportunity>) Trigger.newMap;
      this.mapOldOpportunity = (Map<Id, Opportunity>) Trigger.oldMap;
    }
  
    public override void beforeInsert() {
      //OpportunityEvaluationController.evaluateByOpportunity(lstNewOpportunity);
    }
  
    public override void afterInsert() {
      
    }
  
    public override void beforeUpdate() {
      this.updateIsExternallySynced();
      this.firePlatformEventSynchAccount();
    }
  
    public override void afterUpdate() {
      OpportunityAssignmentController.handleAtWorkOpportunityAssignment(lstNewOpportunity);
    }
  
    public static Id getOpportunityRecordTypeId(String recordTypeName) {
      return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }
  
    private void updateIsExternallySynced() {
      String varSObjectApiName = 'Opportunity';
      Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();
  
      for (Custom_Field_Tracking_Map__mdt varCustomTrackedField : [
        SELECT CampoRastreado__r.QualifiedApiName
        FROM Custom_Field_Tracking_Map__mdt
        WHERE ObjetoRastreado__r.QualifiedApiName = :varSObjectApiName
      ]) {
        mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);
      }
  
      for (Opportunity newOpportunity : mapNewOpportunity.values()) {
        Opportunity oldOpportunity = mapOldOpportunity.get(newOpportunity.Id);
  
        for (String trackedField : mapTrackedFields.keySet()) {
          if (
            newOpportunity.get(trackedField) != oldOpportunity.get(trackedField) &&
            newOpportunity.MigrationRecord__c != true
          ) {
            newOpportunity.IsExternallySynched__c = false;
          }
        }
      }
    }
  
    private void firePlatformEventSynchAccount() {
      for (Opportunity newOpportunity : mapNewOpportunity.values()) {
        if (newOpportunity.IsSynchEnabled__c == 'ENABLED') {
          SynchAccount__e synch = new SynchAccount__e();
          DataBase.SaveResult sr = EventBus.publish(synch);
        }
      }
    }
  }