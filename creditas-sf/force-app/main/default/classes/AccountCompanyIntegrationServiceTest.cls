@isTest
private with sharing class AccountCompanyIntegrationServiceTest {
    
    @isTest
    private static void testInsertAndUpdate(){
        
        AccountCompanyIntegrationVO request = AccountCompanyIntegrationVO.parse(AccountCompanyIntegrationVO.jsonMock('success'));
        Test.startTest();
        System.assertEquals(0, [SELECT Count() FROM Account], 'No accounts should exist');
        Database.upsertResult upsertResultCreate = AccountCompanyIntegrationService.upsertCompany(request);
        System.assertEquals(true, upsertResultCreate.isCreated(), 'Account should be created');
        Database.upsertResult upsertResultUpdate = AccountCompanyIntegrationService.upsertCompany(request);
        Test.stopTest();
        System.assertEquals(false, upsertResultUpdate.isCreated(), 'Account should be updated');
        System.assertEquals(1, [SELECT Count() FROM Account], 'Only one account should exist');
    }
}