public with sharing class ProposalOperationService {
    
    @AuraEnabled
    public static OperationSection__c getOperationSectionFromOpp(Id opportunityId){
        
        List<OperationSection__c> recordsOperationSection = new List<OperationSection__c>();
        recordsOperationSection = [ SELECT  Id, 
                                    QuantityRejectReason__c,
                                    QuantityObservation__c,
                                    BranchStatus__c,
                                    AccountStatus__c,
                                    ServiceDateStatus__c,
                                    ServiceLastDateStatus__c,
                                    OperationPurposeStatus__c,
                                    UnitPriceStatus__c,
                                    QuantityStatus__c,
                                    YearlyInterestStatus__c,
                                    MonthlyInterestStatus__c,
                                    AdditionalCostsStatus__c,
                                    ManufacturingYearStatus__c,
                                    BankStatus__c,
                                    YearlyCETstatus__c,
                                    MonthlyCETstatus__c,
                                    BeneficiarysCNPJstatus__c,
                                    ParameterIOFstatus__c,
                                    BeneficiarysNameStatus__c,
                                    ContractNumberStatus__c,
                                    ParameterTACstatus__c,
                                    PatrimonyStatus__c,
                                    CarValueStatus__c,
                                    NetValueStatus__c,
                                    Opportunity__c
                                    FROM OperationSection__c
                                    WHERE Opportunity__c =: opportunityId
                                    LIMIT 1];
        
        return recordsOperationSection.isEmpty() ? new OperationSection__c() : recordsOperationSection[0];
    }

    @AuraEnabled
    public static Quote getQuoteFromOpp(Id opportunityId){
        
        List<Quote> recordsQuote = new List<Quote>();
        recordsQuote = [ SELECT Id, 
                                Description,
                                ParameterAdditionalCosts__c,
                                ParameterTac__c,
                                ParameterIOF__c,
                                MonthlyCet__c,
                                YearlyCet__c,
                                MonthlyInterest__c,
                                YearlyInterest__c,
                                ServiceDate__c,
                                ServiceLastDate__c,
                                NetValue__c,
                                UnitPrice__c,
                                Quantity__c
                                FROM Quote
                                WHERE OpportunityId =: opportunityId
                                LIMIT 1 ];
        
        return recordsQuote.isEmpty() ? new Quote() : recordsQuote[0];
    }
    @AuraEnabled
    public static FinancialResources__c getFinancialFromOpp(String opportunityId){
        String financialResourceAutoId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Auto');
        Set<Id> financialResourceIdSet = new Set<Id>();
        for(Garantias__c garantia : [SELECT Recurso_Financeiro__c,Recurso_Financeiro__r.RecordTypeId FROM Garantias__c WHERE Opportunity__c = :opportunityId]){
            if(financialResourceAutoId == garantia.Recurso_Financeiro__r.RecordTypeId){
                financialResourceIdSet.add(garantia.Recurso_Financeiro__c);
            }
        }
        if(financialResourceIdSet.isEmpty()){
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> resourceList = [SELECT Id, ManufacturingYear__c, Amount__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet ORDER BY ExternalUpdatedDate__c DESC];
            return resourceList[0];
        }
    }
    @AuraEnabled
    public static Account getProponentFromOpp(Id opportunityId){

        Set<Id> proponentIdSet = new Set<Id>();
        for(OpportunityRole__c proponents : [SELECT Id, 
                                                    Role__c, 
                                                    ExternalPersonId__c 
                                                    FROM OpportunityRole__c 
                                                    WHERE Opportunity__c = :opportunityId]){
            if(proponents.Role__c == 'PRINCIPAL'){
                proponentIdSet.clear();
                proponentIdSet.add(proponents.ExternalPersonId__c);
                break;
            }else{
                proponentIdSet.add(proponents.ExternalPersonId__c);
            }
        }
        if(proponentIdSet.isEmpty()){
            return new Account();
        } else {
            List<Account> resourceList = [SELECT    Id, 
                                                    Name, 
                                                    CompanyCNPJ__c, 
                                                    BankName__c, 
                                                    Agency__c, 
                                                    BankAccountNumber__c, 
                                                    NetWorthLowerLimit__c, 
                                                    NetWorthUpperLimit__c
                                                    FROM Account 
                                                    WHERE Id IN :proponentIdSet 
                                                    ORDER BY ExternalUpdatedDate__c DESC];
            return resourceList[0];
        }
    }
}