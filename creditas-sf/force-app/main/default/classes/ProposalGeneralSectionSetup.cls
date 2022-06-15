@isTest
public with sharing class ProposalGeneralSectionSetup extends DataBuilder{
    public ProposalGeneralSectionSetup(Opportunity opp, String externalId) {
        this.setRecord(
            new GeneralSection__c(
                Opportunity__c = opp.Id,
                GeneralSectionExternalIdAtWork__c = externalId,
                GeneralDataObservation__c = 'observation'
            )
        );
        this.setIterableFields(new String[]{ 'Name', 'GeneralDataObservation__c' });
    }
    public GeneralSection__c createGeneralSection(Map<String, Object> sObjectOpts, Boolean doInsert){
        return (GeneralSection__c) this.createSObject(sobjectOpts, doInsert);
    }
    public List<GeneralSection__c> createGeneralSections(Map<String, Object> sObjectOpts, Integer qtd, Boolean doInsert){
        return (List<GeneralSection__c>) this.createSObjects(sobjectOpts, qtd, doInsert);
    }
}