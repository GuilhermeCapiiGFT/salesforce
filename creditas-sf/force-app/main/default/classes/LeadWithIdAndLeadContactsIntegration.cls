/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update a Lead and Contacts from an API.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/12/2021      Created     Class created to Insert or Update a Lead and Contacts from an API.
**********************************************************************************************************************************/

@RestResource(urlMapping='/lead/upsertLeadId/*')
global with sharing class LeadWithIdAndLeadContactsIntegration{
    
    @HttpPost
    global static String upsertLeadWithId(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        LeadWithIdAndLeadContactsIntegrationVO request = (LeadWithIdAndLeadContactsIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), LeadWithIdAndLeadContactsIntegrationVO.class);
        
        String firstName; 
        String lastName;
        
        List<Lead> lead = new List<Lead>();

        Map<String, LeadCommunicationContact__c> leadContacts = new Map<String, LeadCommunicationContact__c>();
         
        if(string.isBlank(request.leadId)){
			res.statusCode = 400;  
            return 'Error: leadId is empty!';            
        }

        if(string.isBlank(request.fullName)){
			res.statusCode = 400;  
            return 'Error: fullName is empty!';            
        }

        if(request.contacts.isEmpty()){
            res.statusCode = 400;  
            return 'Error: The payload has no contacts!'; 
        }
        
        for(LeadWithIdAndLeadContactsIntegrationVO.Contact ctt : request.contacts){
            
            if(string.isBlank(ctt.channel)){
                res.statusCode = 400;  
                return 'Error: channel is empty!';
            }	
                       
            if(string.isBlank(ctt.code)){
                res.statusCode = 400;  
                return 'Error: code is empty!';
            }

            if(string.isBlank(ctt.type)){
                res.statusCode = 400;  
                return 'Error: type is empty!';
            }
        }
        
        try{
            firstName = request.fullName.substring(0, request.fullName.indexOf(' '));
            lastName = request.fullName.substring(request.fullName.indexOf(' ')+1, request.fullName.length());
        } catch(Exception e){
            res.statusCode = 500;
            return 'Error: Incorrect fullName!';
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
                              
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];

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

                res.statusCode = 200;
                return 'Success: Record created/updated successfully!';

            } catch (Exception e) {
                res.statusCode = 500;
                if(res.statusCode == 500){
                    return 'Error: Failed to complete the request. Please, review the payload.';
                }
                System.debug(e.getMessage());
                return 'Error: Failed to complete the request! ';
            }
    }
    
}