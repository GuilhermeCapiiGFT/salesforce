public with sharing class ProposalIncomeDataService {
    
    @AuraEnabled
    public static IncomeDataSection__c getIncomeDataSection(Id opportunityId)
    {
        List<IncomeDataSection__c> recordsIncomeDataSection = new List<IncomeDataSection__c>();
        recordsIncomeDataSection =    [ SELECT Id, 
                                        ProfessionalSituationStatus__c,
                                        ProfessionalSituationPendingReason__c,
                                        ProfessionalSituationObservation__c,
                                        ProfessionStatus__c,
                                        ProfessionPendingReason__c,
                                        ProfessionObservation__c,
                                        NetWorthStatus__c,
                                        MonthlyIncomeStatus__c,
                                        ReportedIncomePendingReason__c,
                                        MonthlyIncomeObservation__c,
                                        MinimalRequiredIncomeStatus__c,
                                        MinimalRequiredIncomeRejectReason__c,
                                        MinimalRequiredIncomeObservation__c,
                                        PresumedMonthlyIncomeStatus__c,
                                        ConfirmedMonthlyIncomeStatus__c
                                        FROM IncomeDataSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        LIMIT 1];
        
        return recordsIncomeDataSection.isEmpty() ? new IncomeDataSection__c() : recordsIncomeDataSection[0];
    }

    @AuraEnabled
    public static ProfessionalInfo__c getProfession(String accountId)
    {
        List<ProfessionalInfo__c> professionalInfo = new List<ProfessionalInfo__c>();
        professionalInfo = [SELECT Id, Status__c, JobTitle__c FROM ProfessionalInfo__c WHERE Account__c = :accountId LIMIT 1];

        return professionalInfo.isEmpty() ? new ProfessionalInfo__c() : professionalInfo[0];
    }

    @AuraEnabled
    public static Account getAccount(String accountId)
    {           
        return [SELECT Id, NetWorthLowerLimit__c, NetWorthUpperLimit__c FROM Account WHERE Id = :accountId LIMIT 1];
    }

    @AuraEnabled
    public static Map<String, FinancialResources__c> getFinancialResource(String accountId)
    {
        Set<Id> financialResourceIdSet = getFinancialResourcesId(accountId);

        if(financialResourceIdSet.isEmpty()) {
            return new Map<String, FinancialResources__c>();
        } else {
            List<FinancialResources__c> resourceList = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet ORDER BY ExternalUpdatedDate__c DESC];
            Map<String, FinancialResources__c> financialResourcesByType = new Map<String, FinancialResources__c>();

            for(FinancialResources__c financialResource : resourceList)
            {   
                if(String.isNotBlank(financialResource?.Type__c))
                {
                    if(financialResource.Type__c.equals('MONTHLY_INCOME')) {
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } else if(financialResource.Type__c.equals('PRESUMED_MONTHLY_INCOME')) { 
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } else if(financialResource.Type__c.equals('CONFIRMED_MONTHLY_INCOME')) { 
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } 
                }
            }

            return financialResourcesByType;
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId)
    {
        return [SELECT Id, MinimalRequiredIncome__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
    }

    private static Set<Id> getFinancialResourcesId(String accountId) 
    {    
        Set<Id> financialResourceIdSet = new Set<Id>();

        String financialResourceOthersId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');
        
        for(AccountFinancialRelationship__c accFinancialRel : [SELECT Recurso_Financeiro__c, Recurso_Financeiro__r.RecordTypeId FROM AccountFinancialRelationship__c WHERE Account__c = :accountId])
        {
            if(financialResourceOthersId == accFinancialRel.Recurso_Financeiro__r.RecordTypeId)
            {
                financialResourceIdSet.add(accFinancialRel.Recurso_Financeiro__c);
            }
        }

        return financialResourceIdSet;
    }

    public static void saveIncomeSection(Map<String, SObject> records) 
    {
        ProfessionalInfo__c   professionalInfo        = (ProfessionalInfo__c)   records.get('ProfessionalInfo');
        IncomeDataSection__c  validation              = (IncomeDataSection__c)  records.get('IncomeSection');
        Opportunity           minimalRequiredIncome   = (Opportunity)           records.get('MinimalRequiredIncome');
        FinancialResources__c monthlyIncomeInfo       = (FinancialResources__c) records.get('MonthlyIncomeInfo');
        FinancialResources__c presumedMonthlyIncome   = (FinancialResources__c) records.get('PresumedMonthlyIncomeInfo');
        FinancialResources__c confirmedMonthlyIncome  = (FinancialResources__c) records.get('ConfirmedMonthlyIncomeInfo');
        Account               networth                = (Account)               records.get('NetworthIncomeInfo');

        SObjectUtils.upsertRecord(professionalInfo);
        SObjectUtils.upsertRecord(validation);
        SObjectUtils.upsertRecord(minimalRequiredIncome);
        SObjectUtils.upsertRecord(monthlyIncomeInfo);
        SObjectUtils.upsertRecord(presumedMonthlyIncome);
        SObjectUtils.upsertRecord(confirmedMonthlyIncome);
        SObjectUtils.upsertRecord(networth);
    }
}