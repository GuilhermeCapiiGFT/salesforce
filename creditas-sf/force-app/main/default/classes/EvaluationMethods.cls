/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Priorização de oportunidades de AtWork
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       18/01/2021      Created     Criação da classe para priorização de oportunidades de AtWork
 **********************************************************************************************************************/
public with sharing class EvaluationMethods {
  private static Id opportunityAtWorkRecordTypeId = Util.getRecordTypeIdbyName('Opportunity', 'AtWork');
  private static final String PENDENCY_RETURN = 'PENDENCY_RETURN';

  public static void evaluateAtWorkOpportunities(List<Opportunity> lstOpportunity) {
    List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();

    for (Opportunity opp : lstOpportunity) {
      if (opp.RecordTypeId == opportunityAtWorkRecordTypeId) {
        lstOpportunityToUpdate.add(opp);
      }
    }

    if (!lstOpportunityToUpdate.isEmpty()) {
      setPriorityPoints(lstOpportunityToUpdate);
    }
  }

  private static void setPriorityPoints(List<Opportunity> lstNewOpportunity) {
    CustomSetup__c customSetup = getAtWorkCustomSetup();
    Map<String, Double> mapQueuePoints = createQueuePointsMap(customSetup.CustomQueue__r);

    for (Opportunity opp : lstNewOpportunity) {
      opp.PriorityPoints__c = mapQueuePoints.containsKey(opp.ProductType__c)
        ? mapQueuePoints.get(opp.ProductType__c)
        : 0;
      if (opp.PendencyReturn__c) {
        opp.PriorityPoints__c += mapQueuePoints.get(PENDENCY_RETURN);
      }
    }
  }

  public static void evaluateAtWorkOpportunities(List<CustomQueue__c> lstCustomQueue) {
    List<Opportunity> lstOpportunityToUpdate = getAtWorkOpportunities(lstCustomQueue);
    if (!lstOpportunityToUpdate.isEmpty()) {
      updatePriorityPoints(lstOpportunityToUpdate);
    }
  }

  private static void updatePriorityPoints(List<Opportunity> lstNewOpportunity) {
    List<Opportunity> lOppsToUpdate = new List<Opportunity>();

    CustomSetup__c customSetup = getAtWorkCustomSetup();
    Map<String, Double> mapQueuePoints = createQueuePointsMap(customSetup.CustomQueue__r);

    for (Opportunity opp : lstNewOpportunity) {
      opp.PriorityPoints__c = mapQueuePoints.containsKey(opp.ProductType__c)
        ? mapQueuePoints.get(opp.ProductType__c)
        : 0;
      if (opp.PendencyReturn__c) {
        opp.PriorityPoints__c += mapQueuePoints.get(PENDENCY_RETURN);
      }
      lOppsToUpdate.add(opp);
    }

    update lOppsToUpdate;
  }

  private static Map<String, Double> createQueuePointsMap(List<CustomQueue__c> lCustomQueue) {
    Map<String, Double> mapQueuePoints = new Map<String, Double>();
    for (CustomQueue__c cQueue : lCustomQueue) {
      mapQueuePoints.put(cQueue.ProductType__c, cQueue.Points__c);
    }

    return mapQueuePoints;
  }

  public static List<Opportunity> getAtWorkOpportunities(List<CustomQueue__c> lstCustomQueue) {
    boolean hasPendencyReturn = false;
    Set<String> setProductType = new Set<String>();

    for (CustomQueue__c cQueue : lstCustomQueue) {
      setProductType.add(cQueue.ProductType__c);
      if (cQueue.ProductType__c == PENDENCY_RETURN) {
        hasPendencyReturn = true;
      }
    }

    if (hasPendencyReturn) {
      return [
        SELECT
          Id,
          Name,
          ProductType__c,
          PriorityPoints__c,
          RecordTypeId,
          PendencyReturn__c,
          CreatedDate,
          ExternalCreationDate__c,
          OwnerId
        FROM Opportunity
        WHERE
          RecordTypeId = :opportunityAtWorkRecordTypeId
          AND (PendencyReturn__c = TRUE
          OR ProductType__c IN :setProductType)
          AND StageName <> 'Perdido'
      ];
    } else {
      return [
        SELECT
          Id,
          Name,
          ProductType__c,
          PriorityPoints__c,
          RecordTypeId,
          PendencyReturn__c,
          CreatedDate,
          ExternalCreationDate__c,
          OwnerId
        FROM Opportunity
        WHERE RecordTypeId = :opportunityAtWorkRecordTypeId 
        AND ProductType__c IN :setProductType
        AND StageName <> 'Perdido'
      ];
    }
  }

  public static List<Opportunity> getAtWorkOpportunitiesSorted(List<CustomQueue__c> lstCustomQueue, String dateFilter) {
    List<Opportunity> lstOpportunity = getAtWorkOpportunities(lstCustomQueue);
    List<Opportunity> lstOpportunitySorted = new List<Opportunity>();

    if (!lstOpportunity.isEmpty()) {
      List<OpportunityAtWorkComparable> lstOpptyComp = new List<OpportunityAtWorkComparable>();

      for (Opportunity opp : lstOpportunity) {
        lstOpptyComp.add(new OpportunityAtWorkComparable(opp, dateFilter));
      }

      lstOpptyComp.sort();

      for (OpportunityAtWorkComparable oppComp : lstOpptyComp) {
        lstOpportunitySorted.add(oppComp.oppty);
      }
    }

    return lstOpportunitySorted;
  }

  public static CustomSetup__c getAtWorkCustomSetup() {
    return [
      SELECT
        DateFilter__c,
        (SELECT ProductType__c, Points__c FROM CustomQueue__r),
        (SELECT ProductType__c, User__c, User__r.UserAvailable__c FROM ProductAssignedUsers__r)
      FROM CustomSetup__c
      WHERE Name = 'Parametrização de Filas e Usuários'
    ];
  }
}