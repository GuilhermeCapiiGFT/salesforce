public with sharing class ProposalIncomeDataController {
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, SObject> getIncomeDetails(String accountId, String opportunityId)
    {
        try {
            Map<String, SObject> incomeInfoByName = new Map<String, SObject>();

            IncomeDataSection__c validationInfo   = ProposalIncomeDataService.getIncomeDataSection(opportunityId);
            ProfessionalInfo__c professionalInfo  = ProposalIncomeDataService.getProfession(accountId);
            Opportunity opportunityInfo           = ProposalIncomeDataService.getOpportunity(opportunityId);
            Account accountInfo                   = ProposalIncomeDataService.getAccount(accountId);
            Map<String, FinancialResources__c> financialResourceByName = ProposalIncomeDataService.getFinancialResource(accountId);

            incomeInfoByName.put('INCOME_SECTION', validationInfo);
            incomeInfoByName.put('PROFESSIONAL_SECTION', professionalInfo);
            incomeInfoByName.put('MINIMAL_INCOME', opportunityInfo);
            incomeInfoByName.put('NETWORTH_INCOME', accountInfo);
            if(financialResourceByName.get('MONTHLY_INCOME') != null)           incomeInfoByName.put('MONTHLY_INCOME', financialResourceByName.get('MONTHLY_INCOME'));
            if(financialResourceByName.get('PRESUMED_MONTHLY_INCOME') != null)  incomeInfoByName.put('PRESUMED_MONTHLY_INCOME', financialResourceByName.get('PRESUMED_MONTHLY_INCOME'));
            if(financialResourceByName.get('CONFIRMED_MONTHLY_INCOME') != null) incomeInfoByName.put('CONFIRMED_MONTHLY_INCOME', financialResourceByName.get('CONFIRMED_MONTHLY_INCOME'));
            
            return incomeInfoByName;
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveIncomeDataSection(Map<String, SObject> records)
    {
        SavePoint sp = Database.setSavePoint();
        try {
            ProposalIncomeDataService.saveIncomeSection(records);
        } catch(Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}