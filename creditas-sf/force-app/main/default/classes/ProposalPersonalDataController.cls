public with sharing class ProposalPersonalDataController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, SObject> getInfoRecords(String recordId) 
    {   
        try {
            Id validatedOppId = recordId;
            return ProposalPersonalDataService.getPersonalDataSectionRecord(validatedOppId);
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, SObject> getDocuments(String recordId)
    {
        try {
            Id validatedAccountId = recordId;
            return ProposalPersonalDataService.getDocuments(validatedAccountId);
        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}