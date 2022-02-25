/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Test class for mock data to use in test class MinuatorSearchTest
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           03/02/2022      Created      Test class for mock data to use in test class MinuatorSearchTest  
*************************************************************************************************************************************/
@isTest
global with sharing class MinuatorSearchMockTest implements HttpCalloutMock { 
    private Integer statusCode;

    public MinuatorSearchMockTest(Integer statusCode){
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest request) {        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"errorCode": "lead_not_found_error","message": "Lead not found"}');
        response.setStatusCode(this.statusCode);
        
        return response;      
    }
}