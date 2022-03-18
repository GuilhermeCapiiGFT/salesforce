@isTest
private with sharing class InsertLogUtilsTest {
    
    @isTest
    private static void coverageTest(){
        Test.startTest();
        Boolean response = insertLogUtils.insertErrorLog('endPoint', 'requestBody', 0, 'errorMessage');
        Test.stopTest();
        System.assertEquals(false, response, 'Response should be false');
    }
}