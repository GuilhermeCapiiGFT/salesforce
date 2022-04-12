/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Service methods related to CustomSetup__c object
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       15/02/2021      Created     Class creation
 * 1.0       Guilherme Sampaio       15/02/2021      Created     Class creation
 **********************************************************************************************************************/
public with sharing class CustomSetupService {
  private static final String PENDENCY_RETURN = 'PENDENCY_RETURN';
  public static Map<String, Map<String, Double>> priorityPointsByProduct;

  public static CustomSetup__c selectCustomSetupByRecordType(String filterRecordType) {
    CustomSetup__c resultQuery = [
      SELECT
        Name,
        DateFilter__c,
        RecordTypeId,
        (SELECT ProductType__c, Points__c FROM CustomQueue__r),
        (
          SELECT ProductType__c, User__c, User__r.UserAvailable__c, User__r.LastAttendance__c
          FROM ProductAssignedUsers__r
          ORDER BY User__r.LastAttendance__c ASC
        )
      FROM CustomSetup__c
      WHERE RecordTypeId = :filterRecordType
    ];

    return resultQuery;
  }

  public static string getPendencyReturnApiName() {
    return PENDENCY_RETURN;
  }

  public static List<CustomQueue__c> selectCustomQueues() {
    return [SELECT ProductType__c, Points__c, CustomSetup__r.RecordType.DeveloperName FROM CustomQueue__c];
  }

  public static Map<String, Map<String, Double>> getPriorityPointsByProduct() {
    if (priorityPointsByProduct != null) {
      return priorityPointsByProduct;
    }

    priorityPointsByProduct = new Map<String, Map<String, Double>>();
    List<CustomQueue__c> customQueues = selectCustomQueues();

    for (CustomQueue__c cQueue : customQueues) {
      String recordTypeName = cQueue.CustomSetup__r.RecordType.DeveloperName;
      String product = cQueue.ProductType__c;
      Double points = cQueue.Points__c;

      if (!priorityPointsByProduct.containsKey(recordTypeName)) {
        priorityPointsByProduct.put(recordTypeName, new Map<String, Double>());
      }

      priorityPointsByProduct.get(recordTypeName).put(product, points);
    }

    return priorityPointsByProduct;
  }
}