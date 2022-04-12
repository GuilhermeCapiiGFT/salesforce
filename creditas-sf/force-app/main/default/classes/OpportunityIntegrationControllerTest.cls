@isTest
public with sharing class OpportunityIntegrationControllerTest {

    @TestSetup
    static void makeData(){
        Account acc = AccountSetup.createAccount('Joaozinho', 'Pessoa_Fisica');
        acc.ExternalId__c = 'papirus';
        insert acc;
    }

    @isTest
    private static void testInsertSuccessAtWork(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('success','PAYROLL/PAYROLL_LOAN/REFINANCING','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
        
		System.assertEquals(res.statusCode, 200, 'Expected 200');

        System.assertEquals(1, [SELECT Count() FROM Opportunity],'Opportunity failed to be inserted.');

		System.assertEquals('Novo', [SELECT StageName FROM Opportunity]?.StageName,'Opportunity stage should be Novo');
        
        System.assertEquals(1, [SELECT Count() FROM Quote],'Quote failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM OpportunityRole__c],'Opp Role failed to be inserted.');
        
    }

	@isTest
    private static void testUpdateSuccessAtWork(){
		RestRequest reqInsert = new RestRequest(); 
		RestResponse resInsert = new RestResponse();      
		reqInsert.requestURI = '/services/apexrest/IntegrationOpportunity'; 
		reqInsert.httpMethod = 'PUT';
		reqInsert.requestBody = Blob.valueof(payloadMock('success','PAYROLL/PAYROLL_LOAN/REFINANCING','PENDING_SIGNATURE',null));
		RestContext.request = reqInsert;
		RestContext.response = resInsert;            
		OpportunityIntegrationController.putMethod();
		Opportunity atWorkOpp = [SELECT StageName FROM Opportunity];
		atWorkOpp.StageName = 'Aprovado por RH';
		TriggerHandler.bypass('OpportunityTriggerController');
		update atWorkOpp;
		TriggerHandler.clearAllBypasses();
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('success','PAYROLL/PAYROLL_LOAN/REFINANCING','PENDING_HR',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
        
		System.assertEquals(res.statusCode, 200, 'Expected 200');

        System.assertEquals(1, [SELECT Count() FROM Opportunity],'Only 1 opportunity should exist.');

		System.assertEquals('Aprovado por RH', [SELECT StageName FROM Opportunity]?.StageName,'Opportunity failed to be updated.');
        
        System.assertEquals(1, [SELECT Count() FROM Quote],'Quote failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM OpportunityRole__c],'Opp Role failed to be inserted.');
        
    }

	@isTest
    private static void testUpsertSuccessHome(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('success','HOME_REFIN','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
        
		System.assertEquals(res.statusCode, 200, 'Expected 200');

        System.assertEquals(1, [SELECT Count() FROM Opportunity],'Opportunity failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM Quote],'Quote failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM OpportunityRole__c],'Opp Role failed to be inserted.');
        
    }

	@isTest
    private static void testUpsertSuccessAutoFin(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('success','AUTO_FIN','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();

		System.assertEquals(res.statusCode, 200, 'Expected 200');
		
        System.assertEquals(1, [SELECT Count() FROM Opportunity],'Opportunity failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM Quote],'Quote failed to be inserted.');
        
        System.assertEquals(1, [SELECT Count() FROM OpportunityRole__c],'Opp Role failed to be inserted.');
        
    }

    @isTest
    private static void testPayloadParseError(){
        Test.startTest();
			String payloadError = '{"conditions":{"parameters":{"creditscore":800.4}}}';
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadError);
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
                
		System.assertEquals(res.statusCode, 500, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('{"statusCode":500,"opportunityId":null,"message":"Payload parse Error."}', responseBodyString, 'Wrong messageBody');
    }

	@isTest
    private static void testParticipantsEmpty(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('nullParticipant','PAYROLL/SALARY_ADVANCE','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
                
		System.assertEquals(res.statusCode, 500, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('{"statusCode":500,"opportunityId":null,"message":"No participants found."}', responseBodyString, 'Wrong messageBody');
    }

	@isTest
    private static void testProponentNotFound(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('proponentNotFound','PAYROLL/SALARY_ADVANCE','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
                
		System.assertEquals(res.statusCode, 500, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals('{"statusCode":500,"opportunityId":null,"message":"Proponent not found in Salesforce."}', responseBodyString, 'Wrong messageBody');
    }

	@isTest
    private static void testOppDmlError(){
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(payloadMock('opportunityDmlError','PAYROLL/SALARY_ADVANCE','PENDING_SIGNATURE',null));
        	RestContext.request = req;
        	RestContext.response = res;            
            OpportunityIntegrationController.putMethod();          
        Test.stopTest();
                
		System.assertEquals(res.statusCode, 500, 'Expected 500');
        String responseBodyString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		//we don't validate a fixed respons message here because it is dynamic based on the error thrown
        System.assert(String.isNotBlank(responseBodyString),'response body should not be blank');
    }

    /* OPTIONS FOR productType IN THE PAYLOAD JSON
	HOME_REFIN
	AUTO_FIN
    PAYROLL/SALARY_ADVANCE -> Antecipação
    PAYROLL/PAYROLL_LOAN -> Payroll
    PAYROLL/STORE -> Store
    PAYROLL/PAYROLL_LOAN/REFINANCING -> Refinanciamento
    PAYROLL/PAYROLL_LOAN/DISCHARCHING -> Quitação
    */
    public static String payloadMock(String param,String productType, String step, String externalId){
        String participantExternalId = param == 'proponentNotFound' ? '"id":"FAKE_ID_TO_GET_ERROR",' : '"id":"papirus",'; 
        String tenant = param == 'opportunityDmlError' ? '"tenant": "erro",' : '"tenant": "creditasbr",';
        String role = param == 'proponentDmlError' ? '"ERRO"' : '"PRINCIPAL"';
		String oppExternalId = externalId == null ? '"LAP-2211F221-FF13-47ED-B097-4FE93E33712E"' : '"' + externalId + '"';
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
		'       "step":"'+ step + '"'+
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
		'    "productType":"'+ productType +'",'+
		'    "purpose":"OTHERS",'+
		'    "id": ' + oppExternalId + ','+
		'    "version": "7",'+
		tenant+
		'    "createdAt": "2021-08-16T14:09:42.206Z",'+
		'    "updateAt": "2021-08-16T23:40:11.362Z"'+
		' }';
        return json;
    }  
    
}