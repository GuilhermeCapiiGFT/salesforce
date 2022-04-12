public with sharing class ProposalIncomeDataController {
    
    // @AuraEnabled(Cacheable=true)
    // public static List<Addresses__c> getAddress(String accountId){
    //     try {
    //         Id validatedAccId = accountId;         
    //         return ProposalAddressesService.getAddress(validatedAccId);

    //     } catch (Exception e) {
    //         throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    //     }
    // }

    @AuraEnabled(Cacheable=true)
    public static IncomeDataSection__c getIncomeDataSectiontDetails(String opportunityId){
        try {
            Id validatedOppId = opportunityId;
            return ProposalIncomeDataService.getIncomeDataSection(validatedOppId);
            
        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    // @AuraEnabled(Cacheable=false)
    // public static void saveAddress(List<Addresses__c> addresses){
    //     try {
    //         SObjectUtils.upsertRecords(addresses);

    //     } catch(Exception e) {
    //         throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    //     }
    // }

    @AuraEnabled(Cacheable=false)
    public static void saveIncomeDataSection(IncomeDataSection__c incomeDataSection){
        try {
            SObjectUtils.upsertRecord(incomeDataSection);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}