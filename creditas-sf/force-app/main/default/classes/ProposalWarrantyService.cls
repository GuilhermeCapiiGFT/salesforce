public with sharing class ProposalWarrantyService {
    
    public static FinancialResources__c getGuarantee(String opportunityId){
        String financialResourceId = [SELECT Recurso_Financeiro__c FROM Garantias__c WHERE Opportunity__c = :opportunityId WITH SECURITY_ENFORCED]?.Recurso_Financeiro__c;
        if(String.isBlank(financialResourceId)){
            return new FinancialResources__c();
        } else {
            return [SELECT ResourceKey__c,Plate__c,ModelYear__c,ManufacturingYear__c,Brand__c,Model__c,Color__c,LicensingState__c,State__c,ExternalCodeOrigin__c FROM FinancialResources__c WHERE Id = :financialResourceId WITH SECURITY_ENFORCED];
        }
    }
}
