/**
 * @author Otávio Frank - GFT Brasil
 */
public virtual class IncomeDataSectionRepository extends Repository {

    virtual
    public List<IncomeDataSection__c> findLastIncomeDataSectionByOppId( String oppId ) {

        return [ SELECT  Name, CurrencyIsoCode, CreatedDate, ProfessionalSituationStatus__c, 
                         ProfessionalSituationObservation__c, JobTitle__c, 
                         ConfirmedMonthlyIncome__c, ProfessionStatus__c, 
                         ProfessionObservation__c, PresumedMonthlyIncome__c, 
                         MonthlyIncome__c, NetWorthStatus__c, MinimalRequiredIncome__c, 
                         Status__c, MonthlyIncomeStatus__c, MonthlyIncomeObservation__c, 
                         NetWorth__c, MinimalRequiredIncomeStatus__c, MinimalRequiredIncomeObservation__c, 
                         PresumedMonthlyIncomeStatus__c, ConfirmedMonthlyIncomeStatus__c, 
                         MinimalRequiredIncomeRejectReason__c, ProfessionalSituationPendingReason__c, 
                         ProfessionPendingReason__c, ReportedIncomePendingReason__c, Opportunity__c
                FROM IncomeDataSection__c
                WHERE Opportunity__c =: oppId
                ORDER BY CreatedDate DESC limit 1 ];
    }
}