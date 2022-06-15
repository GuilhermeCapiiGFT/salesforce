public with sharing class OpportunityTriggerService {
  public static void updateIsExternallySynced(
    Map<Id, Opportunity> mapNewOpportunity,
    Map<Id, Opportunity> mapOldOpportunity
  ) {
    String varSObjectApiName = 'Opportunity';
    Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();

    for (Custom_Field_Tracking_Map__mdt varCustomTrackedField : [
      SELECT CampoRastreado__r.QualifiedApiName
      FROM Custom_Field_Tracking_Map__mdt
      WHERE ObjetoRastreado__r.QualifiedApiName = :varSObjectApiName
    ]) {
      mapTrackedFields.put(
        varCustomTrackedField.CampoRastreado__r.QualifiedApiName,
        varCustomTrackedField
      );
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

  public static void firePlatformEventSynchAccount(Map<Id, Opportunity> mapNewOpportunity) {
    for (Opportunity newOpportunity : mapNewOpportunity.values()) {
      if (newOpportunity.IsSynchEnabled__c == 'ENABLED') {
        SynchOpportunity__e synch = new SynchOpportunity__e();
        DataBase.SaveResult sr = EventBus.publish(synch);
        break;
      }
    }
  }

  public static void firePlatformEventAutoFinContractUpdate(Map<Id, Opportunity> mapNewOpportunity) {
    List<AutoFinContractUpdate__e> eventList = new List<AutoFinContractUpdate__e>();
    for (Opportunity newOpportunity : mapNewOpportunity.values()) {
        if (TriggerHelper.changedField(newOpportunity, 'CCBnumber__c')) {
            AutoFinContractUpdate__e event = new AutoFinContractUpdate__e(RecordId__c = newOpportunity.Id);
            eventList.add(event);
        }
    }

    if(eventList.isEmpty()){ return; }
    EventBus.publish(eventList);
  }
}