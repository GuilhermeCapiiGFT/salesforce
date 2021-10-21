@isTest
Global class OpportunityServiceTest {
    @isTest
    static void testUpsertOpportunity(){   
        
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        
        	req.requestURI = '/services/apexrest/IntegrationOpportunity'; 
        	req.httpMethod = 'PUT';
        	req.requestBody = Blob.valueof(OpportunityIntegrationModel.opportunityMock());
        	RestContext.request = req;
        	RestContext.response= res;             
       
        	OpportunityService.putMethod();          
        Test.stopTest();     
    }    
}