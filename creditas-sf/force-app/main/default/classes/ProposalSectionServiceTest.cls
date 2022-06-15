@isTest
public with sharing class ProposalSectionServiceTest {
    @TestSetup
    static void makeData(){
        Account acc = TestSetup.getAccount('Julio Iglesias', true);
        Opportunity opp = TestSetup.getOpportunity(acc.Id, false);
        opp.Name = 'genera-data-sectionopp-test';
        insert opp;
        ProposalGeneralSectionSetup setup = new ProposalGeneralSectionSetup(opp, 'general-data-section');
        GeneralSection__c section = setup.createGeneralSection(null, true);
    }
    @IsTest
    static void testGetSection(){
        Opportunity opp = [
            SELECT Id FROM Opportunity WHERE Name = 'genera-data-sectionopp-test'
        ];
        ProposalSectionService service = new ProposalSectionService();
        List<String> fields = new List<String> {'Name', 'GeneralDataObservation__c', 'Opportunity__c'};
        List<GeneralSection__c> section = (List<GeneralSection__c>) service.getLastSection(opp.Id, 'GeneralSection__c', fields, 'Opportunity__c');
        System.assert(!section.isEmpty(), 'List is Empty');
        System.assertEquals(section.get(0).Opportunity__c, opp.Id, 'Ids dont match ');
    }
    @IsTest
    static void testSaveSection(){
        Opportunity opp = [
            SELECT Id FROM Opportunity WHERE Name = 'genera-data-sectionopp-test'
        ];
        ProposalSectionService service = new ProposalSectionService();
        List<String> fields = new List<String> {'Name', 'GeneralDataObservation__c', 'Opportunity__c'};
        List<GeneralSection__c> section = (List<GeneralSection__c>) service.getLastSection(opp.Id, 'GeneralSection__c', fields, 'Opportunity__c');
        String jsonString = '{'+
                '"GeneralSection__c" : {'+
                    '"Id": "' + section.get(0).Id + '",'+
                    '"GeneralDataObservation__c":"observation 2"' +
                '}'+
        '}';
        Test.startTest();
        service.saveSection((Map<String, Object>) JSON.deserializeUntyped(jsonString));
        Test.stopTest();
        GeneralSection__c newSection = [
            SELECT Id, GeneralDataObservation__c FROM GeneralSection__c WHERE GeneralSectionExternalIdAtWork__c = 'general-data-section'
        ];
        System.assert(newSection != null, 'Section was not created');
        System.assertEquals(newSection.GeneralDataObservation__c,  'observation 2', 'observation was not updated');
    }
}