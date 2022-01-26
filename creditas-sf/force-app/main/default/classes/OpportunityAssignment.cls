public with sharing class OpportunityAssignment {
  public static void assignAtWorkOpportunities() {
    CustomSetup__c cSetup = EvaluationMethods.getAtWorkCustomSetup();

    if (cSetup.ProductAssignedUsers__r.isEmpty()) {
      return;
    }

    Set<Id> allUsers = new Set<Id>();

    for (ProductAssignedUser__c prodUser : cSetup.ProductAssignedUsers__r) {
      allUsers.add(prodUser.User__c);
    }

    List<Opportunity> lstAtWorkOpportunities = EvaluationMethods.getAtWorkOpportunitiesSorted(
      cSetup.CustomQueue__r,
      cSetup.DateFilter__c
    );

    if (lstAtWorkOpportunities.isEmpty()) {
      return;
    }

    Map<String, List<Id>> mapUsersByProductType = createMapUsersByProductType(cSetup.ProductAssignedUsers__r);

    List<Opportunity> lstOpptyToAssign = new List<Opportunity>();
    Set<Id> setAssignedUsers = new Set<Id>();

    for (Opportunity op : lstAtWorkOpportunities) {
      if (mapUsersByProductType.isEmpty()) {
        break;
      }

      if (allUsers.contains(op.OwnerId)) {
        setAssignedUsers.add(op.OwnerId);
        continue;
      }

      List<Id> lstUserId = mapUsersByProductType.get(op.ProductType__c);

      if (lstUserId == null || lstUserId.isEmpty()) {
        mapUsersByProductType.remove(op.ProductType__c);
        continue;
      }

      Id userId = mapUsersByProductType.get(op.ProductType__c).remove(0);
      if (setAssignedUsers.contains(userId)) {
        continue;
      }

      op.OwnerId = userId;
      lstOpptyToAssign.add(op);

      setAssignedUsers.add(userId);
    }

    if (lstOpptyToAssign.isEmpty()) {
      return;
    }

    update lstOpptyToAssign;
  }

  static Map<String, List<Id>> createMapUsersByProductType(
    List<ProductAssignedUser__c> lstProductUser
  ) {

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