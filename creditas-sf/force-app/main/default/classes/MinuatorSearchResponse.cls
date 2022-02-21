/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Class to test the methods created by the Minuator SearchService class
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           04/02/2022      Created      Class to test the methods created by the Minuator SearchService class  
*************************************************************************************************************************************/
public class MinuatorSearchResponse {
    @AuraEnabled public Boolean error;
    @AuraEnabled public Integer statusCode;
    @AuraEnabled public MinuatorSearchVO infos;
    @AuraEnabled public String message;
    @AuraEnabled public String errorCode;
    
    
}