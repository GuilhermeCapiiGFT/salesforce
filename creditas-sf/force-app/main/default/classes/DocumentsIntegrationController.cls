public with sharing class DocumentsIntegrationController {
    
    public static String getDocumentsList(String oppExternalId, String productType){
        
        HTTP http = new HTTP();
    	HTTPRequest httpReq = new HTTPRequest();
        string queryParams = '?loanAppId=' + oppExternalId + '&productType=' + productType;
		httpReq.setEndpoint('callout:documentsIntegration' + queryParams);
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setMethod('GET');
		httpReq.setTimeout(12000);

		HTTPResponse httpAuthRes = http.send(httpReq);

		if(httpAuthRes.getStatusCode() == 200){
			return httpAuthRes.getBody();
		} else {
			return 'Error';
		}
    }
}