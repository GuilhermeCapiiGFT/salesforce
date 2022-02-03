public class MinuatorSearchService {
    public static String getLead(String friendlyId){    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();        
        
        try{
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId=' + friendlyId);             
            request.setMethod('GET');			           
            String accessToken = getAccessToken();            
       	    request.setHeader('grant_type', 'password');                  
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('X-TENANT-ID', 'creditasbr');          
            request.setHeader('Authorization', 'Bearer ' + accessToken);           
            
            response = http.send(request);
            System.debug(JSON.deserializeUntyped(response.getBody()));

            if(response.getStatusCode() == 200) {	
                String responseBodyNumber = response.getBody().replaceAll('\"number\":', '\"numberVo\":');
                JSONParser parser = JSON.createParser(response.getBody());                 
                MinuatorSearchVO results = (MinuatorSearchVO) parser.readValueAs(MinuatorSearchVO.class);            
                return response.getBody();               
               
            }else{            
                return '{ "error" : true, "message" : "' + response.getStatusCode() + ' - ' + response.getBody() + '" }';
            }
    
        } catch (Exception e) {    
            throw new AuraHandledException(e.getMessage());    
        }     
    }   
    public static String getAccessToken(){            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();        
	TokenAccess returnToken = new TokenAccess();
        
        try{
            request.setEndpoint('https://auth-staging.creditas.com.br/api/consultants/tokens');
            request.setMethod('POST');                     
      	    request.setHeader('grant_type', 'password'); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Cookie', '__cf_bm=X4J6ojMX0YK2yrGzHRcTPqlXDs_Nw1BgwL9UQ6TI0kU-1643395420-0-AXc5X0C5yIJaYODpoKDNOq6CMMJCXiFEdP3QpTcRgtRhzKTHZxo0r8mlqH+2/vVrKtb4ar80XcC8g28C5RhLRII=');
            request.setBody('{"grant_type": "password", "username": "consultor@creditas.com.br", "password": "tamuMaech7xa9thu"}');
 
            response = http.send(request);
            
            if(response.getStatusCode() == 201) {                
             
            	returnToken = (TokenAccess) System.JSON.deserialize(response.getBody(), TokenAccess.class);               
                return returnToken.access_token;
               
            }else{
                return '{ "error" : true, "message" : "' + response.getStatusCode() + ' - ' + response.getBody() + '" }';
            }
    
            } catch (Exception e) {    
                 throw new AuraHandledException(e.getMessage());    
            }  
        }

    public class TokenAccess{
        public String access_token {get;set;}
    }    
}
