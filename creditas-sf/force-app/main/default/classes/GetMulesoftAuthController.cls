public with sharing class GetMulesoftAuthController {
    public static HTTPResponse getAuth(){
        Http httpAuth = new Http();
        HTTPRequest httpReq = GetMulesoftAuthService.generateRequest();
        return httpAuth.send(httpReq);
    }
}