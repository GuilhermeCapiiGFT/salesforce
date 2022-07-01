@isTest
public class FinancialResourcesRepositoryTest {
    
    @TestSetup
    static void makedata() {

        FinancialResources__c finResource = FinancialResourceSetup.createFinancialResource('Auto');
        insert finResource;
    }

    @isTest
    static void givenSetIdsThenFindFinancialResourecesRecords() {

        FinancialResourcesRepository repo = new FinancialResourcesRepository();

        Test.startTest();

        FinancialResources__c finResource = [ SELECT ID FROM FinancialResources__c LIMIT 1 ];

        List<FinancialResources__c> results = repo.findByIds( new Set<Id>{finResource.Id} );

        Test.stopTest();

        System.assertEquals( results.size(), 1, 'Should have one record recovered');
    }

    @isTest
    static void givenSetIdsThenTrowAndException() {

        FinancialResourcesRepository repo = new FinancialResourcesRepository();

        Test.startTest();

        String exceptionMessage;

        try {

            List<FinancialResources__c> results = repo.findByIds( new Set<Id>{'DUMMY_ID'} );
            
        } catch (Exception ex) {
            exceptionMessage = ex.getMessage();
        }

        Test.stopTest();

        System.assert( String.isNotBlank(exceptionMessage) , 'Should have an exception message');
    }

}