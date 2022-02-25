/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Controller class that calls the methods of the MinuatorSearchService class
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           02/02/2022      Created      Controller class that calls the methods of the MinuatorSearchService  
*************************************************************************************************************************************/
public with sharing class MinuatorSearchController {    
    @AuraEnabled
    public static MinuatorSearchResponse getLead(String friendlyId){
        return MinuatorSearchService.getLead(friendlyId);        
    }    
    @AuraEnabled
    public static String getAccessToken(){
        return MinuatorSearchService.getAccessToken();        
    }   
}