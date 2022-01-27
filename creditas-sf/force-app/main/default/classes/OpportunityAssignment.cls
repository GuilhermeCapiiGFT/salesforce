/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe para atribuição de oportunidades de forma automática
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       25/01/2021      Created     Criação da classe
 **********************************************************************************************************************/
public with sharing class OpportunityAssignment {
  private static Id opportunityAtWorkRecordTypeId = Util.getRecordTypeIdbyName('Opportunity', 'AtWork');

  public static void handleAtWorkOpportunityAssignment(List<Opportunity> lstOpportunity) {
    boolean runAssignment = false;

    for (Opportunity opp : lstOpportunity) {
      if (opp.RecordTypeId == opportunityAtWorkRecordTypeId) {
        runAssignment = true;
        break;
      }
    }

    if (runAssignment) {
      runAtWorkOpportunityAssignment();
    }
  }

  private static void runAtWorkOpportunityAssignment() {
    CustomSetup__c cSetup = EvaluationMethods.getAtWorkCustomSetup();

    List<Opportunity> lstAtWorkOpportunities = EvaluationMethods.getAtWorkOpportunitiesSorted(
      cSetup.CustomQueue__r,
      cSetup.DateFilter__c
    );

    if (cSetup.ProductAssignedUsers__r.isEmpty() || lstAtWorkOpportunities.isEmpty()) {
      return;
    }

    Set<Id> setAllUsers = new Set<Id>();
    Set<Id> setUnavailableUsers = new Set<Id>();

    for (ProductAssignedUser__c prodUser : cSetup.ProductAssignedUsers__r) {
      setAllUsers.add(prodUser.User__c);
      if (!prodUser.User__r.UserAvailable__c) {
        setUnavailableUsers.add(prodUser.User__c);
      }
    }

    for (Opportunity op : lstAtWorkOpportunities) {
      if (setAllUsers.contains(op.OwnerId)) {
        setUnavailableUsers.add(op.OwnerId);
      }
    }

    Map<String, List<Id>> mapUsersByProductType = createMapUsersByProductType(cSetup.ProductAssignedUsers__r);
    List<Opportunity> lstOpptyToAssign = new List<Opportunity>();

    for (Opportunity op : lstAtWorkOpportunities) {
      if (mapUsersByProductType.isEmpty()) {
        break;
      }

      List<Id> lstProductTypeUsers = mapUsersByProductType.get(op.ProductType__c);

      if (lstProductTypeUsers == null || lstProductTypeUsers.isEmpty()) {
        mapUsersByProductType.remove(op.ProductType__c);
        continue;
      }

      Id selectedUserId;

      for (Integer i = 0; i < lstProductTypeUsers.size(); i++) {
        Id userId = lstProductTypeUsers.get(i);

        if (setUnavailableUsers.contains(userId)) {
          continue;
        }

        selectedUserId = userId;
        mapUsersByProductType.get(op.ProductType__c).remove(i);
        break;
      }

      if (selectedUserId != null) {
        op.OwnerId = selectedUserId;
        lstOpptyToAssign.add(op);
        setUnavailableUsers.add(selectedUserId);
      }
    }

    if (lstOpptyToAssign.isEmpty()) {
      return;
    }

    update lstOpptyToAssign;
  }

  private static Map<String, List<Id>> createMapUsersByProductType(List<ProductAssignedUser__c> lstProductUser) {
    Map<String, Set<Id>> mapSetUsersByProductType = new Map<String, Set<Id>>();

    for (ProductAssignedUser__c productUser : lstProductUser) {
      if (mapSetUsersByProductType.containsKey(productUser.ProductType__c)) {
        mapSetUsersByProductType.get(productUser.ProductType__c).add(productUser.User__c);
      } else {
        mapSetUsersByProductType.put(productUser.ProductType__c, new Set<Id>{ productUser.User__c });
      }
    }

    Map<String, List<Id>> mapListUsersByProductType = new Map<String, List<Id>>();

    for (String prodType : mapSetUsersByProductType.keySet()) {
      mapListUsersByProductType.put(prodType, new List<Id>(mapSetUsersByProductType.get(prodType)));
    }

    return mapListUsersByProductType;
  }
}