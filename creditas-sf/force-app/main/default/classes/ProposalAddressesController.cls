public with sharing class ProposalAddressesController {

    @AuraEnabled(Cacheable=true)
    public static List<Addresses__c> getAddress(String accountId){
        try {
            Id validatedAccId = accountId;         
            return ProposalAddressesService.getAddress(validatedAccId);

        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=true)
    public static AddressDataSection__c getAddressSectiontDetails(String opportunityId){
        try {
            Id validatedOppId = opportunityId;
            return ProposalAddressesService.getAddressDataSection(validatedOppId);
            
        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveAddress(List<Addresses__c> addresses){
        try {
            SObjectUtils.upsertRecords(addresses);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveAddressSection(AddressDataSection__c addressSection){
        try {
            SObjectUtils.upsertRecord(addressSection);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}