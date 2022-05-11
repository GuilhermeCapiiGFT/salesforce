public with sharing class InvocableClearCacheService {
    public static void clearAtWorkAssignmentCache(){
        Cache.Org.getPartition('local.atWorkAssignment').remove('AtWorkUserAccountIdMap');
        Cache.Org.getPartition('local.atWorkAssignment').remove('AutoFinUserAccountIdMap');
    }

}