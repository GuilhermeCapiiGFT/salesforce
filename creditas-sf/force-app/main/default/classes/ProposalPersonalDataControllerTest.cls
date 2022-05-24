/**
 * @author Otávio Frank - GFT Brasil
 */
@isTest
public class ProposalPersonalDataControllerTest {

    @isTest
    public static void givenOppIdThenFindLastPersonalDataSection() {

        ProposalPersonalDataController.setPersonalDataSectionRepository( new PersonalDataSectionRepositoryMock() );

        test.startTest();

        PersonalDataSection__c personalDataSection = ProposalPersonalDataController.getLastPersonalDataSectionInstance('oppId');

        test.stopTest();

        System.assertEquals('Aprovar', personalDataSection.RGStatus__c, 'Should have a status');
    }

    @isTest
    public static void givenSerializedPersonalDataSectionThenSave() {

        Account account = TestSetup.getAccount('test', true);
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Teste';
        opportunity.StageName = 'Novo';
        opportunity.CloseDate = Date.today().addDays(5);
        opportunity.ExternalTenant__c = 'creditasbr';
        opportunity.ExternalVersion__c = 1;
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

        test.startTest();

        PersonalDataSection__c personalDataSection = ProposalPersonalDataController.saveInstance( JSON.serialize(personalDataRecord));

        test.stopTest();

        System.assertEquals( true , String.isNotBlank(personalDataSection.Id), 'Should have an Id');
    }

    public class PersonalDataSectionRepositoryMock extends PersonalDataSectionRepository {

        private PersonalDataSection__c personalDataSection;

        public PersonalDataSectionRepositoryMock( ) {

            String payload = '{"attributes":{"type":"PersonalDataSection__c","url":"/services/data/v51.0/sobjects/PersonalDataSection__c/a0K03000001GCQ7EAO"},"Id":"a0K03000001GCQ7EAO","RGobservation__c":null,"RGPendingReason__c":null,"RGRejectReason__c":null,"Opportunity__c":"00603000007pZh6AAE","RGStatus__c":"Aprovar","CPFStatus__c":"Aprovar","CPFPendingReason__c":null}';
            this.personalDataSection = ( PersonalDataSection__c ) JSON.deserialize( payload, PersonalDataSection__c.class );

        }

        override
        public List<PersonalDataSection__c> findLastPersonalDataSectionByOppId (String oppId ) {
            return new List<PersonalDataSection__c> { this.personalDataSection };
        }
    }

}