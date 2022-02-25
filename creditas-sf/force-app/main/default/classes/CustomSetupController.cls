/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Controller class for CustomSetup__c object related functions 
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       17/02/2021      Created     Class creation
 **********************************************************************************************************************/
public with sharing class CustomSetupController {

  public static String getPendencyReturnApiName() {
    return CustomSetupService.getPendencyReturnApiName();
  }

  public static CustomSetup__c getCustomSetupByRecordType(String recordTypeDevName){
    String customSetupRecordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', recordTypeDevName);
    return CustomSetupService.selectCustomSetupByRecordType(customSetupRecordTypeId);
  }

  public static List<CustomQueue__c> selectCustomQueues(){
    return CustomSetupService.selectCustomQueues();
  }
}