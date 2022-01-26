@isTest
Global class OpportunityServiceTest {
    @TestSetup
    static void makeData(){
        Account participant = new Account();
        participant.Name = 'Test';
        participant.ExternalId__c = 'PER-A74F103F-AE7E-43A6-BA3F-172023B54AFA';      
        insert participant;
        
        Opportunity loan = new Opportunity();
        loan.Name = 'Teste';
        loan.StageName = 'New';
        loan.CloseDate = Date.today().addDays(10);
        loan.ExternalId__c = 'LAP-2211F221-FF13-47ED-B097-4FE93E33712E';
        insert loan;
        
        OpportunityRole__c proponent = new OpportunityRole__c();
        proponent.ExternalPersonId__c = participant.Id;
        proponent.Opportunity__c = loan.Id;
        insert proponent;
    }
    
    @isTest
    static void testUpsertOpportunitySucess(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(opportunityMock('success'));
        	RestContext.request = req;
        	RestContext.response= res;            
            OpportunityService.putMethod();          
        Test.stopTest();
        
        List<Opportunity> createdOpp = [SELECT Id FROM Opportunity];
        System.assertEquals(1, createdOpp.Size(),'Opportunity successfully inserted.');
        
        List<Quote> createdQuote = [SELECT Id FROM Quote];
        System.assertEquals(1, createdQuote.Size(),'Quote successfully inserted.');
        
        List<OpportunityRole__c> createdOppRole = [SELECT Id FROM OpportunityRole__c];
        System.assertEquals(1, createdOppRole.Size(),'Opp Role successfully inserted.');
        
		system.assertEquals(res.statusCode, 200, 'Opportunity successfully inserted.');   
    }   
 
    @isTest
    static void testProponentNotFound(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(opportunityMock('proponentNotFound'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		System.assertEquals(reqResString, '{"status":500,"opportunityId":null,"message":"Proponent not found in Salesforce"}');   
    } 
    
    @isTest
    static void testParseError(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof('x');
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 500,'Invalid string for JSON format.');   
    } 

    @isTest
    static void testNullParticipantsError(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(opportunityMock('nullParticipant'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 500,'Participant cannot be null.');   
    } 
    
    @isTest
    static void testOpportunityDmlError(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(opportunityMock('opportunityDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 500,'DML error inserting opportunity.');   
    }   
    
    @isTest
    static void testOpportunityRoleDmlError(){              
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(opportunityMock('proponentDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 500,'DML error inserting Opportunity Role.');   
    } 
    
    static String opportunityMock(String param){
        String participantExternalId = param == 'proponentNotFound' ? '"id":"FAKE_ID_TO_GET_ERROR",' : '"id":"PER-A74F103F-AE7E-43A6-BA3F-172023B54AFA",'; 
        String tenant = param == 'opportunityDmlError' ? '"tenant": "erro",' : '"tenant": "creditasbr",';
        String role = param == 'proponentDmlError' ? '"ERRO"' : '"PRINCIPAL"';
        String participants = param == 'nullParticipant' ? '"participants": null,'
            : '    "participants":['+
            '       {'+
            '          "roles":['+
            role+
            '          ],'+
            '          "person":{'+
            participantExternalId+
            '             "version":4'+
            '          }'+
            '       }'+
            '   ],';
        String json=		'{'+
		''+
		'    "conditions":{'+
		'       "installments":{'+
		'          "value":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":25000'+
		'          },'+
		'          "type":"FIXED",'+
		'          "term":12,'+
		'          "firstDueDate":"2020-02-20",'+
		'          "lastDueDate":"2021-01-20"'+
		'       },'+
		'       "interest":{'+
		'          "monthly":0.0159,'+
		'        '+
		'          "yearly":0.5231'+
		'       },'+
		'       "cet":{'+
		'          "daily":0.0007966283053657541,'+
		'          "monthly":0.024176971037231043,'+
		'          "yearly":0.3373012296403381'+
		'       },'+
		'       "parameters":{'+
		'          "collateralValue":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":25000'+
		'          },'+
		'          "requestedAmount":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":25000'+
		'          },'+
		'          "tac":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":2'+
		'          },'+
		'          "iof":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":100'+
		'          },'+
		'          "additionalCosts":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":200'+
		'          },'+
		'          "term":180,'+
		'          "uf":"AM",'+
		'          "creditScore":800,'+
		'          "gracePeriod":90,'+
		'          "contractDate":"2020-02-10",'+
		'          "calculatorVersion":3'+
		'       },'+
		'       "limitData":{'+
		'          "cetLimit":{'+
		'             "maximum":10,'+
		'             "minimum":0.00950000001'+
		'          },'+
		'          "interest":{'+
		''+
		'             "yearlyLimit":{ '+
		'                "maximum":24,'+
		'                "minimum":0'+
		'             },'+
		'             "monthlyLimit":{'+
		'                "maximum":2,'+
		'                "minimum":0'+
		'             }'+
		'          },'+
		'          "total":{'+
		'             "currencyCode":"BRL",'+
		'             "amount":25000'+
		'          },'+
		'          "installmentType":"FIXED",'+
		'          "dueDate":"2020-02-10"'+
		'        },'+
		'       "depositAccount":{'+
		'          "bankCode":"341",'+
		'          "branch":"38976",'+
		'          "number":"897650",'+
		'          "bankAccountType":"CHECKINGS"'+
		'       },'+
		'       "monthlyInterestRateComposition":['+
		'          {'+
		'             "type":"base",'+
		'             "value":0.015'+
		'          }'+
		'       ],'+
		'       "netValues":{'+
		'          "currencyCode":"BRL",'+
		'          "amount":25000'+
		'       },'+
		'       "step":"CREDIT_ANALYSIS"'+
		'    },'+
		'    "partner":{'+
		'       "id":"21b0f42e-f27d-4696-9cfe-2f4258e31164"'+
		'    },'+
		participants+
		'    "collaterals": ['+
		'        {'+
		'            "type":"ASSET",'+
		'             "id":"f0e55377-0133-4bfe-8cc2-a9819df6cc92",'+
		'             "version":10'+
		'        },'+
		'        {'+
		'             "type":"LIMIT",'+
		'             "id":"f0e55377-0133-4bfe-8cc2-a9819df6cc92"'+
		'         }'+
		'    ],'+
		'    "status":"ONGOING",'+
		'    "productType":"HOME_REFIN",'+
		'    "purpose":"OTHERS",'+
		'    "id": "LAP-2211F221-FF13-47ED-B097-4FE93E33712E",'+
		'    "version": "7",'+
		tenant+
		'    "createdAt": "2021-08-16T14:09:42.206Z",'+
		'    "updateAt": "2021-08-16T23:40:11.362Z"'+
		' }';
        return json;
    }  
}