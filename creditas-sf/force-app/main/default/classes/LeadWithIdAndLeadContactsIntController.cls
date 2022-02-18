/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to receive a HTTP request processed by LeadWithIdAndLeadContactsIntService class
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/12/2021      Created     Controller class for Lead With Id And Lead Contacts Integration
**********************************************************************************************************************************/

@RestResource(urlMapping='/lead/upsertLeadId/*')
global with sharing class LeadWithIdAndLeadContactsIntController{

    @HttpPost
    global static void requisitionLeadWithIdAndLeadContactsIntegration(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        LeadWithIdAndLeadContactsIntegrationVO request = (LeadWithIdAndLeadContactsIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), LeadWithIdAndLeadContactsIntegrationVO.class);
        Map<Integer, String> response  = LeadWithIdAndLeadContactsIntService.upsertLeadId(request);

        for(Integer key : response.keySet()){
            res.statusCode = key;
        }
                
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(response.get(res.statusCode)); 
    }
}