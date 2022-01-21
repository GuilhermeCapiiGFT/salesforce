@isTest(SeeAllData=true)
global with sharing class IntegrationAssetTest {
    @isTest
    static void testUpsertAccount(){   
        
        Account owner = new Account();
        owner.Name = 'Jose';
        owner.ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111';
        owner.DocumentNumber__c = '01234567890';
        owner.DocumentType__c = 'CPF';
        owner.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME = 'Pessoa Física']?.Id;
        
        insert owner;
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        
        	req.requestURI = '/services/apexrest/IntegrationAsset'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(AssetIntegrationModel.assetMock());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	IntegrationAsset.putMethod(); 
            //delete the owner to get the error message
            delete [SELECT Id FROM Account WHERE ExternalId__c = 'PER-3FA85F64-5717-4562-B3FC-111111111111' LIMIT 1];
            IntegrationAsset.putMethod();      
        Test.stopTest();     
    }        
  
}