public with sharing class OpportunityIntegrationService {
    public class OpportunityIntegrationException extends Exception {
    }

    public class Response{
        public Integer statusCode;
        public String opportunityId;
        public String message;
        public Response(Integer statusCode, String oppId, String message){
            this.statusCode = statusCode;
            this.opportunityId = oppId;
            this.message = message;
        }
    }

    public static Map<String, String> getPersonIdAndAccountName(List<OpportunityIntegrationVO.cls_participants> participantsList){
        
        Map<String, String> newMap = new Map<String, String>();
        String personId;
        for(OpportunityIntegrationVO.cls_participants participant : participantsList){
            for(String partRole : participant.roles){
                if(partRole == 'PRINCIPAL'){
                    personId = participant.person.id;
                    newMap.put('personId', personId);
                    break;
                }
            }
        }

        accountName = [SELECT Name FROM Account WHERE ExternalId__c = :personId WITH SECURITY_ENFORCED]?.Name;

        if(accountName != null){
            newMap.put('accountName', accountName);
        }

        return newMap; 
    }

    public static RestResponse setResponse(Response response, Integer errorCode){
        //String errorResponse = String.isBlank(errorMessage) ? 'An error has occurred. Please, contact a Salesforce Administrator.' : errorMessage;
        RestResponse res = RestContext.response != null ?  RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = errorCode;
        return res;
    }

    public static Boolean upsertOpportunity(){   

        Opportunity opportunityToUpsert = new Opportunity();    
        opportunityToUpsert.Id = [SELECT Id, ExternalId__c FROM Opportunity WHERE ExternalId__c = :requestBodyObj.id]?.Id;
        opportunityToUpsert.ExternalId__c = requestBodyObj.id;
        opportunityToUpsert.ExternalVersion__c = Decimal.valueOf(requestBodyObj.version);
        opportunityToUpsert.ExternalTenant__c = requestBodyObj.tenant;
        opportunityToUpsert.Name = accountName.split('_',2)[0];
        opportunityToUpsert.AccountId = accountName.split('_',2)[1];        
        opportunityToUpsert.StageName = 'Formalização';       
        opportunityToUpsert.CloseDate = System.today().addDays(30);                         
        opportunityToUpsert.ExternalCreationDate__c = Date.valueOf(requestBodyObj.createdAt);
        opportunityToUpsert.ExternalUpdatedDate__c = Date.valueOf(requestBodyObj.updateAt);
        opportunityToUpsert.ProductType__c = requestBodyObj.productType;
        opportunityToUpsert.Description = requestBodyObj.purpose;

        opportunityToUpsert.IsExternallySynched__c = true;
        opportunityToUpsert.IsSynchEnabled__c = 'ENABLED';

        if(requestBodyObj.conditions.depositAccount != null){
            opportunityToUpsert.BankCode__c = requestBodyObj.conditions.depositAccount.bankCode;
            opportunityToUpsert.Branch__c = requestBodyObj.conditions.depositAccount.branch;
            opportunityToUpsert.AccountNumber__c = requestBodyObj.conditions.depositAccount.accountNumber;
            opportunityToUpsert.BankAccountType__c = requestBodyObj.conditions.depositAccount.bankAccountType;
        }
              
        try {
            upsert opportunityToUpsert;  
            opportunityId = opportunityToUpsert.Id;  
        } catch (System.DmlException e){
            hasError = true;
            errorMessage = e.getDmlMessage(0);            
            return;
        }      
    }
    public static void upsertQuote(){
        Quote quoteObject = new Quote();
        quoteObject.Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1]?.Id;

        if(requestBodyObj.conditions.installments != null){
            if(requestBodyObj.conditions.installments.value != null){
                quoteObject.UnitPrice__c = Decimal.valueOf(requestBodyObj.conditions.installments.value.amount);
            }
            quoteObject.InstallmentType__c = requestBodyObj.conditions.installments.type;
            quoteObject.Quantity__c = requestBodyObj.conditions.installments.term;
            quoteObject.ServiceDate__c = Date.valueOf(requestBodyObj.conditions.installments.firstDueDate);
            quoteObject.ServiceLastDate__c = Date.valueOf(requestBodyObj.conditions.installments.lastDueDate);
        }

        if(requestBodyObj.conditions.interest != null){
            quoteObject.MonthlyInterest__c =  Decimal.valueOf(requestBodyObj.conditions.interest.monthly);
            quoteObject.YearlyInterest__c =  Decimal.valueOf(requestBodyObj.conditions.interest.yearly);  
        }

        if(requestBodyObj.conditions.cet != null){
            quoteObject.DailyCet__c = requestBodyObj.conditions.cet.daily;
            quoteObject.MonthlyCet__c = requestBodyObj.conditions.cet.monthly;
            quoteObject.YearlyCet__c = requestBodyObj.conditions.cet.yearly;
        }

        if(requestBodyObj.conditions.parameters != null){
            quoteObject.Term__c = requestBodyObj.conditions.parameters.term;
            quoteObject.UF__c = requestBodyObj.conditions.parameters.uf;
            quoteObject.CreditScore__c = requestBodyObj.conditions.parameters.creditScore;
            quoteObject.GracePeriod__c = requestBodyObj.conditions.parameters.gracePeriod;
            quoteObject.ParameterCalcVersion__c = requestBodyObj.conditions.parameters.calculatorVersion;
            if (requestBodyObj.conditions.parameters.tac != null){
                quoteObject.ParameterTac__c = Decimal.valueOf(requestBodyObj.conditions.parameters.tac.amount);
            } 
            if (requestBodyObj.conditions.parameters.iof != null){
                quoteObject.ParameterIOF__c = Decimal.valueOf(requestBodyObj.conditions.parameters.iof.amount);
            }
            if (requestBodyObj.conditions.parameters.additionalCosts != null){
                quoteObject.ParameterAdditionalCosts__c = Decimal.valueOf(requestBodyObj.conditions.parameters.additionalCosts.amount);
            }
            if(requestBodyObj.conditions.parameters.collateralValue != null){
                quoteObject.CollateralAmount__c = Decimal.valueOf(requestBodyObj.conditions.parameters.collateralValue.amount);
            }
            if(requestBodyObj.conditions.parameters.requestedAmount != null){
                quoteObject.RequestedAmount__c = Decimal.valueOf((requestBodyObj.conditions.parameters.requestedAmount.amount));
            }
        }

        if (requestBodyObj.conditions.parameters.contractDate != null){
            quoteObject.ContractDate__c = Date.valueOf(requestBodyObj.conditions.parameters.contractDate);
        }

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
            if(requestBodyObj.conditions.limitData.total != null){
                quoteObject.LimitTotal__c = requestBodyObj.conditions.limitData.total.amount != null ? Decimal.valueOf(requestBodyObj.conditions.limitData.total.amount) : null;
            }     
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
    
    public static void upsertOpportunityRoles(){
        Set<String> externalPersonIds = new Set<String>();
        for(OpportunityIntegrationVO.cls_participants participant : requestBodyObj.participants)
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
        for(OpportunityIntegrationVO.cls_participants participant : requestBodyObj.participants)
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
}
