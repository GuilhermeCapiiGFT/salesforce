public with sharing class InsertLogUtils {

    public static Boolean insertErrorLog(String endPoint, String requestBody, Integer errorCode, String errorMessage){
        Boolean returnMessage = false;

        API_Transaction_Errors__b ate = new API_Transaction_Errors__b();
        ate.Endpoint__c = endPoint;
        ate.RequestBody__c = requestBody;
        ate.ReturnCode__c = errorCode;
        ate.ErrorMessage__c = errorMessage;
        ate.CreatedDate__c = System.now();
        ate.CreatedBy__c = UserInfo.getUserId();

        if(!Test.isRunningTest()){
            Database.SaveResult sr = database.insertImmediate(ate);
            returnMessage = sr.isSuccess();
        }
        return returnMessage;
    }
}