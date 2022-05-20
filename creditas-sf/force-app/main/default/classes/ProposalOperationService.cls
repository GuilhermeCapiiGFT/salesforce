public with sharing class ProposalOperationService {
    
    @AuraEnabled
    public static OperationSection__c getOperationSectionFromOpp(Id opportunityId){
        
        return [SELECT  Id, Agency__c, PartnerAccount__c, DocumentNumber__c, ManufacturingYear__c, BankName__c, YearlyCet__c, MonthlyCet__c, 
                        BankAccountNumber__c, ServiceDate__c, Description__c, ParameterIOF__c, UnitPrice__c, CollateralAmount__c, Quantity__c, 
                        ParameterTac__c, YearlyInterest__c, MonthlyInterest__c, Amount__c, NetValue__c, ServiceLastDate__c, ParameterAdditionalCosts__c, 
                        QuantityRejectReason__c, BranchStatus__c, AccountStatus__c, ServiceDateStatus__c, ServiceLastDateStatus__c, PatrimonyStatus__c,
                        OperationPurposeStatus__c, UnitPriceStatus__c, QuantityStatus__c, YearlyInterestStatus__c, MonthlyInterestStatus__c, 
                        AdditionalCostsStatus__c, ManufacturingYearStatus__c, BankStatus__c, YearlyCETstatus__c, MonthlyCETstatus__c,
                        BeneficiarysCNPJstatus__c, ParameterIOFstatus__c, BeneficiarysNameStatus__c, ContractNumberStatus__c, ParameterTACstatus__c, 
                        CarValueStatus__c, NetValueStatus__c
                        FROM OperationSection__c
                        WHERE Opportunity__c =: opportunityId
                        ORDER BY CreatedDate DESC
                        LIMIT 1];
    }

    public static void saveRecord(OperationSection__c record){
        SObjectUtils.upsertRecord(record);
    }
}