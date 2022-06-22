@isTest
private with sharing class EventAssignmentTest {
    private static Set<String> externalIdSet = new Set<String>();
    private static final String ATWORK_PROFILE = '[ATWORK] Analista de operações de formalização';
    private static final String AUTOFIN_PROFILE = '[AUTOFIN] F Analista I';
    private static final String APPROVED_BY_HR = 'Aprovado por RH';
    private static final String AWAITING_ANALYSIS = 'Aguardando Análise de Formalização';
    private static final String AWAITING_DISTRIBUTION = 'Aguardando Distribuição de Formalização';

    @TestSetup
    static void makeData(){
        List<Opportunity> oppList = createOppsWithDifferentAccounts(3);
        insert oppList;

    }
    
    @isTest
    private static void testUpdateAtWork(){
        List<Opportunity> oppList = [SELECT id, StageName, OwnerId, ExternalId__c FROM Opportunity WHERE RecordType.DeveloperName = 'AtWork'];
        List<User> userList = TestSetup.getUsers(3, ATWORK_PROFILE, true);
        Set<String> newUserIdSet = new Set<String>();
        for(User u : userList){
            newUserIdSet.add(u.Id);
        }
        User runningUser = userList[0];
        List<opportunityAssignment__e> eventList = new List<opportunityAssignment__e>();

        for(Opportunity opp : oppList){

            opportunityAssignment__e e = new opportunityAssignment__e(
                ExternalId__c = opp.ExternalId__c,
                OwnerId__c = userList.remove(0).Id,
                StageName__c = AWAITING_ANALYSIS
            );

            eventList.add(e);
            
            if(userList.isEmpty()){
                break;
            }
        }
        Test.startTest();
            System.runAs(runningUser){
                Eventbus.publish(eventList);
            }
        Test.stopTest();

        String currentUserId = UserInfo.getUserId();
        String atWorkRTId = Util.getRecordTypeIdbyName('Opportunity', 'AtWork');
        for(Opportunity opp : [SELECT Id, StageName, OwnerId, RecordTypeId FROM Opportunity]){
            if(opp.RecordTypeId == atWorkRTId){
                System.assertEquals(AWAITING_ANALYSIS, opp.StageName, 'StageName was not updated');
                System.assert(newUserIdSet.contains(opp.OwnerId), 'Owner of the opp was not updated');
            } else {
                System.assertEquals(AWAITING_DISTRIBUTION, opp.StageName, 'StageName was wrongly updated');
                System.assertEquals(currentUserId, opp.OwnerId, 'Owner of the opp was wrongly updated');
            }
        }
    }

    @isTest
    private static void testUpdateAutoFin(){
        List<Opportunity> oppList = [SELECT id, StageName, OwnerId, ExternalId__c FROM Opportunity WHERE RecordType.DeveloperName = 'AutoFin'];
        List<User> userList = TestSetup.getUsers(3, AUTOFIN_PROFILE, true);
        Set<String> newUserIdSet = new Set<String>();
        for(User u : userList){
            newUserIdSet.add(u.Id);
        }
        User runningUser = userList[0];
        List<opportunityAssignment__e> eventList = new List<opportunityAssignment__e>();

        for(Opportunity opp : oppList){

            opportunityAssignment__e e = new opportunityAssignment__e(
                ExternalId__c = opp.ExternalId__c,
                OwnerId__c = userList.remove(0).Id,
                StageName__c = AWAITING_ANALYSIS
            );

            eventList.add(e);
            
            if(userList.isEmpty()){
                break;
            }
        }
        Test.startTest();
            System.runAs(runningUser){
                Eventbus.publish(eventList);
            }
        Test.stopTest();

        String currentUserId = UserInfo.getUserId();
        String autoFinId = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        for(Opportunity opp : [SELECT Id, StageName, OwnerId, RecordTypeId FROM Opportunity]){
            if(opp.RecordTypeId == autoFinId){
                System.assertEquals(AWAITING_ANALYSIS, opp.StageName, 'StageName was not updated');
                System.assert(newUserIdSet.contains(opp.OwnerId), 'Owner of the opp was not updated');
            } else {
                System.assertEquals(APPROVED_BY_HR, opp.StageName, 'StageName was wrongly updated');
                System.assertEquals(currentUserId, opp.OwnerId, 'Owner of the opp was wrongly updated');
            }
        }
    }

    @isTest
    private static void testUpdateBothRecordtypes(){
        List<Opportunity> oppList = [SELECT id, StageName, OwnerId, ExternalId__c, RecordtypeId FROM Opportunity];
        String autoFinId = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');

        List<User> userList = new List<User>();
        List<User> autoFinUserList = TestSetup.getUsers(3, AUTOFIN_PROFILE, true);
        List<User> atWorkUserList = TestSetup.getUsers(3, ATWORK_PROFILE, true);
        userList.addAll(autoFinUserList);
        userList.addAll(atWorkUserList);
        Set<String> newUserIdSet = new Set<String>();
        for(User u : userList){
            newUserIdSet.add(u.Id);
        }
        User runningUser = userList[0];

        List<opportunityAssignment__e> eventList = new List<opportunityAssignment__e>();

        for(Opportunity opp : oppList){
            opportunityAssignment__e e = new opportunityAssignment__e();
            if(opp.RecordTypeId == autoFinId){
                e.ExternalId__c = opp.ExternalId__c;
                e.OwnerId__c = autoFinUserList.remove(0).Id;
                e.StageName__c = AWAITING_ANALYSIS;
            } else {
                e.ExternalId__c = opp.ExternalId__c;
                e.OwnerId__c = atWorkUserList.remove(0).Id;
                e.StageName__c = AWAITING_ANALYSIS;
            }
            eventList.add(e);
        }

        Test.startTest();
            System.runAs(runningUser){
                Eventbus.publish(eventList);
            }
        Test.stopTest();

        String currentUserId = UserInfo.getUserId();
        for(Opportunity opp : [SELECT Id, StageName, OwnerId, RecordTypeId FROM Opportunity]){
           
            System.assertEquals(AWAITING_ANALYSIS, opp.StageName, 'StageName was not updated');
            System.assert(newUserIdSet.contains(opp.OwnerId), 'Owner of the opp was not updated');
            
        }
    }

    @isTest
    private static void testUpdateBothRecordtypesBULK(){
        List<Opportunity> oppListBase = [SELECT id, StageName, OwnerId, ExternalId__c, RecordtypeId FROM Opportunity];
        List<Opportunity> oppList = createOppsWithDifferentAccounts(97);
        insert oppList;
        oppList.addAll(oppListBase);
        String autoFinId = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');

        List<User> userList = new List<User>();
        List<User> autoFinUserList = TestSetup.getUsers(100, AUTOFIN_PROFILE, true);
        List<User> atWorkUserList = TestSetup.getUsers(100, ATWORK_PROFILE, true);
        userList.addAll(autoFinUserList);
        userList.addAll(atWorkUserList);
        Set<String> newUserIdSet = new Set<String>();
        for(User u : userList){
            newUserIdSet.add(u.Id);
        }
        User runningUser = userList[0];

        List<opportunityAssignment__e> eventList = new List<opportunityAssignment__e>();

        for(Opportunity opp : oppList){
            opportunityAssignment__e e = new opportunityAssignment__e();
            if(opp.RecordTypeId == autoFinId){
                e.ExternalId__c = opp.ExternalId__c;
                e.OwnerId__c = autoFinUserList.remove(0).Id;
                e.StageName__c = AWAITING_ANALYSIS;
            } else {
                e.ExternalId__c = opp.ExternalId__c;
                e.OwnerId__c = atWorkUserList.remove(0).Id;
                e.StageName__c = AWAITING_ANALYSIS;
            }
            eventList.add(e);
        }

        Test.startTest();
            System.runAs(runningUser){
                Eventbus.publish(eventList);
            }
        Test.stopTest();

        String currentUserId = UserInfo.getUserId();
        for(Opportunity opp : [SELECT Id, StageName, OwnerId, RecordTypeId FROM Opportunity]){
           
            System.assertEquals(AWAITING_ANALYSIS, opp.StageName, 'StageName was not updated');
            System.assert(newUserIdSet.contains(opp.OwnerId), 'Owner of the opp was not updated');
            
        }
    }

    private static List<Opportunity> createOppsWithDifferentAccounts(Integer numberOfOpps){
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 1; i <= numberOfOpps*2; i++){
            accList.add(AccountSetup.createAccount('Matilda von ' + i, 'Pessoa_Fisica'));
        }
        insert accList;
        integer n = 1;
        for(Account acc : accList){
            if(n <= numberOfOpps){
                Opportunity opp = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
                opp.ExternalId__c = generateRandomExternalId();
                opp.StageName = APPROVED_BY_HR;
                oppList.add(opp);
            } else {
                Opportunity opp = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
                opp.ExternalId__c = generateRandomExternalId();
                opp.StageName = AWAITING_DISTRIBUTION;
                oppList.add(opp);
            }
            n++;
        }
        return oppList;
    }

    private static String generateRandomExternalId(){
        String oppExternalId = Util.generateRandomString(15);
        if(externalIdSet.contains(oppExternalId)){
            generateRandomExternalId();
        } else {
            externalIdSet.add(oppExternalId);
        }
        return oppExternalId;
    }
}