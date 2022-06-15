@isTest
public class OpportunityRepositoryTest {
    
    @TestSetup
    static void makeData(){

        Account account = TestSetup.getAccount('test', true);
        
        Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id,'AutoFin');
        insert opportunity;
    }

    @isTest
    public static void givenOppIdThenFindRecord() {

        OpportunityRepository repository = new OpportunityRepository();

        Test.startTest();

        Opportunity opp = [ SELECT ID FROM opportunity LIMIT 1 ];

        Opportunity oppResult = repository.findById(opp.Id);

        Test.stopTest();

        System.assertEquals(opp.Id, oppResult.Id, 'Should have the same Id');
    }

    @isTest
    public static void givenInvalidOppIdThenTrowAnException() {

        OpportunityRepository repository = new OpportunityRepository();

        Test.startTest();

        String exceptionMessage;

        try {

            Opportunity oppResult = repository.findById('DUMMY_ID');

        } catch (Exception ex) {
            
            exceptionMessage = ex.getMessage();
        }
       
        Test.stopTest();

        System.assert( String.isNotBlank(exceptionMessage) , 'Should have an exception message');
    }
}