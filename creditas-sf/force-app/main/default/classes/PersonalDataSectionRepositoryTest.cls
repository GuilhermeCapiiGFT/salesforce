/**
 * @author Otávio Frank - GFT Brasil
 */
@isTest
public class PersonalDataSectionRepositoryTest {

    @TestSetup
    static void makeData(){

        Account account = TestSetup.getAccount('test', true);
        
        Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id,'AutoFin');
        insert opportunity;

        PersonalDataSection__c personalDataRecord = new PersonalDataSection__c();
        personalDataRecord.Opportunity__c = opportunity.Id;
        personalDataRecord.NameStatus__c = 'Approved';
        personalDataRecord.CPFStatus__c = 'Rejected';
        personalDataRecord.BirthCityStatus__c = 'Approved';
        personalDataRecord.BirthCountryStatus__c = 'Approved';
        personalDataRecord.BirthDateStatus__c = 'Pending';
        personalDataRecord.NationalityStatus__c = 'Pending';
        personalDataRecord.PoliticallyExposedPersonStatus__c = 'Pending';

        insert personalDataRecord;
    }

    @isTest
    public static void givenOppIdThenFindLastPersonalDataSection() {

        Opportunity opportunity = [ SELECT ID FROM Opportunity LIMIT 1 ];

        PersonalDataSectionRepository repo = new PersonalDataSectionRepository();

        test.startTest();

        List<PersonalDataSection__c> lastPersonalDataSection = repo.findLastPersonalDataSectionByOppId( opportunity.Id );

        test.stopTest();

        System.assertEquals(1, lastPersonalDataSection.size() , 'Should have 1 personalDataSection record');
    }
}