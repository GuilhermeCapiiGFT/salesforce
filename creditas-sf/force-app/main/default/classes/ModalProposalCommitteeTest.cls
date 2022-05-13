@isTest
private with sharing class ModalProposalCommitteeTest {
    @TestSetup
    static void makeData(){
        Account acc = AccountSetup.createAccount('Petrificus Totallus', 'Pessoa_Fisica');
        insert acc;
        Opportunity opp = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        insert opp;        
    }

    @isTest
    private static void testUpdateOppMethod(){
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.CommitteeObservation__c = 'New Observation for Test';
        opp.CommitteeReason__c = 'OTHER';
        opp.CommitteeOtherReason__c = 'Some other reason';
        Test.startTest();
            Boolean updateSuccess = ModalProposalCommitteeController.updateOpportunityCommittee(opp);
        Test.stopTest();
        Opportunity oppAfterUpdate = [SELECT CommitteeObservation__c,CommitteeReason__c,CommitteeOtherReason__c FROM Opportunity];
        System.assertEquals('New Observation for Test', oppAfterUpdate.CommitteeObservation__c, 'CommitteeObservation__c was not updated');
        System.assertEquals('OTHER', oppAfterUpdate.CommitteeReason__c, 'CommitteeReason__c was not updated');
        System.assertEquals('Some other reason', oppAfterUpdate.CommitteeOtherReason__c, 'CommitteeOtherReason__c was not updated');
        System.assert(updateSuccess, 'Should be true');

    }

    @isTest
    private static void testUpdateFailed(){
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.StageName = null;
        opp.AccountId = null;

        Test.startTest();
            Boolean updateSuccess = ModalProposalCommitteeController.updateOpportunityCommittee(opp);
        Test.stopTest();
        
        System.assert(!updateSuccess, 'Update should have faileld');
    }

    @isTest
    private static void testGetListView(){
        Test.startTest();
        String myListViewId = ModalProposalCommitteeController.getMyOpportunitiesListView();
        Test.stopTest();
        System.assert(String.isNotBlank(myListViewId), 'return should not be null');
    }
}