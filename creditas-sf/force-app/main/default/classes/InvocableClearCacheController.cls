public with sharing class InvocableClearCacheController {

    @InvocableMethod(label='getAtWorkOrgCache')
    public static void clearAtWorkOrgCache(){
        InvocableClearCacheService.clearAtWorkAssignmentCache();
    }

}