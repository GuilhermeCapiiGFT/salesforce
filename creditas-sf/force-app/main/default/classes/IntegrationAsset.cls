@RestResource(urlMapping='/IntegrationAsset/*')
global without sharing class IntegrationAsset 
{
    public static final String VEHICLE_RECORD_TYPE_NAME = 'Auto';
    public static final String REAL_ESTATE_RECORD_TYPE_NAME = 'Imovel';
    public static final String CERTIFICATE_RECORD_TYPE_NAME = 'Certificado';
    public static final String OTHERS_RECORD_TYPE_NAME = 'Outros';
    public static Id recordTypeId;
    public static Id assetId;
    public static String errorMessage;
    public static String requestBody;
    public static AssetIntegrationModel requestBodyObj;
    public static Boolean hasError = false;

    @HttpPut
    global static void putMethod()
    {
        try
        {
            requestBody = RestContext.request.requestBody.toString();
            requestBodyObj = AssetIntegrationModel.parse(requestBody);

            if (requestBodyObj.hasError)
            {
                hasError = true;
                errorMessage = requestBodyObj.errorMessage;
                setErrorResponse(500);
                insertErrorLog(500);
                return;
            } else if (requestBodyObj.owners == null)
            {
                hasError = true;
                errorMessage = 'The owner(s) was not found on Salesforce.';
                setErrorResponse(500);
                insertErrorLog(500);
                return;
            }

            Set<String> ownerExternalIds = new Set<String>();
            for (AssetIntegrationModel.OwnersModel owner : requestBodyObj.owners)
            {
                if(String.isNotBlank(owner.person.id))
                {
                    ownerExternalIds.add(owner.person.id);           
                }
            }
            Map<String, Account> accountExternalIdToAccountMap = new Map<String, Account>();
            for (Account acc : [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :ownerExternalIds])
            {
                accountExternalIdToAccountMap.put(acc.ExternalId__c, acc);
            }
            if (accountExternalIdToAccountMap.isEmpty())
            {
                hasError = true;
                errorMessage = 'The owner(s) was not found on Salesforce.';
                setErrorResponse(500);
                insertErrorLog(500);
                return;
            }
            
            String recordTypeDeveloperName = '';
            if (requestBodyObj.type == 'VEHICLE') 
            {
                recordTypeDeveloperName = VEHICLE_RECORD_TYPE_NAME;
            } else if (requestBodyObj.type == 'REAL_ESTATE') 
            {
                recordTypeDeveloperName = REAL_ESTATE_RECORD_TYPE_NAME;
            } else if (requestBodyObj.type == 'CERTIFICATE') 
            {
                recordTypeDeveloperName = CERTIFICATE_RECORD_TYPE_NAME;
            } else 
            {
                recordTypeDeveloperName = OTHERS_RECORD_TYPE_NAME;
            }
            recordTypeId = Util.getRecordTypeIdbyName('FinancialResources__c', recordTypeDeveloperName);
            
            commitTransactions(accountExternalIdToAccountMap);
            
            if (!hasError)
            {
                AssetResponseData assetResponse = new AssetResponseData();
                assetResponse.assetId = assetId;
                assetResponse.message = 'Asset upserted';
                assetResponse.status = 200;

                RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
                res.responseBody = Blob.valueOf(JSON.serialize(assetResponse));
                res.statusCode = 200;
            } else 
            {
                setErrorResponse(500);
                insertErrorLog(500);
            }  
        }  catch (Exception e) 
        {
            hasError = true;
            errorMessage = e.getMessage();
            setErrorResponse(500);
            insertErrorLog(500);
        }
    }

    private static void upsertAsset()
    {
        FinancialResources__c assetObject = new FinancialResources__c();
        if (recordTypeId != null)
        {
            assetObject.recordTypeId = recordTypeId;
        }
        assetObject.Id = [SELECT Id FROM FinancialResources__c WHERE ExternalId__c = :requestBodyObj.id LIMIT 1]?.Id;
        assetObject.ExternalId__c = requestBodyObj.id;
        assetObject.External_Version__c = requestBodyObj.version;
        if (requestBodyObj.value != null)
        {
            if (requestBodyObj.value.amount != null)
            {
                assetObject.CurrencyIsoCode = requestBodyObj.value.amount.currencyCode;
                assetObject.Amount__c  = Decimal.valueOf(requestBodyObj.value.amount.amount);
            }
            assetObject.AppraisalDate__c = Date.valueOf(requestBodyObj.value.appraisalDate);
        }
        if (requestBodyObj.alienation != null){
            assetObject.FinancialInstitution__c = requestBodyObj.alienation.financialInstitution;
        }
        if (requestBodyObj.assetDetail != null){
            assetObject.State__c = requestBodyObj.assetDetail.state;
        }
        assetObject.ExternalCreationDate__c = Date.valueOf(requestBodyObj.createdAt);
        assetObject.ExternalUpdatedDate__c = Date.valueOf(requestBodyObj.updatedAt);

        try {
            upsert assetObject;  
            assetId = assetObject.Id;
        } catch (System.DmlException e){
            hasError = true;
            errorMessage = e.getDmlMessage(0);
            return;
        }  
    }

    private static void upsertAccountFinancialRelationship(Map<String, Account> accountExternalIdToAccountMap)
    {
        Map<String, AccountFinancialRelationship__c> externalOwnerIdToAssetRelationshipMap = new Map<String, AccountFinancialRelationship__c>();
        for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__r.ExternalId__c, Recurso_Financeiro__c 
                                                                            FROM AccountFinancialRelationship__c 
                                                                            WHERE Recurso_Financeiro__c = :assetId])
        {
            externalOwnerIdToAssetRelationshipMap.put(accountRelation.Account__r.ExternalId__c, accountRelation);
        }

        List<AccountFinancialRelationship__c> ownerRelationshipsToUpsert = new List<AccountFinancialRelationship__c>();
        for (AssetIntegrationModel.OwnersModel owner : requestBodyObj.owners)
        {
            if (!accountExternalIdToAccountMap.containsKey(owner.person.id))
            {
                continue;
            }
            AccountFinancialRelationship__c assetOwnerRelationship = new AccountFinancialRelationship__c();
            assetOwnerRelationship.Id = externalOwnerIdToAssetRelationshipMap.get(owner.person.id)?.Id;
            assetOwnerRelationship.Account__c = accountExternalIdToAccountMap.get(owner.person.id).Id;
            assetOwnerRelationship.Recurso_Financeiro__c = assetId;

            ownerRelationshipsToUpsert.add(assetOwnerRelationship);
        }
        upsert ownerRelationshipsToUpsert;                                               
    }

    public static void insertErrorLog(Integer errorCode){
        API_Transaction_Errors__b ate = new API_Transaction_Errors__b();
        ate.Endpoint__c = '/services/apexrest/IntegrationAsset';
        ate.RequestBody__c = requestBody;
        ate.ReturnCode__c = errorCode;
        ate.ErrorMessage__c = errorMessage;
        ate.CreatedDate__c = System.now();
        ate.CreatedBy__c = UserInfo.getUserId();

        try 
        {
            if (!Test.isRunningTest())
            {
  				database.insertImmediate(ate);              
            }
        } catch (Exception e) 
        {
            setErrorResponse(500);
        }
    }

    public static void setErrorResponse(Integer errorCode){
        AssetResponseData resp = new AssetResponseData();
        resp.assetId = null;
        resp.message = String.isNotBlank(errorMessage) ? errorMessage : 'An error has occurred. Please, contact a Salesforce Administrator.';
        resp.status = errorCode;

        RestResponse res = RestContext.response;
        if (res == null) 
        {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.responseBody = Blob.valueOf(JSON.serialize(resp));
        res.statusCode = errorCode;
    }

    public static void commitTransactions(Map<String, Account> accountExternalIdToAccountMap)
    {
        Boolean varSuccess= false;

        Savepoint sp = Database.setSavepoint();
        if (!hasError)
        {
            try
            {
                upsertAsset();
                if(!hasError)
                {
					varSuccess = true;                     
                } else 
                {
                	Database.rollback(sp);    
                }
            } catch(Exception e)
            {
                hasError = true;
                errorMessage =  e.getMessage();
                Database.rollback(sp); 
            }
            if(varSuccess)
            {
                try
                {
                  upsertAccountFinancialRelationship(accountExternalIdToAccountMap);
                } catch(Exception e)
                {
                    hasError = true;
                    errorMessage = e.getMessage();
                    Database.rollback(sp); 
                }
            }
        }
    }
    public class AssetResponseData
    {
        public String assetId;
        public String message;
        public Integer status;
    }
}