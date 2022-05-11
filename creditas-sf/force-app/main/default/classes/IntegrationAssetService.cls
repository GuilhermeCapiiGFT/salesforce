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

    public static Map<String, String> upsertAsset(String requestBody, IntegrationAssetVO requestBodyObj)
    {          
        Map<String, String> returnMap = new Map<String, String>();     
        try 
        {
            Map<String, Account> accountExternalIdToAccountMap = getOwners(requestBodyObj);

            Id recordTypeId = getRecordTypeId(requestBodyObj);

            Id assetId = commitTransactions(accountExternalIdToAccountMap, requestBodyObj, requestBody, recordTypeId);
            if(assetId != null)
            {               
                returnMap.put('statusCode', '200');
                returnMap.put('assetId', assetId);
                return returnMap;
            } else 
            {
                returnMap.put('statusCode', '500');
                returnMap.put('errorMessage', requestBodyObj.errorMessage);
                returnMap.put('exceptionMessage', requestBodyObj.errorMessage);
                return returnMap;
            }
        } catch (Exception e) 
        {
            returnMap.put('statusCode', '500');
            returnMap.put('errorMessage', 'An unexpected error has occurred. Please, contact a Salesforce Administrator.');
            returnMap.put('exceptionMessage', e.getMessage());
            return returnMap;
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
            assetObject.AppraisalDate__c = requestBodyObj.value.appraisalDate != null ? Date.valueOf(requestBodyObj.value.appraisalDate) : null;
        }
        if (requestBodyObj.alienation != null){
            assetObject.FinancialInstitution__c = requestBodyObj.alienation.financialInstitution;
        }
        if (requestBodyObj.assetDetail != null){
            assetObject.State__c = requestBodyObj.assetDetail.state;
        }
        assetObject.ExternalCreationDate__c = requestBodyObj.createdAt != null ? Date.valueOf(requestBodyObj.createdAt) : null;
        assetObject.ExternalUpdatedDate__c = requestBodyObj.updatedAt != null ? Date.valueOf(requestBodyObj.updatedAt) : null;

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
        Set<Id> accountsIds = new Set<Id>();
        for(Account acc : accountExternalIdToAccountMap.values())
        {
            accountsIds.add(acc.Id);
        }
        for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__r.ExternalId__c, Recurso_Financeiro__c 
                                                                            FROM AccountFinancialRelationship__c 
                                                                            WHERE Recurso_Financeiro__c = :assetId
                                                                            AND Account__c IN :accountsIds])
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
                                                    AND Account__c NOT IN :accountsIds])
        {
            accountRelationshipsToDelete.add(afr);                                            
        }

        delete accountRelationshipsToDelete;
        upsert ownerRelationshipsToUpsert;                                               
    }


    public static Id commitTransactions(Map<String, Account> accountExternalIdToAccountMap, IntegrationAssetVO requestBodyObj, String requestBody, Id recordTypeId)
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
                } catch(Exception e)
                {
                    hasError = true;
                    requestBodyObj.errorMessage = e.getMessage();
                    Database.rollback(sp); 
                }
            }
        } 
        return assetId;
    }
}