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
        personalDataRecord.NameStatus__c = 'Aprovar';
        personalDataRecord.CPFStatus__c = 'Rejeitar';
        personalDataRecord.BirthCityStatus__c = 'Aprovar';
        personalDataRecord.BirthCountryStatus__c = 'Aprovar';
        personalDataRecord.BirthDateStatus__c = 'Pendenciar';
        personalDataRecord.NationalityStatus__c = 'Pendenciar';
        personalDataRecord.PoliticallyExposedPersonStatus__c = 'Pendenciar';

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