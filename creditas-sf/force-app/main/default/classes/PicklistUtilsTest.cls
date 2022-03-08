@isTest
private with sharing class PicklistUtilsTest {

    @isTest
    private static void getReasonTest(){
        List<PicklistUtils.PicklistWrapper> returnReason = new List<PicklistUtils.PicklistWrapper>();
        Test.startTest();
            returnReason = PicklistUtils.getPickListValuesWrapped('Account', 'Gender__c');
        Test.stopTest();

        System.assertEquals(false, returnReason.isEmpty(), 'List should not be empty');
    }

    @isTest
    private static void getReasonWithParamsBlank(){
		List<PicklistUtils.PicklistWrapper> returnReason = new List<PicklistUtils.PicklistWrapper>();
        Test.startTest();
            returnReason = PicklistUtils.getPickListValuesWrapped('', '');
        Test.stopTest();
        System.assertEquals(true, returnReason.isEmpty(), 'List should be empty');
    }
    
    @isTest
    private static void getReasonObjectError(){
		List<PicklistUtils.PicklistWrapper> returnReason = new List<PicklistUtils.PicklistWrapper>();
        Test.startTest();
        	returnReason = PicklistUtils.getPickListValuesWrapped('abc','def');   
        Test.stopTest();
        System.assertEquals(true, returnReason.isEmpty(), 'List should be empty');
    }
    
    @isTest
    private static void getReasonFieldError(){
		List<PicklistUtils.PicklistWrapper> returnReason = new List<PicklistUtils.PicklistWrapper>();
        Test.startTest();
        	returnReason = PicklistUtils.getPickListValuesWrapped('PersonalDataSection__c','def');   
        Test.stopTest();
        System.assertEquals(true, returnReason.isEmpty(), 'List should not be empty');
    }
    
}