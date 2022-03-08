/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test Class to LeadFromContactIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          12/01/2022      Created     Test Class to LeadFromContactIntegration Class.
**********************************************************************************************************************************/

@isTest
public with sharing class LeadFromContactIntegrationTest{

	static testMethod void foundLead() {
    	String json= '  { '+ 
		'   "contact": '+ 
        '   {   '+
        '   "id": "L001", '+
        '   "channel": "Email", '+
        '   "code": "maria.neves@gmail.com", '+
        '   "type": "COMERCIAL" '+
        '   } '+
        '	} ';
        
		Test.startTest();

            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
              
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;
            newLead.ExternalId__c       = 'L001';            
            newLead.FirstName	        = 'Maria';
            newLead.LastName            = 'Das Neves';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678911';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c	= '--';
            insert newLead;
          
            Lead idLead = [SELECT Id FROM Lead];
          
            LeadCommunicationContact__c newContact = new LeadCommunicationContact__c();
          
            newContact.ExternalId__c	= 'L001';
            newContact.Channel__c       = 'Email';
            newContact.Code__c          = 'maria.neves@gmail.com';
            newContact.Type__c          = 'COMERCIAL';
            newContact.Lead__c	        = idLead.Id;
            insert newContact;
        
            LeadFromContactIntegrationVO VO = new LeadFromContactIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/services/leads/search';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            LeadFromContactIntegration.getLead();  
            System.assertequals(200, res.statusCode, 'One or more leadId related to the informed Contact must be returned.');
        
		Test.stopTest();   
	}

	static testMethod void leadNotFound(){
        String json= '  { '+ 
        '   "contact": '+ 
        '   {   '+
        '   "id": "", '+
        '   "channel": "Email", '+
        '   "code": "maria.neves@gmail.com", '+
        '   "type": "COMERCIAL" '+
        '   } '+
        '	} ';
    
		Test.startTest();
        
        	RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];

            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;
            newLead.ExternalId__c       = 'L001';            
            newLead.FirstName	        = 'Maria';
            newLead.LastName            = 'Das Neves';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678911';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c	= '--';
            insert newLead;
      
            Lead idLead = [SELECT Id FROM Lead];
          
            LeadCommunicationContact__c newContact = new LeadCommunicationContact__c();
          
            newContact.ExternalId__c	= 'L001';
            newContact.Channel__c       = 'Email';
            newContact.Code__c          = 'maria.neves@gmail.com';
            newContact.Type__c          = 'COMERCIAL';
            newContact.Lead__c	        = idLead.Id;
            insert newContact;
    
			LeadFromContactIntegrationVO VO = new LeadFromContactIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                  
            req.requestURI = '/services/leads/search';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
    
            LeadFromContactIntegration.getLead();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as a Lead related to the informed Contact was not found.');

		Test.stopTest();   
	}

   
	static testMethod void contactWithoutChannel(){        
        String json= '  { '+ 
        '   "contact": '+ 
        '   {   '+
        '   "id": "0010", '+
        '   "channel": "", '+
        '   "code": "erika.t@gmail.com", '+
        '   "type": "COMERCIAL" '+
        '   } '+
        '	} ';
        
        Test.startTest();
    
            LeadFromContactIntegrationVO VO = new LeadFromContactIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                  
            req.requestURI = '/services/leads/search';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
                
            LeadFromContactIntegration.getLead();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the Channel was not informed.');
    
		Test.stopTest();   
	} 
    
    static testMethod void contactWithoutCode(){        
        String json= '  { '+ 
        '   "contact": '+ 
        '   {   '+
        '   "id": "0010", '+
        '   "channel": "Email", '+
        '   "code": "", '+
        '   "type": "COMERCIAL" '+
        '   } '+
        '	} ';
        
        Test.startTest();
    
            LeadFromContactIntegrationVO VO = new LeadFromContactIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                  
            req.requestURI = '/services/leads/search';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
                
            LeadFromContactIntegration.getLead();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the Code was not informed.');
    
        Test.stopTest();   
	}  

    static testMethod void contactWithoutType(){        
        String json= '  { '+ 
        '   "contact": '+ 
        '   {   '+
        '   "id": "0010", '+
        '   "channel": "Email", '+
        '   "code": "erika.t@gmail.com", '+
        '   "type": "" '+
        '   } '+
        '	} ';
        
        Test.startTest();
    
            LeadFromContactIntegrationVO VO = new LeadFromContactIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                  
            req.requestURI = '/services/leads/search';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
                
            LeadFromContactIntegration.getLead();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the Type was not informed.');
    
        Test.stopTest();   
	} 

}