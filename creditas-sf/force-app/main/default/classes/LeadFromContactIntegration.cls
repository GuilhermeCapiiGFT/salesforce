/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to get a Lead ExternalId from a Lead Contact. 
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          12/01/2022      Created    Class created to get a Lead ExternalId from a Lead Contact.
**********************************************************************************************************************************/

@RestResource(urlMapping='/leads/search/*')
global with sharing class LeadFromContactIntegration{

    @HttpPost
    global static void getLead() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        LeadFromContactIntegrationVO request = (LeadFromContactIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), LeadFromContactIntegrationVO.class);

        if(string.isBlank(request.contact.channel)){
            res.statusCode = 400;  
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize('Error: channel is empty!'));
        }	
                
        if(string.isBlank(request.contact.code)){
            res.statusCode = 400;  
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize('Error: code is empty!'));
        }

        if(string.isBlank(request.contact.type)){
            res.statusCode = 400;  
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize('Error: type is empty!'));            
        }
        
        List<Map<String, String>> listExternalIdMap = new List<Map<String, String>>();
        Map<String, List<Map<String, String>>> mapIdList = new Map<String, List<Map<String, String>>>();
        
        for(LeadCommunicationContact__c contact : [SELECT  Lead__r.ExternalId__c
                                                   FROM    LeadCommunicationContact__c  
                                                   WHERE   ExternalId__c =: request.contact.id AND
                                                           Channel__c    =: request.contact.channel AND
                                                           Code__c       =: request.contact.code AND
                                                           Type__c       =: request.contact.type]){
            Map<String, String> leadExternalId = new Map<String, String>();
            if(contact.Lead__r.ExternalId__c != null){
                leadExternalId.put('Id', contact.Lead__r.ExternalId__c); 
                listExternalIdMap.add(leadExternalId); 
            }
        }

        if(listExternalIdMap.isEmpty()){
            res.statusCode = 400;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize('Error: No Lead was found with the contact provided!'));
        }
        else if (listExternalIdMap.size() > 0){
            res.statusCode = 200;
            mapIdList.put('leadId', listExternalIdMap);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(mapIdList));
        }
        else {
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize('Error: Failed to complete the request.'));
            }
        }
}