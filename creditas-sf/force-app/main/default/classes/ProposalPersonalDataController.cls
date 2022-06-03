/**
 * @author Otávio Frank - GFT Brasil
 */
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
    public static PersonalDataSection__c saveInstance( String serializedPersonalDataSection ) {

        PersonalDataSection__c personalDataSection;

        try {

            personalDataSection = ( PersonalDataSection__c ) System.JSON.deserialize( serializedPersonalDataSection, PersonalDataSection__c.class);

            personalDataSection = ( PersonalDataSection__c ) repository.save( personalDataSection );

        } catch (Exception e) {

            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }

        return personalDataSection;
    }

    public static void setPersonalDataSectionRepository(PersonalDataSectionRepository repo) {
        repository = repo;
    }
}