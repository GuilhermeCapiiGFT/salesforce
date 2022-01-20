/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Web Service customizado para criação de Oportunidades e seus objetos relacionados 
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           20/09/2021      Created     Implementação das requisições REST do web service de Opportunity
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationOpportunity/*')
global without sharing class OpportunityService 
{
    public static Opportunity oppToUpsert;
    public static String errorMessage;
    public static String requestBody;
    public static OpportunityIntegrationModel requestBodyObj;
    public static Boolean hasError = false;
    public static String accountName;
    public static Id opportunityId;
    

	@HttpPut
    global static void putMethod() 
    {
        try {
            String requestBodyString = RestContext.request.requestBody.toString();
            requestBody = requestBodyString;
            requestBodyObj = OpportunityIntegrationModel.parse(requestBodyString);

            if (!requestBodyObj.hasError){
                getParticipantName();
                if (accountName == 'false'){
                    hasError = true;
                    errorMessage = 'Proponent not found in Salesforce';
                    setErrorResponse(500);
                    insertErrorLog(500);
                    return;
                }

                //upsertOpportunity();

                commitTransactions();

                if (!hasError){
                    Response oppResponse = new Response();
                    oppResponse.opportunityId = opportunityId;
                    oppResponse.message = 'Opportunity successfully upserted.';
                    RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
                    res.responseBody = Blob.valueOf(JSON.serialize(oppResponse));
                    res.statusCode = 200;
                } else {
                    setErrorResponse(500);
                    insertErrorLog(500);
                }
            } else {
                hasError = true;
                errorMessage = requestBodyObj.errorMessage;
                setErrorResponse(500);
                insertErrorLog(500);
            }
        } catch(Exception e) {
            hasError = true;
            errorMessage = e.getMessage();
            setErrorResponse(500);
            insertErrorLog(500);
        }
    }   
    
    
    private static void getParticipantName(){
        List<String> externalPersonIds = new List<String>();
        Map<String, String> personIdToPersonRoleMap = new Map<String, String>();
        if (requestBodyObj.participants == null){
            accountName =  'false';
            return;
        }
        for (Integer i = 0; i < requestBodyObj.participants.size(); i++){
            String personId = requestBodyObj.participants[i].person.id;
            externalPersonIds.add(personId);
            personIdToPersonRoleMap.put(personId, requestBodyObj.participants[i].roles[0]);
        }
        String accountNameKey = '';
        for(Account acc : [SELECT Id, ExternalId__c, Name, DocumentNumber__c FROM Account WHERE ExternalId__c IN :externalPersonIds]){
            //accountNameKey = acc.DocumentNumber__c + ' ' + acc.Name + '_' + acc.Id;
            accountNameKey = acc.Name + '_' + acc.Id;
            if (personIdToPersonRoleMap.get(acc.ExternalId__c) == 'PRINCIPAL'){
                break;
            }
        }
        accountName = accountNameKey != '' ? accountNameKey : 'false';      
    }
     
    private static void upsertOpportunity()
    {            
        Opportunity opportunityToUpsert = new Opportunity
        (     
        	Id = [SELECT Id, ExternalId__c FROM Opportunity WHERE ExternalId__c = :requestBodyObj.id]?.Id,
            ExternalId__c = requestBodyObj.id,
        	ExternalVersion__c = Decimal.valueOf(requestBodyObj.version),
        	ExternalTenant__c = requestBodyObj.tenant,       
			Name = accountName.split('_',2)[0],
            AccountId = accountName.split('_',2)[1],           
            StageName = 'Formalização',            
            CloseDate = System.today().addDays(30),                          
        	ExternalCreationDate__c = Date.valueOf(requestBodyObj.createdAt),
        	ExternalUpdatedDate__c = Date.valueOf(requestBodyObj.updateAt)
        ); 
        
        //oppToUpsert = opportunityToUpsert;
        
        try {
            upsert opportunityToUpsert;  
            opportunityId = opportunityToUpsert.Id;  
        } catch (System.DmlException e){
            hasError = true;
            errorMessage = e.getDmlMessage(0);            
            return;
        }      
   }

    private static void upsertQuote(){
        /*if (requestBodyObj.conditions == null || hasError){
            hasError = true;
            return;
        }*/
        //Id opportunityId = oppToUpsert?.Id;

        Quote quoteObject = new Quote();
        quoteObject.Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1]?.Id;
        if (requestBodyObj.conditions.parameters.tac != null){
            quoteObject.ParameterTac__c = Decimal.valueOf(requestBodyObj.conditions.parameters.tac.amount);
        }
        if (requestBodyObj.conditions.parameters.iof != null){
            quoteObject.ParameterIOF__c = Decimal.valueOf(requestBodyObj.conditions.parameters.iof.amount);
        }
        if (requestBodyObj.conditions.parameters.additionalCosts != null){
            quoteObject.ParameterAdditionalCosts__c = Decimal.valueOf(requestBodyObj.conditions.parameters.additionalCosts.amount);
        }
        quoteObject.CreditScore__c = requestBodyObj.conditions.parameters.creditScore;
        quoteObject.GracePeriod__c = requestBodyObj.conditions.parameters.gracePeriod;
        if (requestBodyObj.conditions.parameters.contractDate != null){
            quoteObject.ContractDate__c = Date.valueOf(requestBodyObj.conditions.parameters.contractDate);
        }
        quoteObject.ParameterCalcVersion__c = requestBodyObj.conditions.parameters.calculatorVersion;
        if (requestBodyObj.conditions.limitData != null){
            if (requestBodyObj.conditions.limitData.cetLimit != null){
                quoteObject.LimitCetMinimunc__c = requestBodyObj.conditions.limitData.cetLimit.minimum;
                quoteObject.LimitCetMaximum__c = requestBodyObj.conditions.limitData.cetLimit.maximum;
            }
            if (requestBodyObj.conditions.limitData.interest != null){
                if (requestBodyObj.conditions.limitData.interest.yearlyLimit != null){
                    quoteObject.yearlyLimitMinimunc__c = requestBodyObj.conditions.limitData.interest.yearlyLimit.minimum; 
                    quoteObject.yearlyLimitMaximum__c = requestBodyObj.conditions.limitData.interest.yearlyLimit.maximum;
                }
                if (requestBodyObj.conditions.limitData.interest.monthlyLimit != null){
                    quoteObject.monthlyLimitMinimunc__c = requestBodyObj.conditions.limitData.interest.monthlyLimit.minimum;  
                    quoteObject.monthlyLimitMaximum__c = requestBodyObj.conditions.limitData.interest.monthlyLimit.maximum;
                }
            }           
            quoteObject.LimitTotal__c = requestBodyObj.conditions.limitData.total.amount != null ? Decimal.valueOf(requestBodyObj.conditions.limitData.total.amount) : null;
            quoteObject.LimitInstallmentType__c = requestBodyObj.conditions.limitData.installmentType;
            quoteObject.LimitDueDate__c = requestBodyObj.conditions.limitData.dueDate != null ? Date.valueOf(requestBodyObj.conditions.limitData.dueDate) : null; 
        } 
        if (requestBodyObj.conditions.monthlyInterestRateComposition != null && !requestBodyObj.conditions.monthlyInterestRateComposition.isEmpty()){
            quoteObject.MonthlyIntRateCompType__c = requestBodyObj.conditions.monthlyInterestRateComposition[0].type;
            quoteObject.MonthlyIntRateCompValue__c = requestBodyObj.conditions.monthlyInterestRateComposition[0].value;
        }
        if (requestBodyObj.conditions.netValues != null){
            quoteObject.NetValue__c = requestBodyObj.conditions.netValues.amount != null ? Decimal.valueOf(requestBodyObj.conditions.netValues.amount) : null;
        }
        quoteObject.OpportunityId = opportunityId; 
        quoteObject.Name = accountName.split('_',2)[0] + ' Quote';
        
    
        try {
            upsert quoteObject;
        } catch (System.DmlException e){
            hasError = true;
            errorMessage = e.getDmlMessage(0);            
            return;
        }        
    }
    
    private static void upsertOpportunityRoles(){
        //Id opportunityId = oppToUpsert?.Id;

        Set<String> externalPersonIds = new Set<String>();
        for(OpportunityIntegrationModel.cls_participants participant : requestBodyObj.participants)
        {
            externalPersonIds.add(participant.person.id);
        }
        
        Map<String, OpportunityRole__c> externalPersonIdToOpportunityRoleMap = new Map<String, OpportunityRole__c>();
        for (OpportunityRole__c opportunityRole : [SELECT Id, Opportunity__c, ExternalPersonId__c, ExternalPersonId__r.ExternalId__c, Role__c 
                                                   FROM OpportunityRole__c
                                                   WHERE ExternalPersonId__r.ExternalId__c IN :externalPersonIds 
                                                   AND Opportunity__c = :opportunityId])
        {
			externalPersonIdToOpportunityRoleMap.put(opportunityRole.ExternalPersonId__r.ExternalId__c, opportunityRole);                                                  
        }
        
        Map<String, Account> externalPersonIdToAccountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, ExternalId__c, Name FROM Account WHERE ExternalId__c IN :externalPersonIds])
        {
            externalPersonIdToAccountMap.put(acc.ExternalId__c, acc);
        }

        List<OpportunityRole__c> opportunityRolesToUpsert = new List<OpportunityRole__c>();
        for(OpportunityIntegrationModel.cls_participants participant : requestBodyObj.participants)
        {
            Id oppRoleId = externalPersonIdToOpportunityRoleMap.get(participant.person.id)?.Id;
            Id personId = externalPersonIdToAccountMap.get(participant.person.id)?.Id;
            if (personId == null){
                continue;
            }
            OpportunityRole__c opportunityRoleToUpsert = new OpportunityRole__c
            (         
            	Id = oppRoleId,
            	Role__c = participant.roles[0],                  
            	ExternalPersonId__c = personId,
            	Opportunity__c = opportunityId
            ); 
            
            opportunityRolesToUpsert.add(opportunityRoleToUpsert);
        }

        try {
            upsert opportunityRolesToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            errorMessage = e.getDmlMessage(0);            
            return;
        }      
    }

    public static void insertErrorLog(Integer errorCode){
        API_Transaction_Errors__b ate = new API_Transaction_Errors__b();
        ate.Endpoint__c = '/services/apexrest/IntegrationOpportunity';
        ate.RequestBody__c = requestBody;
        ate.ReturnCode__c = errorCode;
        ate.ErrorMessage__c = errorMessage;
        ate.CreatedDate__c = System.now();
        ate.CreatedBy__c = UserInfo.getUserId();

        try {
            if(!Test.isRunningTest()){
                database.insertImmediate(ate);   
            }         	
        } catch (Exception e) {
            setErrorResponse(500);
        }
    }
   
    
    public static void setErrorResponse(Integer errorCode){
        System.debug(errorMessage);
        Response resp = new Response();       
        resp.opportunityId = null;
        resp.message = String.isNotBlank(errorMessage) ? errorMessage : 'An error has occurred. Please, contact a Salesforce Administrator.';
        resp.status = errorCode;

        RestResponse res = RestContext.response != null ?  RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(resp));
        res.statusCode = errorCode;
    }

    public static void commitTransactions(){
        Boolean varSuccess1 = false, varSuccess2 = false, varSuccess3 = false;

        Savepoint sp = Database.setSavepoint();
        if (!hasError){
            try{
                //upsert oppToUpsert;
                upsertOpportunity();
                if (!hasError){
                	varSuccess1 = true;
                } else {
               		Database.rollback(sp);    
                }
            } catch(Exception e){
                hasError = true;
                errorMessage = e.getMessage();
                Database.rollback(sp); 
            }
            if(varSuccess1){
                try{
                    upsertQuote();
                    if (!hasError){
                    	varSuccess2 = true; 
                    } else {
               			Database.rollback(sp);    
                	}
                } catch(Exception e){
                    hasError = true;
                    errorMessage = e.getMessage();
                    Database.rollback(sp); 
                }
            }
            if(varSuccess2){
                try{ 
                    upsertOpportunityRoles();
                    if (!hasError){
                    	varSuccess3 = true;
                    } else {
               			Database.rollback(sp);    
                	}   
                } catch(Exception e){
                    hasError = true;
                    errorMessage = e.getMessage();
                    Database.rollback(sp); 
                }
            }
        }
    }

    private class Response
    {
        public Integer status;
        public String opportunityId;
        public String message;
    }
    
}