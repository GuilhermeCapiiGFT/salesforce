/**
 * @author Otávio Frank - GFT Brasil
 */
@isTest
public class IncomeDataSectionRepositoryTest {
    
    @TestSetup
    static void makeData(){

        Account account = TestSetup.getAccount('test', true);
        
        Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id,'AutoFin');
        insert opportunity;
    }

    @isTest
    public static void givenOpportunityIdFindLastIncomeDataSection() {

        IncomeDataSectionRepository repo = new incomeDataSectionRepository();

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Approved';
        incomeDataSection.ProfessionStatus__c               = 'Approved';
        incomeDataSection.NetWorthStatus__c                 = 'Approved';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Approved';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Approved';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Approved';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Approved';

        insert incomeDataSection;

        Test.startTest();

        List<IncomeDataSection__c> lastIncomeDataSection = repo.findLastIncomeDataSectionByOppId(opportunity.Id);
        
        Test.stopTest();

        System.assertEquals( 1 , lastIncomeDataSection.size(), 'Should have 1 incomeDataSection record' );
    }

    @isTest
    public static void givenListOfIncomeDataSectionThenSave() {

        IncomeDataSectionRepository repo = new incomeDataSectionRepository();

        Test.startTest();

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Approved';
        incomeDataSection.ProfessionStatus__c               = 'Approved';
        incomeDataSection.NetWorthStatus__c                 = 'Approved';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Approved';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Approved';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Approved';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Approved';

        List<IncomeDataSection__c> lastIncomeDataSection = (List<IncomeDataSection__c>) repo.save( new List<IncomeDataSection__c>{ incomeDataSection });
        
        Test.stopTest();

        System.assertEquals( true , String.IsNotBlank( lastIncomeDataSection[0].Id ), 'Should have 1 record with Id' );
    }

    @isTest
    public static void givenListOfIncomeDataSectionThenDelete() {

        IncomeDataSectionRepository repo = new incomeDataSectionRepository();

        Test.startTest();

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Approved';
        incomeDataSection.ProfessionStatus__c               = 'Approved';
        incomeDataSection.NetWorthStatus__c                 = 'Approved';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Approved';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Approved';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Approved';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Approved';

        List<IncomeDataSection__c> lastIncomeDataSection = (List<IncomeDataSection__c>) repo.save( new List<IncomeDataSection__c>{ incomeDataSection });
        
        System.assertEquals( true , String.IsNotBlank( lastIncomeDataSection[0].Id ), 'Should have 1 record with Id' );

        repo.remove( lastIncomeDataSection );

        List<IncomeDataSection__c> result = repo.findLastIncomeDataSectionByOppId(opportunity.Id);

        Test.stopTest();

        System.assertEquals( true , result.isEmpty() , 'The list must be empty' );

    }

    @isTest
    public static void givenAnIncomeDataSectionThenSave() {

        IncomeDataSectionRepository repo = new incomeDataSectionRepository();

        Test.startTest();

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Approved';
        incomeDataSection.ProfessionStatus__c               = 'Approved';
        incomeDataSection.NetWorthStatus__c                 = 'Approved';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Approved';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Approved';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Approved';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Approved';

        incomeDataSection = (IncomeDataSection__c) repo.save( incomeDataSection );
        
        Test.stopTest();

        System.assertEquals( true , String.IsNotBlank( incomeDataSection.Id ), 'The record must have an Id' );
    }

    @isTest
    public static void givenAnIncomeDataSectionThenDelete() {

        IncomeDataSectionRepository repo = new incomeDataSectionRepository();

        Test.startTest();

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Approved';
        incomeDataSection.ProfessionStatus__c               = 'Approved';
        incomeDataSection.NetWorthStatus__c                 = 'Approved';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Approved';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Approved';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Approved';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Approved';

        incomeDataSection = (IncomeDataSection__c) repo.save( incomeDataSection );

        System.assertEquals( true , String.IsNotBlank( incomeDataSection.Id ), 'The record must have an Id' );

        repo.remove( incomeDataSection );

        List<IncomeDataSection__c> lastIncomeDataSection = repo.findLastIncomeDataSectionByOppId(opportunity.Id);

        Test.stopTest();

        System.assertEquals( true , lastIncomeDataSection.isEmpty() , 'The list must be empty' );

    }

}