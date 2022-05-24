/**
 * @author Otávio Frank - GFT Brasil
 */
public with sharing class ProposalIncomeDataController {
    
    public static IncomeDataSectionRepository repository;

    static {
        
        repository = new IncomeDataSectionRepository();
    }

    @AuraEnabled
    public static IncomeDataSection__c getLastIncomeDataSectionInstance( String oppId ) {

        try {

            List<IncomeDataSection__c> lastIncomeDataSection = repository.findLastIncomeDataSectionByOppId( oppId );

            return ( lastIncomeDataSection.isEmpty() ) ? null : lastIncomeDataSection[0];

        } catch (Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled
    public static IncomeDataSection__c saveInstance( String serializedIncomeDataSection ) {

        IncomeDataSection__c incomeDataSectionToSave;

        try {

            incomeDataSectionToSave = ( IncomeDataSection__c ) System.JSON.deserialize( serializedIncomeDataSection, IncomeDataSection__c.class);

            incomeDataSectionToSave.Id = null;

            incomeDataSectionToSave = ( IncomeDataSection__c ) repository.save( incomeDataSectionToSave );

        } catch (Exception e) {

            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }

        return incomeDataSectionToSave;
    }

    public static void setIncomeDataSectionRepository( IncomeDataSectionRepository repo ) {
        repository = repo;
    }
}