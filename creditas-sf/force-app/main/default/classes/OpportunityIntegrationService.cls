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
        RestResponse res = RestContext.response != null ?  RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = errorCode;
        return res;
    }

    public static Database.upsertResult upsertOpportunity(){   

        Opportunity opportunityToUpsert = new Opportunity();    
        opportunityToUpsert.Id = [SELECT Id, ExternalId__c FROM Opportunity WHERE ExternalId__c = :OpportunityIntegrationController.requestBodyObj.id]?.Id;
        opportunityToUpsert.ExternalId__c = OpportunityIntegrationController.requestBodyObj.id;
        opportunityToUpsert.ExternalVersion__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.version);
        opportunityToUpsert.ExternalTenant__c = OpportunityIntegrationController.requestBodyObj.tenant;
        opportunityToUpsert.Name = accountName.split('_',2)[0];
        opportunityToUpsert.AccountId = accountName.split('_',2)[1];        
        opportunityToUpsert.StageName = 'Formalização';       
        opportunityToUpsert.CloseDate = System.today().addDays(30);                         
        opportunityToUpsert.ExternalCreationDate__c = Date.valueOf(OpportunityIntegrationController.requestBodyObj.createdAt);
        opportunityToUpsert.ExternalUpdatedDate__c = Date.valueOf(OpportunityIntegrationController.requestBodyObj.updateAt);
        opportunityToUpsert.ProductType__c = OpportunityIntegrationController.requestBodyObj.productType;
        opportunityToUpsert.Description = OpportunityIntegrationController.requestBodyObj.purpose;

        opportunityToUpsert.IsExternallySynched__c = true;
        opportunityToUpsert.IsSynchEnabled__c = 'ENABLED';

        if(OpportunityIntegrationController.requestBodyObj.conditions.depositAccount != null){
            opportunityToUpsert.BankCode__c = OpportunityIntegrationController.requestBodyObj.conditions.depositAccount.bankCode;
            opportunityToUpsert.Branch__c = OpportunityIntegrationController.requestBodyObj.conditions.depositAccount.branch;
            opportunityToUpsert.AccountNumber__c = OpportunityIntegrationController.requestBodyObj.conditions.depositAccount.accountNumber;
            opportunityToUpsert.BankAccountType__c = OpportunityIntegrationController.requestBodyObj.conditions.depositAccount.bankAccountType;
        }
              
        Schema.SObjectField oppExternalId = Opportunity.Fields.ExternalId__c;
        
        Database.UpsertResult result = Database.upsert(opportunityToUpsert, oppExternalId, true);  
        return result;
         
    }
    public static void upsertQuote(){
        Quote quoteObject = new Quote();
        quoteObject.Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1]?.Id;

        if(OpportunityIntegrationController.requestBodyObj.conditions.installments != null){
            if(OpportunityIntegrationController.requestBodyObj.conditions.installments.value != null){
                quoteObject.UnitPrice__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.installments.value.amount);
            }
            quoteObject.InstallmentType__c = OpportunityIntegrationController.requestBodyObj.conditions.installments.type;
            quoteObject.Quantity__c = OpportunityIntegrationController.requestBodyObj.conditions.installments.term;
            quoteObject.ServiceDate__c = Date.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.installments.firstDueDate);
            quoteObject.ServiceLastDate__c = Date.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.installments.lastDueDate);
        }

        if(OpportunityIntegrationController.requestBodyObj.conditions.interest != null){
            quoteObject.MonthlyInterest__c =  Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.interest.monthly);
            quoteObject.YearlyInterest__c =  Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.interest.yearly);  
        }

        if(OpportunityIntegrationController.requestBodyObj.conditions.cet != null){
            quoteObject.DailyCet__c = OpportunityIntegrationController.requestBodyObj.conditions.cet.daily;
            quoteObject.MonthlyCet__c = OpportunityIntegrationController.requestBodyObj.conditions.cet.monthly;
            quoteObject.YearlyCet__c = OpportunityIntegrationController.requestBodyObj.conditions.cet.yearly;
        }

        if(OpportunityIntegrationController.requestBodyObj.conditions.parameters != null){
            quoteObject.Term__c = OpportunityIntegrationController.requestBodyObj.conditions.parameters.term;
            quoteObject.UF__c = OpportunityIntegrationController.requestBodyObj.conditions.parameters.uf;
            quoteObject.CreditScore__c = OpportunityIntegrationController.requestBodyObj.conditions.parameters.creditScore;
            quoteObject.GracePeriod__c = OpportunityIntegrationController.requestBodyObj.conditions.parameters.gracePeriod;
            quoteObject.ParameterCalcVersion__c = OpportunityIntegrationController.requestBodyObj.conditions.parameters.calculatorVersion;
            if (OpportunityIntegrationController.requestBodyObj.conditions.parameters.tac != null){
                quoteObject.ParameterTac__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.parameters.tac.amount);
            } 
            if (OpportunityIntegrationController.requestBodyObj.conditions.parameters.iof != null){
                quoteObject.ParameterIOF__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.parameters.iof.amount);
            }
            if (OpportunityIntegrationController.requestBodyObj.conditions.parameters.additionalCosts != null){
                quoteObject.ParameterAdditionalCosts__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.parameters.additionalCosts.amount);
            }
            if(OpportunityIntegrationController.requestBodyObj.conditions.parameters.collateralValue != null){
                quoteObject.CollateralAmount__c = Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.parameters.collateralValue.amount);
            }
            if(OpportunityIntegrationController.requestBodyObj.conditions.parameters.requestedAmount != null){
                quoteObject.RequestedAmount__c = Decimal.valueOf((OpportunityIntegrationController.requestBodyObj.conditions.parameters.requestedAmount.amount));
            }
        }

        if (OpportunityIntegrationController.requestBodyObj.conditions.parameters.contractDate != null){
            quoteObject.ContractDate__c = Date.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.parameters.contractDate);
        }

        if (OpportunityIntegrationController.requestBodyObj.conditions.limitData != null){
            if (OpportunityIntegrationController.requestBodyObj.conditions.limitData.cetLimit != null){
                quoteObject.LimitCetMinimunc__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.cetLimit.minimum;
                quoteObject.LimitCetMaximum__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.cetLimit.maximum;
            }
            if (OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest != null){
                if (OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.yearlyLimit != null){
                    quoteObject.yearlyLimitMinimunc__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.yearlyLimit.minimum; 
                    quoteObject.yearlyLimitMaximum__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.yearlyLimit.maximum;
                }
                if (OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.monthlyLimit != null){
                    quoteObject.monthlyLimitMinimunc__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.monthlyLimit.minimum;  
                    quoteObject.monthlyLimitMaximum__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.interest.monthlyLimit.maximum;
                }
            }      
            if(OpportunityIntegrationController.requestBodyObj.conditions.limitData.total != null){
                quoteObject.LimitTotal__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.total.amount != null ? Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.limitData.total.amount) : null;
            }     
            quoteObject.LimitInstallmentType__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.installmentType;
            quoteObject.LimitDueDate__c = OpportunityIntegrationController.requestBodyObj.conditions.limitData.dueDate != null ? Date.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.limitData.dueDate) : null; 
        } 

        if (OpportunityIntegrationController.requestBodyObj.conditions.monthlyInterestRateComposition != null && !OpportunityIntegrationController.requestBodyObj.conditions.monthlyInterestRateComposition.isEmpty()){
            quoteObject.MonthlyIntRateCompType__c = OpportunityIntegrationController.requestBodyObj.conditions.monthlyInterestRateComposition[0].type;
            quoteObject.MonthlyIntRateCompValue__c = OpportunityIntegrationController.requestBodyObj.conditions.monthlyInterestRateComposition[0].value;
        }

        if (OpportunityIntegrationController.requestBodyObj.conditions.netValues != null){
            quoteObject.NetValue__c = OpportunityIntegrationController.requestBodyObj.conditions.netValues.amount != null ? Decimal.valueOf(OpportunityIntegrationController.requestBodyObj.conditions.netValues.amount) : null;
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
        for(OpportunityIntegrationVO.cls_participants participant : OpportunityIntegrationController.requestBodyObj.participants)
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
        for(OpportunityIntegrationVO.cls_participants participant : OpportunityIntegrationController.requestBodyObj.participants)
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
