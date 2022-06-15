/**
 * @author Otávio Frank - GFT Brasil
 */
@isTest
public class ProposalIncomeDataControllerTest {

    @isTest
    public static void givenOppIdThenFindLastPersonalDataSection() {

        ProposalIncomeDataController.setIncomeDataSectionRepository( new IncomeDataSectionRepositoryMock() );

        test.startTest();

        IncomeDataSection__c incomeDataSection = ProposalIncomeDataController.getLastIncomeDataSectionInstance('oppId');

        test.stopTest();

        System.assertEquals('APPROVED', incomeDataSection.MinimalRequiredIncomeStatus__c, 'Should have a status');
    }

    @isTest
    public static void givenSerializedIncomeDataSectionThenSave() {

        Account account = TestSetup.getAccount('test', true);
        
        Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id,'AutoFin');
        insert opportunity;

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'APPROVED';
        incomeDataSection.ProfessionStatus__c               = 'APPROVED';
        incomeDataSection.NetWorthStatus__c                 = 'APPROVED';
        incomeDataSection.MonthlyIncomeStatus__c            = 'APPROVED';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'APPROVED';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'APPROVED';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'APPROVED';

        insert incomeDataSection;

        test.startTest();

        incomeDataSection = ProposalIncomeDataController.saveInstance( JSON.serialize(incomeDataSection));

        test.stopTest();

        System.assertEquals( true , String.isNotBlank(incomeDataSection.Id), 'Should have an Id');
    }

    public class IncomeDataSectionRepositoryMock extends IncomeDataSectionRepository {

        private IncomeDataSection__c incomeDataSection;

        public IncomeDataSectionRepositoryMock( ) {

            String payload = '{"attributes":{"type":"IncomeDataSection__c","url":"/services/data/v51.0/sobjects/IncomeDataSection__c/a0T030000012nXZEAY"},"Status__c":"CLT","MinimalRequiredIncomeStatus__c":"APPROVED","ConfirmedMonthlyIncomeStatus__c":"APPROVED"}';
            this.incomeDataSection = ( IncomeDataSection__c ) JSON.deserialize( payload, IncomeDataSection__c.class );

        }

        override
        public List<IncomeDataSection__c> findLastIncomeDataSectionByOppId (String oppId ) {
            return new List<IncomeDataSection__c> { this.incomeDataSection };
        }
    }
}