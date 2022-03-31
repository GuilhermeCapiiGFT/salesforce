/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Class that contains the methods for the API call to the Minuator
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           02/02/2022      Created      Class that contains the methods for the API call to the Minuator  
*************************************************************************************************************************************/
public class MinuatorSearchService {
    public static MinuatorSearchResponse getLead(String friendlyId){    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();    
		
        try{
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId=' + friendlyId);  
            request.setMethod('GET');               
            String accessToken = Test.isRunningTest() ? 'test' : getAccessToken();	             
       		request.setHeader('grant_type', 'password');       
            request.setHeader('Content-Type', 'application/json');        
            request.setHeader('X-TENANT-ID', 'creditasbr');               
            request.setHeader('Authorization', 'Bearer ' + accessToken);          
            response = http.send(request);               
	
            if(response.getStatusCode() == 200) {	                
                String responseBodyNumber = response.getBody().replaceAll('\"number\":', '\"numberVo\":');
                JSONParser parser = JSON.createParser(response.getBody());                 
                MinuatorSearchVO results = (MinuatorSearchVO) parser.readValueAs(MinuatorSearchVO.class);              
                MinuatorSearchResponse response200 = new MinuatorSearchResponse();                
                response200.infos = results;
                response200.error = false;
                response200.message = '';
                response200.statusCode = 200;
                return response200; 
            }
                
            else if(response.getStatusCode() == 400){
                MinuatorSearchResponse response400 = new MinuatorSearchResponse();                
                response400.infos = null;
                response400.error = true;
                response400.message = 'Lead does not have credit analysis yet';
                response400.statusCode = 400;
                return response400;    
            }
             else if(response.getStatusCode() == 404){
                MinuatorSearchResponse response404 = new MinuatorSearchResponse();               
                response404.infos = null;
                response404.error = true;
                response404.message = 'Lead not found';
                response404.errorCode = 'lead_not_found_error';
                response404.statusCode = 404;
                return response404;    
            }              
                
            else if(response.getStatusCode() == 500){
                MinuatorSearchResponse response500 = new MinuatorSearchResponse();               
                response500.infos = null;
                response500.error = true;
                response500.message = 'Internal server error';
                response500.statusCode = 500;
                return response500;
               
            }else{          
                MinuatorSearchResponse res = new MinuatorSearchResponse();
                res.infos = null;
                res.error = true;
                res.message = response.getBody();
                res.statusCode = response.getStatusCode();
                return res;
            
            } 
        }catch (Exception e) {             
            MinuatorSearchResponse res = new MinuatorSearchResponse();
                res.infos = null;
                res.error = true;
                res.message = e.getMessage();
                res.statusCode = null;
                return res; 
        	}    
    } 


    public static void getPendingValidationFields(String friendlyId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();    
		
            request.setEndpoint('https://stg-api.creditas.io/home-formalization-service/contracts?friendlyId=' + friendlyId + '/sync');  
            request.setMethod('GET');               
            String accessToken = Test.isRunningTest() ? 'test' : getAccessToken();	             
       		request.setHeader('grant_type', 'password');       
            request.setHeader('Content-Type', 'application/json');        
            request.setHeader('X-TENANT-ID', 'creditasbr');               
            request.setHeader('Authorization', 'Bearer ' + accessToken);          
            response = http.send(request);               
	
            if(response.getStatusCode() == 200) {	                
                System.debug(response.getBody());
            }
    }   

    
    public static String getAccessToken(){            
        Http http = new Http();
        HttpRequest request = new HttpRequest();       

        HttpResponse response = new HttpResponse();        
		TokenAccess returnToken = new TokenAccess();
        
        try{
     		request.setEndpoint('callout:MinuatorCredentials');           
            string createBody = '{ "username" : "{!$Credential.Username}", "password" : "{!$Credential.Password}", "grant_type": "password"}';
 			request.setBody(createBody);
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json'); 
            
           
          	response = http.send(request);
             
            if(response.getStatusCode() == 201) {                   
              	returnToken = (TokenAccess) System.JSON.deserialize(response.getBody(), TokenAccess.class);                 
                return returnToken.access_token;
               
            }else{                
                throw new AuraHandledException('Error to get access token'); 
            }
    
            } catch (Exception e) {    
                 throw new AuraHandledException(e.getMessage());    
            }  
        }

    public class TokenAccess{
        public String access_token {get;set;}
    }    
}