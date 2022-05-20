public with sharing class ProposalAddressesController {

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
    public static void saveAddressSection(AddressDataSection__c addressSection){
        try {
            SObjectUtils.upsertRecord(addressSection);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}