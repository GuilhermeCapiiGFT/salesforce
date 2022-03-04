@isTest
private with sharing class InvocableClearCacheTest {
    @isTest
    private static void testRemoveCache(){
        
        Test.startTest();
        InvocableClearCacheController.clearAtWorkOrgCache();
        Map<String,String> accountUserIdMap = (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId') == null ? new Map<String,String>() : (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId');
        System.assert(accountUserIdMap.isEmpty(), 'should have returned an empty map');
        accountUserIdMap.put('hello','world');
        Cache.Org.put('local.atWorkAssignment.mapUserAccountId', accountUserIdMap, 43200, Cache.Visibility.ALL, false);


        Map<String,String> accountUserIdMap2 = (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId') == null ? new Map<String,String>() : (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId');
        System.assert(!accountUserIdMap.isEmpty(), 'should have returned a map with at least one key');
        accountUserIdMap2.put('hello2','world2');
        Cache.Org.put('local.atWorkAssignment.mapUserAccountId', accountUserIdMap2, 43200, Cache.Visibility.ALL, false);
        
        InvocableClearCacheController.clearAtWorkOrgCache();
        Test.stopTest();
        Map<String,String> nullMap = (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId');
        System.assert(nullMap == null, 'Map should be null as cache as cleared');
        
    }
}