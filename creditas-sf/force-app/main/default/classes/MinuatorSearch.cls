public with sharing class MinuatorSearch {
    @AuraEnabled(cacheable=true)
    public static String getLead(String leadId){
    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try{
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId='+leadId);
            request.setMethod('GET');
            response = http.send(request);
            
            if(response.getStatusCode() == 200) {                
                MinuatorSearchModel results = (MinuatorSearchModel) JSON.deserialize(response.getBody(),MinuatorSearchModel.class); 
                system.debug('results');
                system.debug(results);        	
        		return response.getBody();
               
            }else{
                return '{ "error" : true, "message" : "' + response.getStatusCode() + ' - ' + response.getBody() + '" }';
            }
    
        } catch (Exception e) {    
             throw new AuraHandledException(e.getMessage());    
        }     
    }   
}