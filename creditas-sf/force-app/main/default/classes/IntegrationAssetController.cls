@RestResource(urlMapping='/IntegrationAsset/*')
global with sharing class IntegrationAssetController 
{
    @HttpPut
    global static void putMethod()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        String requestBodyString = req.requestBody.toString(); 
        IntegrationAssetVO requestBodyObject = IntegrationAssetVO.parse(requestBodyString);

        if(requestBodyObject.hasError)
        {
            Boolean isLogInserted = InsertLogUtils.insertErrorLog('/services/apexrest/IntegrationAsset', requestBodyString, 500, requestBodyObject.errorMessage);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Invalid JSON format.');
            return;
        }

        Map<String, String> responseMap = IntegrationAssetService.upsertAsset(requestBodyObject);
        Integer statusCode = Integer.valueOf(responseMap.get('statusCode'));

        if(statusCode == 200)
        {
            String assetId = responseMap.get('assetId');
            res.statusCode = statusCode;
            res.responseBody = Blob.valueOf('Asset successfully upserted with id '+assetId);
        } else
        {
            String exceptionMessage = responseMap.get('exceptionMessage');
            String errorMessage = responseMap.get('errorMessage');
    
            Boolean isLogInserted = InsertLogUtils.insertErrorLog('/services/apexrest/IntegrationAsset', requestBodyString, statusCode, exceptionMessage);
            res.statusCode = statusCode;
            res.responseBody = Blob.valueOf(errorMessage);
        }
    }
}