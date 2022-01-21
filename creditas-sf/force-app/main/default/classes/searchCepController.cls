public with sharing class searchCepController {
    @AuraEnabled(cacheable=true)
    public static String getCepInfo(String cep) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://viacep.com.br/ws/'+cep+'/json/');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        return response.getBody();
    }
}