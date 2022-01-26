public with sharing class MinuatorSearch {
    @AuraEnabled(cacheable=true)
    public static MinuatorSearchModel minuatorSearch(String leadId){
    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId='+leadId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {                
            MinuatorSearchModel results = (MinuatorSearchModel) JSON.deserialize(response.getBody(),MinuatorSearchModel.class); 
            system.debug('results');
            system.debug(results);

        }
        return new MinuatorSearchModel();
    }    
}