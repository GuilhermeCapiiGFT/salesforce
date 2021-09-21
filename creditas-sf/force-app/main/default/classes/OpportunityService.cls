/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Web Service customizado para criação de Opportunities and seus objetos relacionados 
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           16/09/2021      Created     Implementação das requisições REST do web service de Opportunity
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationOpportunity/*')
global without sharing class OpportunityService {
    
	@HttpPost
    global static void postMethod() 
    {
        OpportunityIntegrationModel requestBodyObj = OpportunityIntegrationModel.parse(RestContext.request.requestBody.toString());

        Id opportunityId = upsertOpportunity(requestBodyObj);
        
        upsertQuote(requestBodyObj, opportunityId);
    }
    
    
    private static Id upsertOpportunity(OpportunityIntegrationModel requestBodyObj)
    {            
        Opportunity opportunityToUpsert = new Opportunity();      
        opportunityToUpsert.Id = [SELECT ExternalId__c FROM Opportunity WHERE ExternalId__c = :requestBodyObj.id]?.Id;
        opportunityToUpsert.ExternalVersion__c = Decimal.valueOf(requestBodyObj.version);
        opportunityToUpsert.ExternalTenant__c = requestBodyObj.tenant;
        opportunityToUpsert.ExternalCreationDate__c = DateTime.parse(requestBodyObj.createdAt);
        opportunityToUpsert.ExternalUpdatedDate__c = DateTime.parse(requestBodyObj.updateAt);
                
        upsert opportunityToUpsert;
         
        return opportunityToUpsert.Id;

    }

    
    private static void upsertQuote(OpportunityIntegrationModel requestBodyObj, Id opportunityId)
    {
        Quote quoteToUpsert = new Quote();
        quoteToUpsert.Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId]?.Id;
        quoteToUpsert.ParameterTac__c = requestBodyObj.conditions.parameters.tac.amount;
    }

    /*public static Opportunity getOpportunityById(Id opportunityId) {
        return [SELECT Id, Name 
                FROM Opportunity
                WHERE Id =: opportunityId];
    }*/

    private class Response {
        public String status;
        public String opportunityId;
        public String message;
    }
}