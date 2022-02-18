/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created for validate the Business Rules and Insert or Update a Lead and Contacts from an API.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/12/2021      Created     Service class for Lead With Id And Lead Contacts Integration
**********************************************************************************************************************************/

public with sharing class LeadWithIdAndLeadContactsIntService{
    
    public static Map<Integer, String> upsertLeadId(LeadWithIdAndLeadContactsIntegrationVO request){
              
        String firstName; 
        String lastName;
        List<Lead> lead = new List<Lead>();
        Map<Integer, String> resultMap = new Map<Integer, String>();
        Map<String, LeadCommunicationContact__c> leadContacts = new Map<String, LeadCommunicationContact__c>();
         
        if(string.isBlank(request.leadId)){
            resultMap.put(400,'Error: leadId is empty!'); 
            return resultMap;                            
        }
      
        if(string.isBlank(request.fullName)){
            resultMap.put(400,'Error: fullName is empty!'); 
            return resultMap;      
        }


        if(request.contacts.isEmpty()){
            resultMap.put(400,'Error: The payload has no contacts!'); 
            return resultMap;  
        }
        
        for(LeadWithIdAndLeadContactsIntegrationVO.Contact ctt : request.contacts){
            
            if(string.isBlank(ctt.channel)){
                resultMap.put(400,'Error: channel is empty!'); 
                return resultMap;  
            }	
                       
            if(string.isBlank(ctt.code)){
                resultMap.put(400,'Error: code is empty!'); 
                return resultMap;  
            }

            if(string.isBlank(ctt.type)){
                resultMap.put(400,'Error: type is empty!'); 
                return resultMap;  
            }
        }
        
        try{
            firstName = request.fullName.substring(0, request.fullName.indexOf(' '));
            lastName = request.fullName.substring(request.fullName.indexOf(' ')+1, request.fullName.length());
        } catch(Exception e){
            resultMap.put(400,'Error: Incorrect fullName!'); 
            return resultMap;
        }
                  
        lead = [SELECT 	RecordTypeId, 
                        FirstName, 
                        LastName,            
                        DocumentType__c,
                        CPF__c, 
                        Company,
                        mainDocumentCode__c,
                        ExternalId__c
                FROM Lead
                WHERE ExternalId__c =: request.leadId];

        if(!lead.isEmpty()){
                    
            for(LeadCommunicationContact__c theContact : [SELECT    ExternalId__c,
                                                                    Channel__c,
                                                                    Code__c,
                                                                    Type__c,
                                                                    Lead__c, 
                                                                    Lead__r.ExternalId__c
                                                        FROM LeadCommunicationContact__c  
                                                        WHERE Lead__c =:lead[0].id]){
                leadContacts.put(theContact.Lead__r.ExternalId__c+theContact.Code__c, theContact);
            }
                    
            lead[0].FirstName       	   = firstName; 
            lead[0].LastName         	   = lastName;
            lead[0].DocumentType__c        = request.mainDocument.type;
            lead[0].CPF__c                 = request.mainDocument.code;
            lead[0].Company                = string.isBlank(request.company.businessName) ? '--' : request.company.businessName;
            lead[0].mainDocumentCode__c	   = string.isBlank(request.company.mainDocumentCode) ? '--' : request.company.mainDocumentCode;
            
        }else{
                            
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE DeveloperName = 'Auto' AND SobjectType = 'Lead'];

            Lead newLead = new Lead();
            
            newLead.RecordTypeId        = recordTypeLead.Id;
            newLead.FirstName	        = firstName;
            newLead.LastName            = lastName;
            newLead.ExternalId__c       = request.leadId;
            newLead.DocumentType__c     = request.mainDocument.type;
            newLead.CPF__c              = request.mainDocument.code;
            newLead.Company             = string.isBlank(request.company.businessName) ? '--' : request.company.businessName;
            newLead.mainDocumentCode__c	= string.isBlank(request.company.mainDocumentCode) ? '--' : request.company.mainDocumentCode;
            
            lead.add(newLead);                          
        }
        try {
            upsert lead;

            List<LeadCommunicationContact__c> cttToInsert = new List<LeadCommunicationContact__c>();

            for(LeadWithIdAndLeadContactsIntegrationVO.Contact newCtt : request.contacts){

                LeadCommunicationContact__c theContact = leadContacts.get(request.leadId+newCtt.code);

                if(theContact == null){
                    theContact = new LeadCommunicationContact__c(Lead__c = lead[0].Id);
                }                       

                theContact.ExternalId__c       = newCtt.id;
                theContact.Channel__c          = newCtt.channel;
                theContact.Code__c             = newCtt.code;
                theContact.Type__c             = newCtt.type;
                cttToInsert.add(theContact);
            }

            if(cttToInsert.size() > 0){
                upsert cttToInsert;
            } 

            resultMap.put(200,'Success: Record created/updated successfully!'); 
            return resultMap;

        } catch (Exception e) {
            System.debug(e.getMessage());   
            resultMap.put(500,'Error: Failed to complete the request. Please, review the payload.'); 
            return resultMap;
        }      
    }      
}