public with sharing class CustomSetupController {
  public static String getPendencyReturnApiName() {
    return CustomSetupService.getPendencyReturnApiName();
  }
  
  public static String getCommitteeApiName() {
    return CustomSetupService.getCommitteeApiName();
  }

  public static CustomSetup__c getCustomSetupByRecordType(String recordTypeDevName) {
    String customSetupRecordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', recordTypeDevName);
    return CustomSetupService.selectCustomSetupByRecordType(customSetupRecordTypeId);
  }

  public static List<CustomQueue__c> selectCustomQueues() {
    return CustomSetupService.selectCustomQueues();
  }

  public static Map<String, Map<String, Double>> getProductPointsByRecordType() {
    return CustomSetupService.getProductPointsByRecordType();
  }
}