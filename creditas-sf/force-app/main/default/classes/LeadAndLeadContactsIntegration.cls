/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update an Lead and Contacts from an API.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          14/12/2021      Created     Class created to Insert or Update an Lead and Contacts from an API.
**********************************************************************************************************************************/

@RestResource(urlMapping='/lead/*')
global with sharing class LeadAndLeadContactsIntegration{
    
    @HttpPost
    global static String upsertLead(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        LeadAndLeadContactsIntegrationVO request = (LeadAndLeadContactsIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), LeadAndLeadContactsIntegrationVO.class);
        
        List<Lead> lead = new List<Lead>();

        List<String> codes = new List<String>();

        Map<String, LeadCommunicationContact__c> leadContacts = new Map<String, LeadCommunicationContact__c>();
       
		      
        if(string.isBlank(request.fullName)){
			res.statusCode = 400;  
            return 'Error: fullName is empty!';            
        }

        if(request.contacts.isEmpty()){
            res.statusCode = 400;  
            return 'Error: The payload has no contacts!'; 
        }
        
        for(LeadAndLeadContactsIntegrationVO.Contact ctt : request.contacts){
            
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
            
            codes.add(ctt.code);
        }
        

        Id leadId;
        for(LeadCommunicationContact__c theContact : [SELECT    ExternalId__c,
                                                                Channel__c,
                                                                Code__c,
                                                                Type__c,
                                                                Lead__c,
                                                                Lead__r.auxLeadName__c 
													  FROM LeadCommunicationContact__c  
                                                      WHERE Lead__r.auxLeadName__c = :request.fullName AND Code__c IN :codes]){ 
            leadId = theContact.Lead__c;              
            leadContacts.put(theContact.Lead__r.auxLeadName__c+theContact.Code__c, theContact);
        }
                        
        if(leadId != null){

            lead = [SELECT  RecordTypeId, 
                        	FirstName, 
                        	LastName,            
                        	DocumentType__c,
                        	CPF__c, 
                        	Company,
                        	mainDocumentCode__c
                FROM Lead
                WHERE Id =: leadId];
        
            lead[0].DocumentType__c        = request.mainDocument.type;
			lead[0].CPF__c                 = request.mainDocument.code;
            lead[0].Company                = string.isBlank(request.company.businessName) ? '--' : request.company.businessName;
            lead[0].mainDocumentCode__c	   = string.isBlank(request.company.mainDocumentCode) ? '--' : request.company.mainDocumentCode;
            
        }else{
            
            String firstName; 
            String lastName;
            
            try{
                firstName = request.fullName.substring(0, request.fullName.indexOf(' '));
                lastName = request.fullName.substring(request.fullName.indexOf(' ')+1, request.fullName.length());
            } catch(Exception e){
                res.statusCode = 500;
                return 'Error: Incorrect fullName!';
            }
         	
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];

            Lead newLead = new Lead();
            
            newLead.RecordTypeId        = recordTypeLead.Id;
            newLead.FirstName	        = firstName;
            newLead.LastName            = lastName;
            newLead.DocumentType__c     = request.mainDocument.type;
			newLead.CPF__c              = request.mainDocument.code;
            newLead.Company             = string.isBlank(request.company.businessName) ? '--' : request.company.businessName;
            newLead.mainDocumentCode__c	= string.isBlank(request.company.mainDocumentCode) ? '--' : request.company.mainDocumentCode;
            
            lead.add(newLead);                          
        }
	        try {
                upsert lead;

                List<LeadCommunicationContact__c> cttToInsert = new List<LeadCommunicationContact__c>();

                for(LeadAndLeadContactsIntegrationVO.Contact newCtt : request.contacts){

                    LeadCommunicationContact__c theContact = leadContacts.get(request.fullName+newCtt.code);

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
                return 'Error: Failed to complete the request!';
            }
    }
    
}