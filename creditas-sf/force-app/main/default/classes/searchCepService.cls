public with sharing class searchCepService {
    public static string getCepFromRest(String cep){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://viacep.com.br/ws/'+cep+'/json/');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        return response.getBody();
    }
}