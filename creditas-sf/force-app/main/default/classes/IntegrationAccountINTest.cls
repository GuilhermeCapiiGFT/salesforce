@IsTest
global with sharing class IntegrationAccountINTest {
    
    @TestSetup
    static void makeData(){
        Account testAcc = new Account(Name = 'test acc', ExternalId__c = 'PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664');
        insert testAcc;
                   
        Account spouseAcc = new Account(Name = 'spouse test', ExternalId__c = 'PER-EDF4345E-04C2-45C1-87D5-445F52391DA1');
        insert spouseAcc;
        
        Account accDocumentNumber = new Account(Name = 'test doc number', DocumentNumber__c = '91722085037', ExternalId__c = 'FAKE_EXTERNAL_ID');
        insert accDocumentNumber;
        
        CommunicationContacts__c testContact = new CommunicationContacts__c(ExternalId__c = '758a54b3-0fbf-49e8-a7bc-5a0397ec3940', Account__c = testAcc.Id);
        insert testContact;
        
        Addresses__c testAddress = new Addresses__c(ExternalAddressId__c = 'fake_external_id_for_test', Account__c = testAcc.Id);
        insert testAddress;
        
        AccountRelationships__c accRelationship = new AccountRelationships__c(ExternalId__c = 'd565c5ca-b5fc-42fc-b120-62550c34a0aa', PrimaryRelationship__c = testAcc.Id, SecondaryRelationship__c = spouseAcc.Id);
		insert accRelationship;
        
        Documents__c testDocument = new Documents__c(ExternalId__c = '92ff3147-a698-4ae5-ad3b-bea939911015', Account__c = testAcc.Id);
        insert testDocument;
        
        FinancialResources__c testIncome = new FinancialResources__c(ExternalId__c = '43a6c3d0-47db-45f3-b410-b63859efd9a2');
    	insert testIncome;
        
        AccountFinancialRelationship__c testIncomeRelationship = new AccountFinancialRelationship__c(Recurso_Financeiro__c = testIncome.Id, Account__c = testAcc.Id);
    	insert testIncomeRelationship;
        
        ProfessionalInfo__c testProfessionalInfo = new ProfessionalInfo__c(ExternalId__c = '3cd499c0-5bb1-4019-83f3-2cf8d961da2c', Account__c = testAcc.Id);
    	insert testProfessionalInfo;
        
        FinancialResources__c testProfessionalIncome = new FinancialResources__c(ExternalId__c = '43a6c3d0-47db-45f3-b410-b63859efd9a2', ProfessionalInfo__c = testProfessionalInfo.Id);
    	insert testProfessionalIncome;
            
        AccountFinancialRelationship__c testProfessionalIncomeRelationship = new AccountFinancialRelationship__c(Recurso_Financeiro__c = testProfessionalIncome.Id, Account__c = testAcc.Id);
    	insert testProfessionalIncomeRelationship;
    }
    
    @isTest
    static void testUpsertAccountSucess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('success'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();        
        
        List<Account> createdAcc = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664'];
        System.assertEquals(1, createdAcc.Size(),'Account successfully upserted.');
        
        List<CommunicationContacts__c> createdContacts = [SELECT Id FROM CommunicationContacts__c];
        System.assertEquals(3, createdContacts.Size(),'CommunicationContacts successfully upserted.');
        
        List<Addresses__c> createdAddresses = [SELECT Id FROM Addresses__c];
        System.assertEquals(2, createdAddresses.Size(),'Addresses successfully upserted.');
        
        List<Documents__c> createdDocuments = [SELECT Id FROM Documents__c];
        System.assertEquals(1, createdDocuments.Size(),'Documents successfully upserted.');
        
        List<FinancialResources__c> createdIncomes = [SELECT Id FROM FinancialResources__c];
        System.assertEquals(4, createdIncomes.Size(),'FinancialResources successfully upserted.');
        
        List<ProfessionalInfo__c> createdProfessionalInfos = [SELECT Id FROM ProfessionalInfo__c];
        System.assertEquals(2, createdProfessionalInfos.Size(),'ProfessionalInfo successfully upserted.');
               
        List<AccountFinancialRelationship__c> createdAccountFinancialRelationships = [SELECT Id FROM AccountFinancialRelationship__c];
        System.assertEquals(4, createdAccountFinancialRelationships.Size(),'AccountFinancialRelationship successfully upserted.');
        
        List<AccountRelationships__c> createdRelationships = [SELECT Id FROM AccountRelationships__c];
        System.assertEquals(1, createdRelationships.Size(),'AccountRelationships successfully upserted.');
          
		system.assertEquals(res.statusCode, 200,'Account and related objects successfully upserted');   
        
    }    
    
    @isTest
    static void testUpsertAccountByDocumentNumber(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('documentNumber'));
        	RestContext.request = req;
        	RestContext.response= res;           
            IntegrationAccountIN.putMethod();          
        Test.stopTest();
        
		system.assertEquals(res.statusCode, 200,'Document Number successfully upserted.');   
    }  
    
    @isTest
    static void testInvalidCurrency(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('invalidCurrency'));
        	RestContext.request = req;
        	RestContext.response= res;            
            IntegrationAccountIN.putMethod();          
        Test.stopTest();
        
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		System.assertEquals(reqResString, '{"status":500,"message":"invalid currency code: ERRO","accountId":null}');
    }  
    
    @isTest
    static void testUpsertAccountParseError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('parseError'));
        	RestContext.request = req;
        	RestContext.response= res;             
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		system.assertEquals(reqResString,'{"status":500,"message":"Invalid JSON format.","accountId":null}','Invalid string for JSON format.');      
    }  
    
    @isTest
    static void testUpsertAccountDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('AccDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
            IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		system.assertEquals(reqResString,'{"status":500,"message":"An error has occurred upserting Account object.","accountId":null}','DML error to upsert Account.');      
    }   
    
    @isTest
    static void testUpsertAccountDmlError2(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('AccDmlError2'));
        	RestContext.request = req;
        	RestContext.response= res;             
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
		system.assertEquals(reqResString,'{"status":500,"message":"An error has occurred upserting Account object.","accountId":null}','DML error to upsert Account.');      
    }   
    
    @isTest
    static void testUpsertContactDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('contactDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert Contact.');      
    }
    
    @isTest
    static void testUpsertAddressesDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('addressDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert Addresses.');      
    }
    
    @isTest
    static void testUpsertRelationshipsDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('relationshipDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert Relationships.');      
    }
    
    @isTest
    static void testUpsertDocumentsDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('documentDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert Documents.');      
    }    
    
    @isTest
    static void testUpsertIncomeDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('incomeDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert Income.');      
    }
    
    @isTest
    static void testUpsertProfessionalInfoDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('professionalInfoDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert ProfessionalInfo.');      
    }    
    
    @isTest
    static void testUpsertProfessionalIncomeDmlError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('professionalIncomeDmlError'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);
		system.assertEquals(res.statusCode, 500,'DML error to upsert ProfessionalIncome.');      
    }    
    
    @isTest
    static void testNullContactSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullContact'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Contacts is null and the Account is still being successfully upserted.');      
    }

    @isTest
    static void testNullAddressSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullAddress'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Addresses is null and the Account is still being successfully upserted.');      
    }    

    @isTest
    static void testNullRelationshipsSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullRelationships'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Relationship is null and the Account is still being successfully upserted.');      
    }   
    
    @isTest
    static void testNullDocumentsSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullDocuments'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Documents is null and the Account is still being successfully upserted.');      
    }  

    @isTest
    static void testNullIncomeSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullIncome'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Income is null and the Account is still being successfully upserted.');      
    }      
  
    @isTest
    static void testNullProfessionalInfoSuccess(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullProfessionalInfo'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
		system.assertEquals(res.statusCode, 200,'Professional Info is null and the Account is still being successfully upserted.');      
    }      
    
    @isTest
    static void doubleProfessionalIncomeError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('doubleProfIncome'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.assertEquals(reqResString, '{"status":500,"message":"Each professional info. must has only one professional income.","accountId":null}');
        
    }   
    
    @isTest
    static void nullMainDocumentError(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();      
        	req.requestURI = '/services/apexrest/IntegrationAccountIN'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(accountMock('nullMainDoc'));
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAccountIN.putMethod();          
        Test.stopTest();
        String reqResString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(res.responseBody)).toString();
        System.debug(reqResString);       
    } 
      
    static String accountMock(String param){
        String version = param == 'parseError' ? '"version": "A"' : '"version": 27';
        String gender = param == 'AccDmlError' ? '"gender": "ERRO",' : '"gender": "FEMALE",';
        String networthLowerLimit = param == 'AccDmlError2' ? '"networthLowerLimit": "erro",' : '"networthLowerLimit": "30000",';
        String contactType = param == 'contactDmlError' ? '"type": "ERRO"' : '"type": "PERSONAL"';
        String externalAccountId = param == 'documentNumber' ? '"id": null,' : '"id": "PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664",';
        String documentNumber =  param == 'documentNumber' ? '"code": "91722085037"' : '"code": "50450177050"';
        String contactExternalId = param == 'documentNumber' ? '"id": "758a54b2-0fbf-49e8-a7bc-5a0397ec3940",' : '"id": "758a54b3-0fbf-49e8-a7bc-5a0397ec3940",';
        String currencyCode = param == 'invalidCurrency' ? '"currencyCode": "ERRO",' : '"currencyCode": "BRL",';
        String addressType = param == 'addressDmlError' ? '"type": "ERRO",' : '"type": "BILLING",';
        String relationshipType = param == 'relationshipDmlError' ? '"type": "ERRO",' : '"type": "SPOUSE",';
        String documentType = param == 'documentDmlError' ? '"type": "erro",' : '"type": "pis",';
        String incomeType = param == 'incomeDmlError' ? '"type": "ERRO",' : '"type": "MONTHLY_INCOME",';
        String professionalCategory = param == 'professionalInfoDmlError' ? '"category": "ERRO",' : '"category": "ADMINISTRATIVE",';
        String professionalIncomeType = param == 'professionalIncomeDmlError' ? '"type": "ERRO",' : '"type": "MONTHLY_INCOME",';
        String mainDocument = param == 'nullMainDoc' ? '"mainDocument": null,'
            : 		'    "mainDocument": {'+
					'        "type": "CPF",'+
					documentNumber+
					'    },';
        String contacts = param == 'nullContact' ? '"contacts": null,'
            : '    "contacts": ['+
            '        {'+
            '            "id": "2d8003db-8e36-4f1b-a238-f1813d2f1fc3",'+
            '            "channel": "PHONE",'+
            '            "code": "1155557771",'+
            contactType+
            '        },'+
            '        {'+
            contactExternalId+
            '            "channel": "WHATSAPP",'+
            '            "code": "11999998883",'+
            '            "type": "COMERCIAL"'+
            '        },'+
            '        {'+
            '            "id": "16cbd37c-6b99-4510-85ee-21e8bf61bc27",'+
            '            "channel": "EMAIL",'+
            '            "code": "email@email2.com",'+
            '            "type": "PERSONAL"'+
            '        }'+
            '    ],';
        String addresses = param == 'nullAddress' ? '"addresses":null,'
            : 	'"addresses": ['+
                '        {'+
                '            "id": "fake_external_id_for_test",'+
                addressType+
                '            "country": "MX",'+
                '            "neighborhood": "ARBOLEDAS DEL SUR",'+
                '            "street": "CERRADA BETIS",'+
                '            "streetNumber": "30",'+
                '            "complement": "14388",'+
                '            "zipCode": "14376"'+
                '        },'+
                '        {'+
                '            "id": "fake_external_id_for_test2",'+
                '            "type": "HOME",'+
                '            "country": "MX",'+
                '            "neighborhood": "ARBOLEDAS DEL SUR",'+
                '            "street": "CERRADA BETIS",'+
                '            "streetNumber": "40",'+
                '            "complement": "14388",'+
                '            "zipCode": "14376"'+
                '        }'+
                '    ],';
        String relationships = param == 'nullRelationships' ? '"relationships": null,'
            : '    "relationships": ['+
            '        {'+
            '            "id": "d565c5ca-b5fc-42fc-b120-62550c34a0aa",'+
            relationshipType+
            '            "personId": "PER-EDF4345E-04C2-45C1-87D5-445F52391DA1"'+
            '        },'+
            '        {'+
            '			 "id": "e65a232d-9ec4-4bc5-965f-a290fde3a599",'+
            '            "type": "OFFSPRING",'+
            '	         "personId": "PER-54AA8B47-D0BD-464F-A446-5FA759222CD3"'+
         	'        }'+
            '    ],';
        String documents = param == 'nullDocuments' ? '"documents": null,'
            : '    "documents": ['+
            '        {'+
            '            "id": "92ff3147-a698-4ae5-ad3b-bea939911015",'+
            documentType+
            '            "code": "HEVP260702QA3",'+
            '            "issueDate": "2023-01-01"'+
            '        }'+
            '    ],';
        String income = param == 'nullIncome' ?  '"income": null,'
            : '    "income": ['+
            '        {'+
            '            "id": "43a6c3d0-47db-45f3-b410-b63859efd9a2",'+
            incomeType+
            '            "source": "SALES",'+
            '            "amount": {'+
            currencyCode+
            '                "amount": "10000"'+
            '            },'+
            '            "createdAt": "2021-08-16T21:06:49Z",'+
            '            "updatedAt": "2021-08-16T21:06:49Z"'+
            '        },'+
            '        {'+
            '            "id": "5baf872f-6b43-4da9-a8ca-74b3ca149aa1",'+
            '            "type": "PRESUMED_MONTHLY_INCOME",'+
            '            "source": "RENTS",'+
            '            "amount": {'+
            '                "currencyCode": "BRL",'+
            '                "amount": "10000"'+
            '            },'+
            '            "createdAt": "2021-08-16T21:06:49Z",'+
            '            "updatedAt": "2021-08-16T21:06:49Z"'+
            '        }'+
            '    ],';
        String doubleProfessionalIncome = param == 'doubleProfIncome' ?
            	'               ,{'+
            	'                    "type": "MONTHLY_INCOME",'+
				'                    "amount": {'+
				'                        "currencyCode": "BRL",'+
				'                        "amount": "11000"'+
				'                    },'+
				'                    "source": "SALES"'+
				'                }' 
    	: '';
        String professionalIncome = param == 'nullProfessionalInfo' ? '"professionalInfo": null,'
            : '    "professionalInfo": ['+
            '        {'+
            '            "id": "3cd499c0-5bb1-4019-83f3-2cf8d961da2c",'+
            '            "startDate": {'+
            '                "year": 2019,'+
            '                "month": 10'+
            '            },'+
            '            "jobTitle": "Seller",'+
            '            "companyName": "La Vivenda",'+
            '            "economicActivity": "AGRICULTURE",'+
            '            "status": "SELF_EMPLOYED",'+
            professionalCategory+
            '            "current": true,'+
            '            "professionalIncome": ['+
            '                {'+
            professionalIncomeType+
            '                    "amount": {'+
            '                        "currencyCode": "BRL",'+
            '                        "amount": "10000"'+
            '                    },'+
            '                    "source": "SALES"'+
            '                }'+
            doubleProfessionalIncome+
            '            ]'+
            '        },'+
            '        {'+
            '            "id": "8576ff9d-b6db-4253-adbe-0bd116419097",'+
            '            "startDate": {'+
            '                "year": 2019,'+
            '                "month": 10'+
            '            },'+
            '            "jobTitle": "Seller",'+
            '            "companyName": "La Vivenda",'+
            '            "economicActivity": "AGRICULTURE",'+
            '            "status": "SELF_EMPLOYED",'+
            '            "category": "MERCHANT",'+
            '            "current": true,'+
            '            "professionalIncome": ['+
            '                {'+
            '                    "type": "MONTHLY_INCOME",'+
            '                    "amount": {'+
            '                        "currencyCode": "BRL",'+
            '                        "amount": "8000"'+
            '                    },'+
            '                    "source": "SALES"'+
            '                }'+
            '            ]'+
            '        }'+
            '    ],';
        
		String json=		'{'+
		externalAccountId+
		mainDocument+
		'    "fullName": "test account",'+
		'    "additionalProperties": {'+
		'        "firstName": "Melanie",'+
		'        "secondName": "Martin",'+
		'        "lastName": "Virginia",'+
		'        "secondLastName": "Esteban",'+
		'        "curp": "EEVM960513MMCSIL01",'+
		'        "ineNumber": "1234567891234",'+
		'        "bankName": "BBVA",'+
		'        "accountNumber": "123445566",'+
		'        "clabe": "123445566",'+
		'        "politicallyExposed": false'+
		'    },'+
		'    "wealth": {'+
		networthLowerLimit+
		'        "networthUpperLimit": "100000",'+
		'        "currencyCode": "BRL",'+
		'        "informedDate": "2021-08-16T14:09:42.189Z"'+
		'    },'+
		gender+
		'    "birthDate": "1996-05-13",'+
		'    "civilStatus": "MARRIED",'+
		'    "cityOfBirth": "Mexico",'+
		'    "countryOfBirth": "MX",'+
		'    "nationality": "MX",'+
		contacts+
		addresses+
		documents+
		'    "education": {'+
		'        "degree": "COLLEGE_DEGREE_COMPLETED"'+
		'    },'+
		'    "filiation": ['+
		'        {'+
		'            "type": "MOTHER",'+
		'            "name": "Paola Virginia 4"'+
		'        }'+
		'    ],'+
		income+
		professionalIncome+
		relationships+
		'    "createdAt": "2021-08-16T14:09:42.206Z",'+
		'    "updatedAt": "2021-08-16T23:40:11.362Z",'+
		version+
		'}';
        return json;
    }
    
}