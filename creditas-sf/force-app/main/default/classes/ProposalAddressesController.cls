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
    public static void saveAddress(List<SObject> listAddress){
        try {
            List<Addresses__c> records = (List<Addresses__c>) listAddress;
            ProposalAddressesService.upsertAddress(records);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveAddressSection(SObject recordAddressSection) 
    {
        try {
            AddressDataSection__c record = (AddressDataSection__c) recordAddressSection;
            ProposalAddressesService.upsertAddressSection(record);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}