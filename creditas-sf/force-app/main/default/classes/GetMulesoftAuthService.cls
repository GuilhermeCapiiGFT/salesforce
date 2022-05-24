public with sharing class GetMulesoftAuthService {
    public static HTTPRequest generateRequest(){
        HTTPRequest httpReq = new HTTPRequest();
        httpReq.setEndpoint('callout:getAuth');
        httpReq.setHeader('client_id', '{!$Credential.Username}');
        httpReq.setHeader('client_secret', '{!$Credential.Password}');
        httpReq.setMethod('POST');
        httpReq.setBody('grant_type=client_credentials');
        httpReq.setTimeout(12000);
        return httpReq;
    }
}