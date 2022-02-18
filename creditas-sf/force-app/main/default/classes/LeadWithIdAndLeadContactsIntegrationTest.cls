/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test Class for Lead With Id And Lead Contacts Integration
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/12/2021      Created     Test Class for Lead With Id And Lead Contacts Integration
**********************************************************************************************************************************/

@isTest
public with sharing class LeadWithIdAndLeadContactsIntegrationTest{

    static testMethod void insertLeadAndContacts(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+    
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":""	'+
        '   },	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest(); 

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();   

        Test.stopTest();   

        System.assertEquals(200, res.statusCode, 'A Lead and Lead Contacts should be inserted.');
        System.assertEquals(res.responseBody.toString(), 'Success: Record created/updated successfully!'); 
    } 

    static testMethod void updateLeadAndContacts(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +  
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678920"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();    

        RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE DeveloperName  = 'Auto' AND SobjectType = 'Lead'];
                
        Lead newLead = new Lead();
        newLead.RecordTypeId        = recordTypeLead.Id;            
        newLead.FirstName	        = 'Flávia';
        newLead.LastName            = 'Rodrigues dos Santos';
        newLead.ExternalId__c       = 'id-12345010-124124';
        newLead.DocumentType__c     = 'CPF';
        newLead.CPF__c              = '12345678910';
        newLead.Company             = '--';
        newLead.mainDocumentCode__c = '--';
        insert newLead;
                
        Lead idLead = [SELECT Id FROM Lead];
                
        LeadCommunicationContact__c newContact = new LeadCommunicationContact__c();
                
        newContact.ExternalId__c	= '';
        newContact.Channel__c		= 'Email';
        newContact.Code__c			= 'gft.fsantos@creditas.com';
        newContact.Type__c			= 'COMERCIAL';
        newContact.Lead__c			= idLead.Id;
        insert newContact;
        
        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();

        Test.stopTest();   

        System.assertEquals(200, res.statusCode, 'A Lead and Lead Contacts should be updated.');  
        System.assertEquals(res.responseBody.toString(), 'Success: Record created/updated successfully!'); 
    } 
        
    static testMethod void insertLeadWithoutId(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"", '+    
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":""	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();       

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();   

        Test.stopTest();   

        System.assertEquals(400, res.statusCode, 'An error should have occurred, as the leadId was not informed.');
        System.assertEquals(res.responseBody.toString(), 'Error: leadId is empty!'); 
    } 
        
    static testMethod void insertLeadWithoutFullName(){
        String json= '{	'+ 
        '	"fullName":"",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();        

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();   

        Test.stopTest();   

        System.assertEquals(400, res.statusCode, 'An error should have occurred, as the fullName was not informed.');
        System.assertEquals(res.responseBody.toString(), 'Error: fullName is empty!'); 
    }  
        
    static testMethod void insertLeadWithoutContacts(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();     

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();   

        Test.stopTest();   

        System.assertEquals(400, res.statusCode, 'An error should have occurred, as no Lead Contact was informed.');
        System.assertEquals(res.responseBody.toString(), 'Error: The payload has no contacts!'); 
    }    
        
    static testMethod void insertLeadWithoutChannel(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();    

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();    

        Test.stopTest();
        
        System.assertEquals(400, res.statusCode, 'An error should have occurred, as a Channel was not informed.');
        System.assertEquals(res.responseBody.toString(), 'Error: channel is empty!'); 
    }  
        
    static testMethod void insertLeadWithoutCode(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();        

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration(); 

        Test.stopTest();   

        System.assertEquals(400, res.statusCode, 'An error should have occurred, as a Code was not informed.'); 
        System.assertEquals(res.responseBody.toString(), 'Error: code is empty!'); 
    }  
        
    static testMethod void insertLeadWithoutType(){
        String json= '{	'+ 
        '	"fullName":"Flávia Rodrigues dos Santos",	'+
        '	"leadId":"id-12345010-124124", '+ 
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":"--"	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "11999998882",'+
        '	"type": ""'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();        

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();     

        Test.stopTest();  
        
        System.assertEquals(400, res.statusCode, 'An error should have occurred, as a Type was not informed.');
        System.assertEquals(res.responseBody.toString(), 'Error: type is empty!');   
    }  
        
    static testMethod void insertLeadWithIncompleteName(){
        String json= '{	'+ 
        '	"fullName":"Flávia",    '+
        '	"leadId":"id-12345010-124124", '+    
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":""	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();
        
        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();     

        Test.stopTest(); 
        
        System.assertEquals(400, res.statusCode, 'An error should have occurred, as the fullName is incomplete.');
        System.assertEquals(res.responseBody.toString(), 'Error: Incorrect fullName!'); 
    }    
        
    static testMethod void insertLeadWithPayloadError(){
        String json= '{	'+ 
        '	"fullName":"Flávia ",	'+
        '	"leadId":"id-12345010-124124", '+    
        '	"company":{	'+
        '	"businessName":"--", '+
        '	"mainDocumentCode":""	'+
        '	},	'+
        '   "contacts": [	'+
        '	{	'+
        '	"id": "",	'+
        '	"channel": "Email",	'+
        '	"code": "gft.fsantos@creditas.com", '+
        '	"type": "COMERCIAL" '+
        '   },'+
        '	{'+
        '	"id": "",'+
        '	"channel": "WHATSAPP",'+
        '	"code": "(11) 98765-4321",'+
        '	"type": "PERSONAL"'+
        '	}	' +           
        '	],	'+
        '	"mainDocument": {	'+
        '	"type": "CPF",	'+
        '	"code": "12345678910"	'+
        '	}	'+
        '	}	';
        
        Test.startTest();    

        LeadWithIdAndLeadContactsIntegrationVO VO = new LeadWithIdAndLeadContactsIntegrationVO();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/lead/upsertLeadId';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;             
        
        LeadWithIdAndLeadContactsIntController.requisitionLeadWithIdAndLeadContactsIntegration();   

        Test.stopTest();   

        System.assertEquals(500, res.statusCode, 'An error should have occurred, as the payload has an error.');
        System.assertEquals(res.responseBody.toString(), 'Error: Failed to complete the request. Please, review the payload.'); 
    }      
}