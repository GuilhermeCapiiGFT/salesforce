public with sharing class searchCepController {
    @AuraEnabled(cacheable=true)
    public static String getCepInfo(String cep) {
        return searchCepService.getCepFromRest(cep);
    }
}