public with sharing class ProposalIncomeDataService {
    
    // @AuraEnabled
    // public static List<Addresses__c> getAddress(Id accountId) {
        
    //     List<Addresses__c> recordInfo = new List<Addresses__c>();

    //     for(Addresses__c address : [SELECT Id, Street__c, Country__c, AreaLevel1__c, AreaLevel2__c, Neighborhood__c, PostalCode__c, Complement__c, StreetNumber__c
    //                                 FROM Addresses__c 
    //                                 WHERE Account__c =: accountId 
    //                                 ORDER BY CreatedDate asc LIMIT 1])
    //     {
    //         recordInfo.add(address);
    //     }

    //     return recordInfo;
    // }

    @AuraEnabled
    public static IncomeDataSection__c getIncomeDataSection(Id opportunityId){
        
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
}