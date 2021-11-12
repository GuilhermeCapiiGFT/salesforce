/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update an Account Employee from an API.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Guilherme Assis         09/11/2021      Created     Class created to Insert or Update an Account Employee from an API.
**********************************************************************************************************************************/

@RestResource(urlMapping='/Account/*')
global with sharing class AccountEmployeeIntegration {
    
    @HttpPost
    global static String upsertEmployee(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Account> acc = new List<Account>();
        AccountEmployeeIntegrationVO request = (AccountEmployeeIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), AccountEmployeeIntegrationVO.class);
        if(request.personId != ''){
            acc = [SELECT AdmissionDate__c, 
                          EmployeeId__c, 
                          EmployeeStatus__c,
                          EmployeeType__c,
                          ExternalCompanyId__c, 
                          ExternalEmployeeVersion__c, 
                          ExternalId__c, 
                          ExternalTenant__c, 
                          Margin__c, 
                          Salary__c, 
                          Type,
                          ExternalVersion__c,
                          DocumentNumber__c,
                          DocumentType__c
                    FROM Account 
                    WHERE ExternalId__c =: request.personId];
        } 
        else {
            res.statusCode = 400;
            return 'PersonId invalido.';
        }
        
        if(!acc.isEmpty()){
            String admissionDate = request.admissionDate;

            list<String> lstSplitDate = admissionDate.split('-');
            Date admissionDateFormatted = date.newinstance(Integer.valueOf(lstSplitDate[0]), Integer.valueOf(lstSplitDate[1]), Integer.valueOf(lstSplitDate[2]));
            
            acc[0].AdmissionDate__c           = admissionDateFormatted;
            acc[0].EmployeeId__c              = request.id;
            acc[0].EmployeeStatus__c          = request.status;
            acc[0].EmployeeType__c            = request.employeeType;
            acc[0].ExternalCompanyId__c       = request.companyId;
            acc[0].ExternalEmployeeVersion__c = decimal.valueOf(request.personVersion);
            acc[0].ExternalId__c              = request.personId;
            acc[0].ExternalTenant__c          = request.tenant;
            acc[0].Margin__c                  = request.margin.amount;
            acc[0].Salary__c                  = request.salary.amount;
            acc[0].ExternalVersion__c         = decimal.valueOf(request.version);
            acc[0].DocumentNumber__c          = request.mainDocument.code;
            acc[0].DocumentType__c            = request.mainDocument.type;

        } 
        else {
            Account newAcc = new Account();
            String admissionDate = request.admissionDate;

            list<String> lstSplitDate = admissionDate.split('-');
            Date admissionDateFormatted = date.newinstance(Integer.valueOf(lstSplitDate[0]), Integer.valueOf(lstSplitDate[1]), Integer.valueOf(lstSplitDate[2]));
            
            newAcc.AdmissionDate__c           = admissionDateFormatted;
            newAcc.EmployeeId__c              = request.id;
            newAcc.EmployeeStatus__c          = request.status;
            newAcc.EmployeeType__c            = request.employeeType;
            newAcc.ExternalCompanyId__c       = request.companyId;
            newAcc.ExternalEmployeeVersion__c = decimal.valueOf(request.personVersion);
            newAcc.ExternalId__c              = request.personId;
            newAcc.ExternalTenant__c          = request.tenant;
            newAcc.Margin__c                  = request.margin.amount;
            newAcc.Salary__c                  = request.salary.amount;
            newAcc.ExternalVersion__c         = decimal.valueOf(request.version);
            newAcc.DocumentNumber__c          = request.mainDocument.code;
            newAcc.DocumentType__c            = request.mainDocument.type;
            newAcc.Name                       = request.personId;

            acc.add(newAcc);
        }
        try {
            upsert acc;
            res.statusCode = 200;
            return 'Registro criado/atualizado com sucesso';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}