public with sharing class CustomSetupService {
  private static final String PENDENCY_RETURN = 'PENDENCY_RETURN';
  private static final String COMMITTEE = 'COMMITTEE';
  public static Map<String, Map<String, Double>> productPointsByRecordType;

  public static CustomSetup__c selectCustomSetupByRecordType(String filterRecordType) {
    CustomSetup__c resultQuery = [
      SELECT
        Name,
        DateFilter__c,
        RecordTypeId,
        (SELECT QueueName__c, Points__c FROM CustomQueue__r),
        (
          SELECT QueueName__c, User__c, User__r.UserAvailable__c, User__r.LastAttendance__c
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

  public static string getCommitteeApiName() {
    return COMMITTEE;
  }

  public static List<CustomQueue__c> selectCustomQueues() {
    return [SELECT QueueName__c, Points__c, CustomSetup__r.RecordType.DeveloperName FROM CustomQueue__c];
  }

  public static Map<String, Map<String, Double>> getProductPointsByRecordType() {
    productPointsByRecordType = new Map<String, Map<String, Double>>();
    List<CustomQueue__c> customQueues = selectCustomQueues();

    for (CustomQueue__c cQueue : customQueues) {
      String recordTypeName = cQueue.CustomSetup__r.RecordType.DeveloperName;
      String product = cQueue.QueueName__c;
      Double points = cQueue.Points__c;

      if (!productPointsByRecordType.containsKey(recordTypeName)) {
        productPointsByRecordType.put(recordTypeName, new Map<String, Double>());
      }

      productPointsByRecordType.get(recordTypeName).put(product, points);
    }

    return productPointsByRecordType;
  }
}