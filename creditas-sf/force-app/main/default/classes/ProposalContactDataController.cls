public with sharing class ProposalContactDataController {

    /*@AuraEnabled(Cacheable=true)
    public static Map<String,CommunicationContacts__c> getCommunicationContact(String accountId){
        try {
            Id validatedAccId = accountId;         
            return ProposalContactDataService.getCommunicationContactFromAccount(validatedAccId);

        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }*/

    @AuraEnabled(Cacheable=true)
    public static ContactDetailsSection__c getContactDetails(String opportunityId){
        try {
            Id validatedOppId = opportunityId;
            return ProposalContactDataService.getContactDetailsSectionFromOpp(validatedOppId);
            
        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    /*@AuraEnabled(Cacheable=false)
    public static void saveCommunicationContacts(List<SObject> listCommunication){
        try {
            List<CommunicationContacts__c> records = (List<CommunicationContacts__c>) listCommunication;
            ProposalContactDataService.upsertCommunicationContacts(records);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    } */

    @AuraEnabled(Cacheable=false)
    public static void saveContactDetailsSection(SObject recordContactDetails) 
    {
        try {
            ContactDetailsSection__c record = (ContactDetailsSection__c) recordContactDetails;
            ProposalContactDataService.upsertContactDetailsSection(record);

        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}