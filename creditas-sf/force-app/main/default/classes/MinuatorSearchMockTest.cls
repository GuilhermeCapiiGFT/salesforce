@isTest
global with sharing class MinuatorSearchMockTest implements HttpCalloutMock { 
    
    public Integer statusCode;
        
    public MinuatorSearchMockTest(Integer statusCode){
        this.statusCode = statusCode;
    }
    
    global HTTPResponse respond(HTTPRequest request) {        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"title":"TestTitle","shortDescription":"Short Description","longDescription":"Long Description","desiredSkills":"Test Desired Skills"}');
        response.setStatusCode(this.statusCode);
        return response;      
    }
}