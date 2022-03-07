@isTest
public class ProposalControllerTest {

    @isTest
    private static void getReasonTest(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('PersonalDataSection__c','CNHnumberPendingReason__c');
        Test.stopTest();

        System.assertNotEquals('[]', returnReason, 'Should have returned String');
    }

    @isTest
    private static void getReasonWithParamsBlank(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('', '');
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }
    
    @isTest
    private static void getReasonObjectError(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('abc','def');   
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }
    
    @isTest
    private static void getReasonFieldError(){
        String returnReason;
        Test.startTest();
            returnReason = ProposalController.getReason('PersonalDataSection__c','def');   
        Test.stopTest();
        System.assertEquals('[]', returnReason, 'Should have returned empty list');
    }
}