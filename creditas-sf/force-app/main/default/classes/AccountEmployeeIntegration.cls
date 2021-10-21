@RestResource(urlMapping='/Account/*')
global with sharing class AccountEmployeeIntegration {
    
    @HttpPost
    global static String updateEmployee(){
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
                          ExternalVersion__c 
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

            update acc;
        } 
        else {
            res.statusCode = 400;
            return 'Conta com personId ' + request.personId + ' não encontrada.';
        }
        res.statusCode = 200;
        return 'Registro atualizado com sucesso!';
    }
}