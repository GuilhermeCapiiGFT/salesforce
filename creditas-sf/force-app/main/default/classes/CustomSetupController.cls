public with sharing class CustomSetupController {

  public static String getPendencyReturnApiName() {
    return CustomSetupService.PENDENCY_RETURN;
  }

  public static CustomSetup__c getCustomSetupByRecordType(String recordTypeDevName){
    String customSetupRecordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', recordTypeDevName);
    return CustomSetupService.selectCustomSetups(customSetupRecordTypeId)[0];
  }

  public static List<CustomQueue__c> selectCustomQueues(){
    return CustomSetupService.selectCustomQueues();
  }

  public static List<CustomQueue__c> selectCustomQueues(Set<Id> customQueueIds){
    return CustomSetupService.selectCustomQueues(customQueueIds);
  }
}