/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class Refactor for IntegrationAsset
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
*  1.0      Gabriel Vidal           03/03/2022      Created     Class Refactor for IntegrationAsset
**********************************************************************************************************************************/
public with sharing class IntegrationAssetService 
{
    public static final String VEHICLE_RECORD_TYPE_NAME = 'Auto';
    public static final String REAL_ESTATE_RECORD_TYPE_NAME = 'Imovel';
    public static final String CERTIFICATE_RECORD_TYPE_NAME = 'Certificado';
    public static final String OTHERS_RECORD_TYPE_NAME = 'Outros';

    public void upsertAsset()
    {        
        String requestBody = RestContext.request.requestBody.toString();           
        try 
        {
            IntegrationAssetVO requestBodyObj = IntegrationAssetVO.parse(requestBody);

            if (requestBodyObj.hasError)
            {
                setErrorResponse(500, 'Invalid JSON format.');
                insertErrorLog(500, requestBody, requestBodyObj.errorMessage);
                return;
            } 

            Map<String, Account> accountExternalIdToAccountMap = getOwners(requestBodyObj);

            Id recordTypeId = getRecordTypeId(requestBodyObj);

            Boolean hasError = commitTransactions(accountExternalIdToAccountMap, requestBodyObj, requestBody, recordTypeId);
            if(hasError)
            {
                setErrorResponse(500, requestBodyObj.errorMessage);
                insertErrorLog(500, requestBody, requestBodyObj.errorMessage);
            }
        } catch (Exception e) 
        {
            setErrorResponse(500, '');
            insertErrorLog(500, requestBody, e.getMessage());
        }
    }

    public static Map<String, Account> getOwners(IntegrationAssetVO requestBodyObj)
    {
        if (requestBodyObj.owners == null || requestBodyObj.owners.isEmpty())
        {
            return new Map<String, Account>();
        }
        Set<String> ownerExternalIds = new Set<String>();
        for (IntegrationAssetVO.OwnersModel owner : requestBodyObj.owners)
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
        return accountExternalIdToAccountMap;
    }


    public static Id getRecordTypeId(IntegrationAssetVO requestBodyObj)
    {
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
        return Util.getRecordTypeIdbyName('FinancialResources__c', recordTypeDeveloperName);
    }


    private static Id upsertAsset(IntegrationAssetVO requestBodyObj, Id recordTypeId)
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
            return assetObject.Id;
        } catch (System.DmlException e){
            requestBodyObj.hasError = true;
            requestBodyObj.errorMessage = e.getDmlMessage(0);
            return null;
        }  
    }


    private static void upsertAccountFinancialRelationship(Map<String, Account> accountExternalIdToAccountMap, IntegrationAssetVO requestBodyObj, Id assetId)
    {
        Map<String, AccountFinancialRelationship__c> externalOwnerIdToAssetRelationshipMap = new Map<String, AccountFinancialRelationship__c>();
        for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__r.ExternalId__c, Recurso_Financeiro__c 
                                                                            FROM AccountFinancialRelationship__c 
                                                                            WHERE Recurso_Financeiro__c = :assetId
                                                                            AND Account__c IN :accountExternalIdToAccountMap.keySet()])
        {
            externalOwnerIdToAssetRelationshipMap.put(accountRelation.Account__r.ExternalId__c, accountRelation);
        }

        List<AccountFinancialRelationship__c> ownerRelationshipsToUpsert = new List<AccountFinancialRelationship__c>();
        for (IntegrationAssetVO.OwnersModel owner : requestBodyObj.owners)
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

        List<AccountFinancialRelationship__c> accountRelationshipsToDelete = new List<AccountFinancialRelationship__c>();
        for (AccountFinancialRelationship__c afr : [SELECT Id
                                                    FROM AccountFinancialRelationship__c
                                                    WHERE Recurso_Financeiro__c = :assetId
                                                    AND Account__c NOT IN :accountExternalIdToAccountMap.keySet()])
        {
            accountRelationshipsToDelete.add(afr);                                            
        }

        delete accountRelationshipsToDelete;
        upsert ownerRelationshipsToUpsert;                                               
    }


    public static Boolean commitTransactions(Map<String, Account> accountExternalIdToAccountMap, IntegrationAssetVO requestBodyObj, String requestBody, Id recordTypeId)
    {
        Boolean varSuccess = false, hasError = false;
        Id assetId;

        Savepoint sp = Database.setSavepoint();
        if (!hasError)
        {
            try
            {
                assetId = upsertAsset(requestBodyObj, recordTypeId);
                hasError = requestBodyObj.hasError;
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
                requestBodyObj.errorMessage =  e.getMessage();
                Database.rollback(sp); 
            }
            if(varSuccess)
            {
                try
                {
                    if(!accountExternalIdToAccountMap.isEmpty())
                    {
                        upsertAccountFinancialRelationship(accountExternalIdToAccountMap, requestBodyObj, assetId);
                    }
                    successReturn(assetId);
                } catch(Exception e)
                {
                    hasError = true;
                    requestBodyObj.errorMessage = e.getMessage();
                    Database.rollback(sp); 
                }
            }
        } 
        return hasError;
    }


    public static void insertErrorLog(Integer errorCode, String requestBody, String errorMessage)
    {
        System.debug('Error: '+errorMessage);
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
            setErrorResponse(500, 'Error inserting error log.');
        }
    }


    public static void setErrorResponse(Integer errorCode, String errorMessage)
    {
        AssetResponseData resp = new AssetResponseData();
        resp.assetId = null;
        resp.message = String.isNotBlank(errorMessage) ? errorMessage : 'An error has occurred. Please, contact a Salesforce Administrator.';
        resp.status = errorCode;

        RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(resp));
        res.statusCode = errorCode;
    }


    public static void successReturn(Id assetId)
    {
        AssetResponseData assetResponse = new AssetResponseData();
        assetResponse.assetId = assetId;
        assetResponse.message = 'Asset upserted';
        assetResponse.status = 200;

        RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(assetResponse));
        res.statusCode = 200;
    }
    
    public class AssetResponseData
    {
        public String assetId;
        public String message;
        public Integer status;
    }
}