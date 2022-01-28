/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test Class to DealAndLeadIntegrationClass.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          20/01/2022      Created     Test Class to DealAndLeadIntegrationClass.
**********************************************************************************************************************************/

@istest
public class DealAndLeadIntegrationTest {

    static testMethod void insertDealAndProductOfInterest(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSales' AND SobjectType = 'Product2'];
           
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     			
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                   
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id; 
        	newLead.Status	        	= 'New';
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'cred123';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;
            	
			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/cred123/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(200, res.statusCode, 'A deal and the Products of Interest should be inserted.');    
        Test.stopTest();  
    }

    static testMethod void updatetDealAndInterestProduct(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+     
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;

                 
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

            Lead lead = [SELECT Id, FirstName, LastName FROM Lead WHERE ExternalId__c = 'EID-12345'];
            Group queue = [SELECT Id FROM Group WHERE Name = 'Creditas Auto - Vendas' AND Type = 'Queue'];     
            RecordType recordTypeDeal = [SELECT id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Deal__c'];
           
            Deal__c newDeal = new Deal__c();
            newDeal.Name            = 'Comprar carro - '+ lead.FirstName + ' '+ lead.LastName;
            newDeal.RecordType      = recordTypeDeal;
            newDeal.DealValue__c    =  12345.12;
            newDeal.CurrencyIsoCode = 'BRL'; 
            newDeal.LeadOrigin__c   = 'CREDITAS';
            newDeal.UTM_Campaign__c = '[creditas-auto][search][institucional][cliques]';
            newDeal.UTM_source__c   = 'google';
            newDeal.UTM_Media__c    = 'cpc';
            newDeal.Priority__c     = 2;
            newDeal.ExternalId__c   = 'DE-001';
            newDeal.OwnerId         = queue.Id;
            newDeal.Lead__c         = lead.Id;
            insert newDeal;

            RecordType recordTypeProdInt = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'ProductOfInterest__c'];
            Product2 prodId = [SELECT Id FROM Product2 WHERE ExternalId = 'ID12301239'];
            Deal__c dealId = [SELECT Id FROM  Deal__c WHERE ExternalId__c = 'DE-001'];

            ProductOfInterest__c interestProd = new ProductOfInterest__c();
            interestProd.Deal__c            = dealId.Id;
            interestProd.Name               = 'Chevrolet Onix 2021';
            interestProd.recordtype         = recordTypeProdInt; 
            interestProd.productId__c       = prodId.id;
            interestProd.productType__c     = 'Creditas Auto Buyer'; 
            interestProd.Product__c         = prodId.Id;
            insert interestProd;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(200, res.statusCode, 'A deal should be updated.');    
        Test.stopTest();
    } 
    
    static testMethod void invalidLeadExternalId(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-1234/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the leadId is not correct.');    
        Test.stopTest();  
    }

    static testMethod void withoutDealId(){
        String json= '   { '+
        '   "dealId":"",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the dealId was not informed.');    
        Test.stopTest();  
    }

    static testMethod void withoutAmount(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"",   '+     
        '   "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the amount was not informed.');    
        Test.stopTest();  
    }

    static testMethod void withoutCurrency(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":""   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+ 
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the currency was not informed.');    
        Test.stopTest();  
    }

    static testMethod void incorrectCurrency(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":"BR"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+   
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;
        
			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the currency informed does not exist.');    
        Test.stopTest();  
    }

    static testMethod void withoutSource(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   ';

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the source was not informed.');    
        Test.stopTest();  
    }

    static testMethod void withoutUTMSource(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   ';

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the UTM_Source was not informed.');    
        Test.stopTest();  
    }

    static testMethod void withoutUTMMedium(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+       
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   ';

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the UTM_Medium was not informed.');    
        Test.stopTest();  
    }

    static testMethod void withoutUTMCampaign(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '   "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   ';

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the UTM_Campaign was not informed.');    
        Test.stopTest();  
    }


    static testMethod void withoutProductOfInterest() {
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest":   '+
        '   [   '+ 
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as a Product of Interest was not informed.' );    
        Test.stopTest();  
    }

    static testMethod void productOfInterestwithoutProductId() {
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "",   '+     
        '   "quantity": 1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;
    
			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the productId of the Product of Interest was not informed.');    
        Test.stopTest();  
    }

    static testMethod void productOfInterestwithoutQuantity(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity": null,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;
                  

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the quantity of the Product of Interest was not informed or was incorrect.');    
        Test.stopTest();  
    }

    static testMethod void productOfInterestwithoutProductType(){
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "ID12301239",   '+     
        '   "quantity": 1,   '+     
        '   "productType":""   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the productType of the Product of Interest was not informed.');    
        Test.stopTest();  
    }

    static testMethod void productIdNotFound() {
        String json= '   { '+
        '   "dealId":"DE-001",  '+    
        '   "totalValue":{   '+     
        '   "amount":"12345,1234",   '+     
        '    "currencyIsoCode":"BRL"   '+    
        '   },   '+     
        '   "source":"CREDITAS_AUTO",   '+     
        '   "UTM_source":"google",   '+     
        '   "UTM_Medium":"cpc",   '+     
        '   "UTM_Campaign":"[creditas-auto][search][institucional][cliques]",   '+ 
        '   "priority":111,   '+     
        '   "productsOfInterest": [  '+  
        '   {   '+     
        '   "ProductId" : "IDABC",   '+     
        '   "quantity":1,   '+     
        '   "productType":"Creditas Auto Buyer"   '+ 
        '   }   '+    
        '   ]   '+     
        '   }   '; 

        Test.startTest();  
        
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
            
            Product2 newproduct         = new Product2();
            newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
            newProduct.productType__c   = 'Creditas Auto Buyer';
            newProduct.CurrencyIsoCode	= 'BRL';
            insert newproduct;
     
            RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'];
                    
            Lead newLead = new Lead();
            newLead.RecordTypeId        = recordTypeLead.Id;            
            newLead.FirstName	        = 'Jane';
            newLead.LastName            = 'Doe';
            newLead.ExternalId__c       = 'EID-12345';
            newLead.DocumentType__c     = 'CPF';
            newLead.CPF__c              = '12345678910';
            newLead.Company             = '--';
            newLead.mainDocumentCode__c = '--';
            insert newLead;

			DealAndLeadIntegrationVO VO = new DealAndLeadIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/leads/EID-12345/deal';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            DealAndLeadIntegration.upsertDeal();  
            System.assertequals(400, res.statusCode, 'An error should occur, as a Product with the productId informed was not found.');    
        Test.stopTest();  
    }
}