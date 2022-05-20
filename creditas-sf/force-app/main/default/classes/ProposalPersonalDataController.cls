public with sharing class ProposalPersonalDataController {
    
    public static PersonalDataSectionRepository repository;

    static {
        repository = new PersonalDataSectionRepository();
    }

    @AuraEnabled
    public static PersonalDataSection__c getLastPersonalDataSectionInstance( String oppId ) {

        try {

            List<PersonalDataSection__c> personalDataSection = repository.findLastPersonalDataSectionByOppId( oppId );

            return ( personalDataSection.isEmpty() ) ? null : personalDataSection[0];

        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled
    public static string saveInstance( String personalDataSectionInstance ) {

        PersonalDataSection__c record = ( PersonalDataSection__c ) System.JSON.deserialize( personalDataSectionInstance, PersonalDataSection__c.class);

        return System.JSON.serialize(record );
    }
}