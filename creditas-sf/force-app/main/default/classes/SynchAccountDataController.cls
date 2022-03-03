public with sharing class SynchAccountDataController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(String accountId) {
        try{
            return SynchAccountDataService.queryAccountData(accountId);         
        } catch (Exception e){
            System.debug(e.getCause() + ' - ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static void checkSynchingField(Account acc) {
        SynchAccountDataService.updateSynchingField(acc);
    }
}