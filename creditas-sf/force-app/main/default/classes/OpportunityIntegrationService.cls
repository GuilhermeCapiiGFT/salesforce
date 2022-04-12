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
    private static Map<String,String> mapPersonIdAccountName = new Map<String,String>();
    public static String opportunityId;

    private static final String HOME_REFIN = 'HOME_REFIN';
    private static final String AUTO_FIN = 'AUTO_FIN';
    private static final String ATWORK = 'PAYROLL';

    private static Map<String,String> mapStageName = new Map<String,String>{
                                                            ATWORK => 'Novo',
                                                            HOME_REFIN => 'Emissão e Pré-Assinatura',
                                                            AUTO_FIN => 'Crédito'
                                                        };
 
    public static Map<String, String> getPersonIdAndAccountName(List<OpportunityIntegrationVO.cls_participants> participantsList){
        
        String personId = 'NON_EXISTANT';
        for(OpportunityIntegrationVO.cls_participants participant : participantsList){
            for(String partRole : participant.roles){
                if(partRole == 'PRINCIPAL'){
                    personId = participant.person.id;
                    break;
                }
            }
        }

        String accountName = [SELECT Name FROM Account WHERE ExternalId__c = :personId WITH SECURITY_ENFORCED]?.Name;

        if(accountName != null){
            mapPersonIdAccountName.put('accountName', accountName);
            mapPersonIdAccountName.put('personId', personId);
        }
        return mapPersonIdAccountName;
    }

    public static RestResponse setResponse(Response response, Integer errorCode){
        RestResponse res = RestContext.response != null ?  RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = errorCode;
        return res;
    }
    
    public static Database.upsertResult upsertOpportunity(OpportunityIntegrationVO requestBodyObj){

        String externalId = requestBodyObj?.id;
        Map<String,String> recordTypeProductMap = createRTProductMap(requestBodyObj?.productType);
        String oppRecordTypeId = selectOppRecordTypeId(recordTypeProductMap.get('recordType'));
        String oppStageName;
        
        if(HOME_REFIN == recordTypeProductMap.get('recordType') || AUTO_FIN ==  recordTypeProductMap.get('recordType') || ATWORK ==  recordTypeProductMap.get('recordType') ){
            oppStageName = [SELECT StageName FROM Opportunity WHERE ExternalId__c = :externalId]?.StageName;
        }
        Opportunity opportunityToUpsert = new Opportunity(

            ExternalId__c = externalId,
            ExternalVersion__c = getDecimalValue(requestBodyObj?.version),
            ExternalTenant__c = requestBodyObj?.tenant,
            Name = mapPersonIdAccountName.get('accountName'),
            Account = new Account(ExternalId__c = mapPersonIdAccountName.get('personId')),
            StageName = oppStageName == null ? mapStageName.get(recordTypeProductMap.get('recordType')) : oppStageName,
            CloseDate = Date.today().addDays(30),
            RecordTypeId = oppRecordTypeId,
            ExternalCreationDate__c = getDateValue(requestBodyObj?.createdAt),
            ExternalUpdatedDate__c = getDateValue(requestBodyObj?.updateAt),
            ProductType__c = recordTypeProductMap.get('productType'),
            Description = requestBodyObj.purpose,
            IsExternallySynched__c = true,
            IsSynchEnabled__c = 'ENABLED',
            BankCode__c = requestBodyObj.conditions?.depositAccount?.bankCode,
            Branch__c = requestBodyObj.conditions?.depositAccount?.branch,
            AccountNumber__c = requestBodyObj.conditions?.depositAccount?.accountNumber,
            BankAccountType__c = requestBodyObj.conditions?.depositAccount?.bankAccountType
        );
          
        Schema.SObjectField oppExternalId = Opportunity.Fields.ExternalId__c;
        Database.UpsertResult result = Database.upsert(opportunityToUpsert, oppExternalId, false);
        return result;
        
    }

    public static Database.upsertResult upsertQuote(OpportunityIntegrationVO requestBodyObj){
        String montlhyType;
        Double monthlyValue;
        
        if(requestBodyObj.conditions?.monthlyInterestRateComposition != null && !requestBodyObj.conditions?.monthlyInterestRateComposition.isEmpty()){
            montlhyType = requestBodyObj.conditions?.monthlyInterestRateComposition[0]?.type;
            monthlyValue = requestBodyObj.conditions?.monthlyInterestRateComposition[0]?.value;
        }

        Quote quoteObject = new Quote(

            UnitPrice__c = getDecimalValue(requestBodyObj.conditions?.installments?.value?.amount),
            InstallmentType__c = requestBodyObj.conditions?.installments?.type,
            Quantity__c = requestBodyObj.conditions?.installments?.term,
            ServiceDate__c = getDateValue(requestBodyObj.conditions?.installments?.firstDueDate),
            ServiceLastDate__c = getDateValue(requestBodyObj.conditions?.installments?.lastDueDate),
            MonthlyInterest__c =  getDecimalValue(requestBodyObj.conditions?.interest?.monthly),
            YearlyInterest__c =  getDecimalValue(requestBodyObj.conditions?.interest?.yearly),  
            DailyCet__c = requestBodyObj.conditions?.cet?.daily,
            MonthlyCet__c = requestBodyObj.conditions?.cet?.monthly,
            YearlyCet__c = requestBodyObj.conditions?.cet?.yearly,
            Term__c = requestBodyObj.conditions?.parameters?.term,
            UF__c = requestBodyObj.conditions?.parameters?.uf,
            CreditScore__c = requestBodyObj.conditions?.parameters?.creditScore,
            GracePeriod__c = requestBodyObj.conditions?.parameters?.gracePeriod,
            ParameterCalcVersion__c = requestBodyObj.conditions?.parameters.calculatorVersion,           
            ParameterTac__c = getDecimalValue(requestBodyObj.conditions?.parameters?.tac?.amount),
            ParameterIOF__c = getDecimalValue(requestBodyObj.conditions?.parameters?.iof?.amount),        
            ParameterAdditionalCosts__c = getDecimalValue(requestBodyObj.conditions?.parameters?.additionalCosts?.amount),     
            CollateralAmount__c = getDecimalValue(requestBodyObj.conditions?.parameters?.collateralValue?.amount),        
            RequestedAmount__c = getDecimalValue((requestBodyObj.conditions?.parameters?.requestedAmount?.amount)),
            ContractDate__c = getDateValue(requestBodyObj.conditions?.parameters?.contractDate), 
            LimitCetMinimunc__c = requestBodyObj.conditions?.limitData?.cetLimit?.minimum,
            LimitCetMaximum__c = requestBodyObj.conditions?.limitData?.cetLimit?.maximum,
            yearlyLimitMinimunc__c = requestBodyObj.conditions?.limitData?.interest?.yearlyLimit?.minimum, 
            yearlyLimitMaximum__c = requestBodyObj.conditions?.limitData?.interest?.yearlyLimit?.maximum,
            monthlyLimitMinimunc__c = requestBodyObj.conditions?.limitData?.interest?.monthlyLimit?.minimum,  
            monthlyLimitMaximum__c = requestBodyObj.conditions?.limitData?.interest?.monthlyLimit?.maximum,
            LimitTotal__c = getDecimalValue(requestBodyObj.conditions?.limitData?.total?.amount), 
            LimitInstallmentType__c = requestBodyObj.conditions?.limitData?.installmentType,
            LimitDueDate__c = getDateValue(requestBodyObj.conditions?.limitData?.dueDate), 
            MonthlyIntRateCompType__c = montlhyType,
            MonthlyIntRateCompValue__c = getDecimalValue(monthlyValue),
            NetValue__c = getDecimalValue(requestBodyObj?.conditions?.netValues?.amount),
            OpportunityId = opportunityId, 
            Name = mapPersonIdAccountName.get('accountName') + ' Quote'
        );
        
        quoteObject.Id = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1]?.Id;
        
        Database.upsertResult upsertQuote = Database.upsert(quoteObject, false);
        return upsertQuote;
    }
    
    public static List<Database.upsertResult> upsertOpportunityRoles(OpportunityIntegrationVO requestBodyObj){
        Set<String> externalPersonIds = new Set<String>();
        for(OpportunityIntegrationVO.cls_participants participant : requestBodyObj.participants)
        {
            externalPersonIds.add(participant.person.id);
        }
        
        Map<String, OpportunityRole__c> externalPersonIdToOpportunityRoleMap = new Map<String, OpportunityRole__c>();

        for (OpportunityRole__c opportunityRole : [SELECT Id, ExternalPersonId__r.ExternalId__c 
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
            Id personId = externalPersonIdToAccountMap.get(participant.person.id)?.Id;
            if (personId != null){
                
                OpportunityRole__c opportunityRoleToUpsert = new OpportunityRole__c (         
                    Id = externalPersonIdToOpportunityRoleMap.get(participant.person.id)?.Id,
                    Role__c = participant.roles[0],                  
                    ExternalPersonId__c = personId,
                    Opportunity__c = opportunityId
                ); 
                opportunityRolesToUpsert.add(opportunityRoleToUpsert);

                }

        }

        List<Database.upsertResult> upsertOppRole = Database.upsert(opportunityRolesToUpsert, false);
        return upsertOppRole;  
    }
    @TestVisible
    private static Date getDateValue(String dateString){
        return String.isBlank(dateString) ? null : Date.valueOf(dateString);
    }
    @TestVisible
    private static Decimal getDecimalValue(String stringValue){
        return String.isBlank(stringValue) ? null : Decimal.valueOf(stringValue);
    }
    @TestVisible
    private static Decimal getDecimalValue(Integer integerValue){
        return integerValue == null ? null : Decimal.valueOf(integerValue);
    }
    @TestVisible
    private static Decimal getDecimalValue(Double doubleValue){
        return doubleValue == null ? null : Decimal.valueOf(doubleValue);
    }

    private static Map<String,String> createRTProductMap(String stringInput){

        List<String> splittedString = stringInput.replace('REQUESTING','PAYROLL_LOAN').split('/');
        Map<String,String> RecordTypeProductMap = new Map<String,String>();

        RecordTypeProductMap.put('recordType',splittedString.remove(0));

        if( splittedString.contains('REGULAR') && splittedString.size() > 1){
            RecordTypeProductMap.put('productType',splittedString.remove(1));
        } else if(!splittedString.isEmpty()){
            RecordTypeProductMap.put('productType',splittedString.remove(0));
        }
        return RecordTypeProductMap;
    }

    private static String selectOppRecordTypeId(String recordTypeDevName){
        String oppRTId = '';
        if(recordTypeDevName == HOME_REFIN){
            oppRTId = Util.getRecordTypeIdbyName('Opportunity', 'Home');
        } else if(recordTypeDevName == AUTO_FIN){
            oppRTId = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        } else {
            oppRTId = Util.getRecordTypeIdbyName('Opportunity', 'AtWork');
        }
        return oppRTId; 
    }
}