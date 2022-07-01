@isTest
private with sharing class IntegrationAssetServiceTest {

    @TestSetup
    private static void makeData(){
        Account testAcc = new Account(Name = 'Jose', ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111113');
        insert testAcc;
        
        FinancialResources__c testIncome = new FinancialResources__c(ExternalId__c = 'AST-3FA85F64-5717-4562-B3FC-111111111111');
        insert testIncome;
        
        AccountFinancialRelationship__c accRelationship = new AccountFinancialRelationship__c();
        accRelationship.Account__c = testAcc.Id;
        accRelationship.Recurso_Financeiro__c = testIncome.Id;
        insert accRelationship;
    }
 
    @isTest
    private static void testUpsertAssetSuccess(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('vehicle'));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        FinancialResources__c assetList = [SELECT Id, RecordType.DeveloperName FROM FinancialResources__c LIMIT 1];
        System.assert(assetList.RecordType.DeveloperName == 'Auto'); 
        
        System.assertEquals(1, [SELECT Count() FROM AccountFinancialRelationship__c], 'Only one relation must be created, because the other owner id does not exist on salesforce'); 
    }     

    @isTest
    private static void testNullOwnerSuccess(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('nullOwners'));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        System.assertEquals(res.statusCode, 200, 'Expected asset successfully upserted even if "owners" is null.'); 
    }  

    @isTest
    private static void testSucessForVehicleAsset(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('vehicle'));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        List<FinancialResources__c> assetList = [SELECT Id, Recordtype.DeveloperName FROM FinancialResources__c];
        System.assert(assetList[0].Recordtype.DeveloperName == 'Auto'); 
    }    
    
    @isTest
    private static void testSucessForRealStateAsset(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('realState'));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        List<FinancialResources__c> assetList = [SELECT Id, RecordType.DeveloperName FROM FinancialResources__c];
        System.assert(assetList[0].RecordType.DeveloperName == 'Imovel'); 
    }  
    
       @isTest
    private static void testSucessForOthersAsset(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('other'));
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        List<FinancialResources__c> assetList = [SELECT Id, RecordType.DeveloperName FROM FinancialResources__c];
        System.assert(assetList[0].RecordType.DeveloperName == 'Outros'); 
    }    
    
    @isTest
    private static void testIfAccountRelationIsDeleted(){
        Account testAccToDissociate = new Account(Name = 'Jose', ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111118');
        insert testAccToDissociate;
    
        FinancialResources__c testIncome = [SELECT Id FROM FinancialResources__c WHERE ExternalId__c = 'AST-3FA85F64-5717-4562-B3FC-111111111111'];
    
        AccountFinancialRelationship__c accRelationshipToBeDeleted = new AccountFinancialRelationship__c();
        accRelationshipToBeDeleted.Account__c = testAccToDissociate.Id;
        accRelationshipToBeDeleted.Recurso_Financeiro__c = testIncome.Id;
        insert accRelationshipToBeDeleted;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('vehicle'));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        
        List<AccountFinancialRelationship__c> deletedRelations = [SELECT Id FROM AccountFinancialRelationship__c WHERE Account__r.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111118'];
        System.assertEquals(deletedRelations.size(), 0, 'Check if the relation was deleted after upsert method execution'); 
    }

    @isTest
    private static void testUpsertAssetDmlError(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        String payload = getAssetMock('assetDmlError');
        req.requestBody = Blob.valueof(payload);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();
        System.debug('response = ' + res) ;
        System.assertEquals(500, res.statusCode, 'Error for invalid currency code');
    }
    
    //we need to keep this method for test coverage
    @isTest
    private static void testParseError(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IntegrationAsset';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(getAssetMock('invalidJSON'));
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            IntegrationAssetController.putMethod();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'JSON parse error'); 
    }

    @isTest
    private static void testGetUF(){
        Test.startTest();
            System.assertEquals('AC',IntegrationAssetService.getUF('Acre'));
            System.assertEquals('AL',IntegrationAssetService.getUF('Alagoas'));
            System.assertEquals('AP',IntegrationAssetService.getUF('Amapá'));
            System.assertEquals('AM',IntegrationAssetService.getUF('a M a Z o n A s'));
            System.assertEquals('BA',IntegrationAssetService.getUF('BAHIA'));
            System.assertEquals('CE',IntegrationAssetService.getUF('CEARÁ'));
            System.assertEquals('DF',IntegrationAssetService.getUF('Distrito Fede RAL'));
            System.assertEquals('ES',IntegrationAssetService.getUF('Esp irito Sant o'));
            System.assertEquals('GO',IntegrationAssetService.getUF('goiAs'));
            System.assertEquals('MA',IntegrationAssetService.getUF('maranhão'));
            System.assertEquals('MT',IntegrationAssetService.getUF('Mato Grosso'));
            System.assertEquals('MS',IntegrationAssetService.getUF('Mato Grosso do Sul'));
            System.assertEquals('MG',IntegrationAssetService.getUF('Minas Gerais'));
            System.assertEquals('PA',IntegrationAssetService.getUF('Pará'));
            System.assertEquals('PB',IntegrationAssetService.getUF('paraíba'));
            System.assertEquals('PR',IntegrationAssetService.getUF('Paráná'));
            System.assertEquals('PE',IntegrationAssetService.getUF('Pernambuco'));
            System.assertEquals('PI',IntegrationAssetService.getUF('Piauí'));
            System.assertEquals('RJ',IntegrationAssetService.getUF('rIo dE JaNeIrO'));
            System.assertEquals('RN',IntegrationAssetService.getUF('Rio Grande do Norte'));
            System.assertEquals('RS',IntegrationAssetService.getUF('Rio Grande Do Sul'));
            System.assertEquals('RO',IntegrationAssetService.getUF('Rondônia'));
            System.assertEquals('RR',IntegrationAssetService.getUF('Roraima'));
            System.assertEquals('SC',IntegrationAssetService.getUF('SantaCatarina'));
            System.assertEquals('SP',IntegrationAssetService.getUF('São Paulo'));
            System.assertEquals('SE',IntegrationAssetService.getUF('Sergipe'));
            System.assertEquals('TO',IntegrationAssetService.getUF('Tocantins'));
            System.assertEquals('ZipLoque Reglabel',IntegrationAssetService.getUF('ZipLoque Reglabel'));
            System.assertEquals('SP',IntegrationAssetService.getUF('SP'));
        Test.stopTest();
    }

    static String getAssetMock(String param)
    {
        String currencyCode = param == 'assetDmlError' ? '"currencyCode": "MXN",' : '"currencyCode": "BRL",';
        String version = param == 'invalidJSON' ? '"version": "A",' : '"version": 1,';
        String assetType = param == 'vehicle' ? '"type": "VEHICLE",' : param == 'realState' ? '"type": "REAL_ESTATE",' : param == 'other' ? '"type": "OTHER",' : '"type": "CERTIFICATE",';
  
        String owners = param == 'nullOwners' ? '"owners": null,'
           : '"owners": ['+
          '    {'+
          '      "person": {'+
          '        "id": "PER-3FA85F64-5717-4562-B3FC-111111111113",'+
          '        "version": 1'+
          '      }'+
            '    },'+
          '    {'+
          '      "person": {'+
          '        "id": "PER-3FA85F64-5617-4562-B3FC-111111111112",'+
          '        "version": 1'+
          '      }'+
            '    }'+  
          '  ],';

        String json=		'{'+
        '  "id": "AST-3FA85F64-5717-4562-B3FC-111111111111",'+
            version+
            assetType+
            owners+
        '  "value": {'+
        '    "amount": {'+
                currencyCode +
        '      "amount": "30000"'+
        '    },'+
        '    "appraisalDate": "2019-05-10"'+
        '  },'+
        '  "alienation": {'+
        '    "financialInstitution": "001"'+
        '  },'+
        '  "assetDetail": {'+
        '    "type": "CAR",'+
        '    "chassis": "123414141",'+
        '    "plate": "EIO7016",'+
        '    "brand": "Ford",'+
        '    "model": "Fiesta Sedan 1.6 16V Flex Mec.",'+
        '    "modelYear": 2014,'+
        '    "manufacturingYear": 2013,'+
        '    "licensing": {'+
        '      "address": {'+
        '        "administrativeAreaLevel1": "Pernambuco",'+
        '        "administrativeAreaLevel2": "Recife",'+
        '        "street": "Recife address",'+
        '        "neighborhood": "Boa Vista",'+
        '        "streetNumber": "5432",'+
        '        "complement": "apartment 43",'+
        '        "zipCode": "87989-000"'+
        '      }'+
        '    },'+
        '    "color": "Azul",'+
        '    "fuelType": "GASOLINE",'+
        '    "state": "SP",'+
        '    "category": "PERSONAL",'+
        '    "externalCodes": [ '+
        '       { ' +
        '           "origin": "FIPE", ' + 
        '           "code": "008026-8" ' +
        '        } ' +
        '   ], '+
        '   "additionalKeys": [ '+
        '          { '+
        '               "key": "NCI", ' +
        '               "code": "123454321123" ' +
        '          } ' +
        '   ] ' +
        '   },'+
        '  "createdAt": "2019-01-10T10:00:01Z",'+
        '  "updatedAt": "2019-01-10T12:00:01Z"'+
        '}';

        return json;
    }
}