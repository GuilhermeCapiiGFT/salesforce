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

  public static void evaluateAtWorkOpportunities(List<CustomQueue__c> lstCustomQueue) {
    List<Opportunity> lstOpportunityToUpdate = getAtWorkOpportunities(lstCustomQueue);
    if (!lstOpportunityToUpdate.isEmpty()) {
      updatePriorityPoints(lstOpportunityToUpdate);
    }
  }

  private static Id opportunityAtWorkRecordTypeId = Util.getRecordTypeIdbyName('Opportunity', 'AtWork');

  private static void setPriorityPoints(List<Opportunity> lOpportunity) {
    CustomSetup__c customSetup = getAtWorkCustomSetup();
    Map<String, Double> mapQueuePoints = createQueuePointsMap(customSetup.CustomQueue__r);

    for (Opportunity opp : lOpportunity) {
      opp.PriorityPoints__c = mapQueuePoints.containsKey(opp.ProductType__c)
        ? mapQueuePoints.get(opp.ProductType__c)
        : 0;
    }
  }

  private static void updatePriorityPoints(List<Opportunity> lOpportunity) {
    List<Opportunity> lOppsToUpdate = new List<Opportunity>();

    CustomSetup__c customSetup = getAtWorkCustomSetup();
    Map<String, Double> mapQueuePoints = createQueuePointsMap(customSetup.CustomQueue__r);

    for (Opportunity opp : lOpportunity) {
      opp.PriorityPoints__c = mapQueuePoints.containsKey(opp.ProductType__c)
        ? mapQueuePoints.get(opp.ProductType__c)
        : 0;
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

  private static List<Opportunity> getAtWorkOpportunities(List<CustomQueue__c> lstCustomQueue) {
    Set<String> setProductType = new Set<String>();
    for (CustomQueue__c cQueue : lstCustomQueue) {
      setProductType.add(cQueue.ProductType__c);
    }

    return [
      SELECT Id, ProductType__c, PriorityPoints__c, RecordTypeId
      FROM Opportunity
      WHERE RecordTypeId = :opportunityAtWorkRecordTypeId AND ProductType__c IN :setProductType
    ];
  }

  private static CustomSetup__c getAtWorkCustomSetup() {
    return [
      SELECT Id, DateFilter__c, (SELECT Id, ProductType__c, Points__c FROM CustomQueue__r)
      FROM CustomSetup__c
      WHERE Name = 'Parametrização de Filas e Usuários'
    ];
  }
}