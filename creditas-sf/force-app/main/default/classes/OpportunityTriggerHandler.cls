/***********************************************************************************************************************************
 * Copyright © 2021 Creditas
 * ================================================================================================================================
 * @description Handler padrão para a trigger do botão sincronizar do Objeto Opportunity.
 * ================================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Nathalia Rosa           17/12/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Opportunity
 **********************************************************************************************************************************/
public without sharing class OpportunityTriggerHandler extends TriggerHandler {
  private List<Opportunity> lstNewOpportunity;
  private List<Opportunity> lstOldOpportunity;
  private Map<Id, Opportunity> mapNewOpportunity;
  private Map<Id, Opportunity> mapOldOpportunity;

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description Construtor
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0
   **********************************************************************************************************************************/
  public OpportunityTriggerHandler() {
    this.lstNewOpportunity = (List<Opportunity>) Trigger.new;
    this.lstOldOpportunity = (List<Opportunity>) Trigger.old;
    this.mapNewOpportunity = (Map<Id, Opportunity>) Trigger.newMap;
    this.mapOldOpportunity = (Map<Id, Opportunity>) Trigger.oldMap;
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description Método contextualizado before insert
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0
   **********************************************************************************************************************************/
  public override void beforeInsert() {
    //EvaluationMethods.evaluateAtWorkOpportunities(lstNewOpportunity);
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description Método contextualizado after insert
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0
   **********************************************************************************************************************************/
  public override void afterInsert() {
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description Método contextualizado before update
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0
   **********************************************************************************************************************************/
  public override void beforeUpdate() {
    this.updateIsExternallySynced();
    this.firePlatformEventSynchAccount();
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description Método contextualizado after update
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0
   **********************************************************************************************************************************/
  public override void afterUpdate() {
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description pegar id do tipo de registro
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0         Nathalia Rosa           17/12/2021
   **********************************************************************************************************************************/
  public static Id getOpportunityRecordTypeId(String recordTypeName) {
    return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
  }

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description verificar se os campos rastreados mudaram de valor
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0         Nathalia Rosa           17/12/2021
   **********************************************************************************************************************************/
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

  /**********************************************************************************************************************************
   * ================================================================================================================================
   * @description disparar o evento de plataforma quando a oportunidade for sincronizada
   * ================================================================================================================================
   * History
   * -------
   * VERSION     AUTHOR                  DATE            DETAIL      Description
   * 1.0         Nathalia Rosa          17/12/2021
   **********************************************************************************************************************************/
  private void firePlatformEventSynchAccount() {
    for (Opportunity newOpportunity : mapNewOpportunity.values()) {
      if (newOpportunity.IsSynchEnabled__c == 'ENABLED') {
        SynchAccount__e synch = new SynchAccount__e();
        DataBase.SaveResult sr = EventBus.publish(synch);
      }
    }
  }
}