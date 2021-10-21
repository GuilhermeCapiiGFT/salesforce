/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Web Service customizado para criação de Opportunities and seus objetos relacionados 
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           20/09/2021      Created     Implementação das requisições REST do web service de Opportunity
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationOpportunity/*')
global without sharing class OpportunityService 
{
    
	@HttpPut
    global static void putMethod() 
    {
        OpportunityIntegrationModel requestBodyObj = OpportunityIntegrationModel.parse(RestContext.request.requestBody.toString());
        
        String accountName = getParticipantName(requestBodyObj);
                        
        Response opportunityResponse = upsertOpportunity(requestBodyObj, accountName);

        Id opportunityId = opportunityResponse.opportunityId;
        
        upsertQuote(requestBodyObj, opportunityId, accountName);
        
        upsertOpportunityRoles(requestBodyObj, opportunityId); 
                    
        //Response
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.responseBody = Blob.valueOf(JSON.serialize(opportunityResponse));
        res.statusCode = 200;
    }   
    
    
    private static String getParticipantName(OpportunityIntegrationModel requestBodyObj){
        List<String> externalPersonIds = new List<String>();
        for(OpportunityIntegrationModel.cls_participants participant : requestBodyObj.participants)
        {
            externalPersonIds.add(participant.person.id);
        }
        
        String accountName = [SELECT Id, ExternalId__c, Name FROM Account WHERE ExternalId__c IN :externalPersonIds]?.Name;
        
		return accountName != null ? accountName : externalPersonIds[0];         
    }
 
    
    private static Response upsertOpportunity(OpportunityIntegrationModel requestBodyObj, String accountName)
    {            
        
        Opportunity opportunityToUpsert = new Opportunity
        (     
        	Id = [SELECT Id, ExternalId__c FROM Opportunity WHERE ExternalId__c = :requestBodyObj.id]?.Id,
            ExternalId__c = requestBodyObj.id,
        	ExternalVersion__c = Decimal.valueOf(requestBodyObj.version),
        	ExternalTenant__c = requestBodyObj.tenant,                     
            Name = requestBodyObj.friendlyId + ' - ' + accountName,
            StageName = 'Formalização',
            IdName__c = requestBodyObj.friendlyId,
            CloseDate = System.today().addDays(30),                                
        	ExternalCreationDate__c = Date.valueOf(requestBodyObj.createdAt),
        	ExternalUpdatedDate__c = Date.valueOf(requestBodyObj.updateAt)
        ); 
        Boolean isUpdate = opportunityToUpsert.Id != null;
                
        upsert opportunityToUpsert;
        system.debug('>>>>> ' + opportunityToUpsert);
       	Response oppResponse = new Response();
        oppResponse.opportunityId = opportunityToUpsert.Id;
        oppResponse.message = isUpdate ? 'Opportunity sucessfully updated.' : 'Opportunity sucessfully created.';
        return oppResponse;
    }
    
   
    private static void upsertQuote(OpportunityIntegrationModel requestBodyObj, Id opportunityId, String accountName)
    {
        Quote quoteToUpsert = new Quote
        (
        	Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId]?.Id,
        	ParameterTac__c = requestBodyObj.conditions.parameters.tac.amount,
        	ParameterIOF__c = requestBodyObj.conditions.parameters.iof.amount,
        	ParameterAdditionalCosts__c = requestBodyObj.conditions.parameters.additionalCosts.amount,
        	CreditScore__c = requestBodyObj.conditions.parameters.creditScore,    
        	GracePeriod__c = requestBodyObj.conditions.parameters.gracePeriod,
        	ContractDate__c = Date.valueOf(requestBodyObj.conditions.parameters.contractDate),
        	ParameterCalcVersion__c = requestBodyObj.conditions.parameters.calculatorVersion,
            LimitCetMinimunc__c = requestBodyObj.conditions.limitData.cetLimit.minimum,
            LimitCetMaximum__c = requestBodyObj.conditions.limitData.cetLimit.maximum,
            yearlyLimitMinimunc__c = requestBodyObj.conditions.limitData.interest.yearlyLimit.minimum,   
            yearlyLimitMaximum__c = requestBodyObj.conditions.limitData.interest.yearlyLimit.maximum,  
            monthlyLimitMinimunc__c = requestBodyObj.conditions.limitData.interest.monthlyLimit.minimum,   
            monthlyLimitMaximum__c = requestBodyObj.conditions.limitData.interest.monthlyLimit.maximum, 
        	LimitTotal__c = requestBodyObj.conditions.limitData.total.amount,
        	LimitInstallmentType__c = requestBodyObj.conditions.limitData.installmentType,
        	LimitDueDate__c = Date.valueOf(requestBodyObj.conditions.limitData.dueDate),     
        	MonthlyIntRateCompType__c = requestBodyObj.conditions.monthlyInterestRateComposition[0].type,    
        	MonthlyIntRateCompValue__c = requestBodyObj.conditions.monthlyInterestRateComposition[0].value, 
        	NetValue__c = requestBodyObj.conditions.netValues.amount,
            OpportunityId = opportunityId,
            Name = accountName + ' Quote'
        );
        
        upsert quoteToUpsert;                 
    }
 
    
    private static void upsertOpportunityRoles(OpportunityIntegrationModel requestBodyObj, Id opportunityId)
    {
        Set<String> externalPersonIds = new Set<String>();
        for(OpportunityIntegrationModel.cls_participants participant : requestBodyObj.participants)
        {
            externalPersonIds.add(participant.person.id);
        }
        
        Map<String, OpportunityRole__c> externalPersonIdToOpportunityRoleMap = new Map<String, OpportunityRole__c>();
        for (OpportunityRole__c opportunityRole : [SELECT Id, Opportunity__c, ExternalPersonId__c, Role__c 
                                                   FROM OpportunityRole__c
                                                   WHERE ExternalPersonId__r.ExternalId__c IN :externalPersonIds 
                                                   AND Opportunity__c = :opportunityId])
        {
			externalPersonIdToOpportunityRoleMap.put(opportunityRole.ExternalPersonId__c, opportunityRole);                                                  
        }
        
        Map<String, Account> externalPersonIdToAccountMap = new Map<String, Account>();
        String accountName = '';
        for (Account acc : [SELECT Id, ExternalId__c, Name FROM Account WHERE ExternalId__c IN :externalPersonIds])
        {
            externalPersonIdToAccountMap.put(acc.ExternalId__c, acc);
        }
        
        List<OpportunityRole__c> opportunityRolesToUpsert = new List<OpportunityRole__c>();
        for(OpportunityIntegrationModel.cls_participants participant : requestBodyObj.participants)
        {
            Id personId = externalPersonIdToOpportunityRoleMap.get(participant.person.id)?.Id;
            if (personId == null) continue;
            OpportunityRole__c opportunityRoleToUpsert = new OpportunityRole__c
            (         
            	Id = personId,
            	Role__c = participant.roles[0],
            	ExternalPersonId__c = externalPersonIdToAccountMap.get(participant.person.id)?.Id,
            	Opportunity__c = opportunityId
            ); 
            
            opportunityRolesToUpsert.add(opportunityRoleToUpsert);
        }
        
        upsert opportunityRolesToUpsert;        
    }

    private class Response
    {
        public String status;
        public String opportunityId;
        public String message;
    }
    
}