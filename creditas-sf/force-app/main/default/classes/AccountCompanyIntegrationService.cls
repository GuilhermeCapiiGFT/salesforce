public with sharing class AccountCompanyIntegrationService {

    public static Database.UpsertResult upsertCompany(AccountCompanyIntegrationVO request){

        Datetime createdAtDateTime = formatDatetime(request.createdAt);
        Datetime updatedAtDateTime = formatDatetime(request.updatedAt);           
        String recordTypeAcc = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');
        String products;
        if(request?.enabledProducts != null && !request.enabledProducts.isEmpty() && request.enabledProducts.size() > 1){
            products = String.join(request.enabledProducts,';');
        } else if (!request.enabledProducts.isEmpty()){
            products = request?.enabledProducts[0];
        }      

        Account newAcc = new Account(
            ExternalId__c           = request.Id,
            ExternalVersion__c		= decimal.valueOf(request.version),
            CompanyStatus__c		= request.status,
            ExternalCreationDate__c	= createdAtDateTime,
            ExternalUpdatedDate__c	= updatedAtDateTime,
            DocumentNumber__c		= request.mainDocument.code,
            DocumentType__c			= request.mainDocument.type,
            Name					= request.businessName,
            LegalName__c			= request.legalName,
            enabledProducts__c		= products,
            RecordTypeId            = recordTypeAcc
        );

        Schema.SObjectField externalField = Account.Fields.ExternalId__c;

        Database.upsertResult upsertResult = Database.upsert(newAcc, externalField, false);
        return upsertResult;
    }

    @TestVisible
    private static Datetime formatDatetime(String aDatetime){

        if(String.isBlank(aDatetime)){
            return Datetime.now();
        }
        List<String> dateParts = aDatetime.split('T');
        String part1 = dateParts[0];
        String part2 = dateParts[1].split('\\.')[0];
        String formatedDatetime = part1 + ' ' + part2;        

        return Datetime.valueOf(formatedDatetime);
    }
}