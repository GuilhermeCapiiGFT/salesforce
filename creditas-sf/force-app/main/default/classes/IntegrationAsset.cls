@RestResource(urlMapping='/IntegrationAsset/*')
global without sharing class IntegrationAsset 
{
    public static final String VEHICLE_RECORD_TYPE_NAME = 'Auto';
    public static final String REAL_ESTATE_RECORD_TYPE_NAME = 'Imovel';
    public static final String CERTIFICATE_RECORD_TYPE_NAME = 'Certificado';
    public static final String OTHERS_RECORD_TYPE_NAME = 'Outros';

    @HttpPut
    global static void putMethod()
    {
        AssetIntegrationModel typedRequestBody = AssetIntegrationModel.parse(RestContext.request.requestBody.toString());

        Set<String> ownerExternalIds = new Set<String>();
        for (AssetIntegrationModel.OwnersModel owner : typedRequestBody.owners)
        {
            ownerExternalIds.add(owner.person.id);
        }

        Map<String, Account> accountExternalIdToAccountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :ownerExternalIds])
        {
            accountExternalIdToAccountMap.put(acc.ExternalId__c, acc);
        }
        if (accountExternalIdToAccountMap.isEmpty())
        {
            AssetResponseData ard = new AssetResponseData();
            ard.assetId = null;
            ard.message = 'The owner(s) was not found on Salesforce.';
    
            RestResponse res = RestContext.response;
            res.responseBody = Blob.valueOf(JSON.serialize(ard));
            res.statusCode = 400;

            return;
        }
        
        String recordTypeDeveloperName = '';
        if (typedRequestBody.type == 'VEHICLE') 
        {
            recordTypeDeveloperName = VEHICLE_RECORD_TYPE_NAME;
        } else if (typedRequestBody.type == 'REAL_ESTATE') 
        {
            recordTypeDeveloperName = REAL_ESTATE_RECORD_TYPE_NAME;
        } else if (typedRequestBody.type == 'CERTIFICATE') 
        {
            recordTypeDeveloperName = CERTIFICATE_RECORD_TYPE_NAME;
        } else 
        {
            recordTypeDeveloperName = OTHERS_RECORD_TYPE_NAME;
        }
        Id recordTypeId = Util.getRecordTypeIdbyName('FinancialResources__c', recordTypeDeveloperName);
        
        FinancialResources__c asset = upsertAsset(typedRequestBody, recordTypeId);

        upsertAccountFinancialRelationship(asset, typedRequestBody, accountExternalIdToAccountMap);

        AssetResponseData ard = new AssetResponseData();
        ard.assetId = asset.Id;
        ard.message = 'Asset upserted';

        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf(JSON.serialize(ard));
        res.statusCode = 200;
    }

    private static FinancialResources__c upsertAsset(AssetIntegrationModel requestBody, Id recordTypeId)
    {
        FinancialResources__c assetToUpsert = new FinancialResources__c();
        if (recordTypeId != null)
        {
            assetToUpsert.recordTypeId = recordTypeId;
        }
        assetToUpsert.Id = [SELECT Id FROM FinancialResources__c WHERE ExternalId__c = :requestBody.id LIMIT 1]?.Id;
        assetToUpsert.ExternalId__c = requestBody.id;
        assetToUpsert.External_Version__c = requestBody.version;
        assetToUpsert.CurrencyIsoCode = requestBody.value.amount.currencyCode;
        assetToUpsert.Amount__c  = Decimal.valueOf(requestBody.value.amount.amount);
        assetToUpsert.AppraisalDate__c = Date.valueOf(requestBody.value.appraisalDate);
        assetToUpsert.FinancialInstitution__c = requestBody.alienation.financialInstitution;
        assetToUpsert.State__c = requestBody.assetDetail.state;
        assetToUpsert.ExternalCreationDate__c = Date.valueOf(requestBody.createdAt);
        assetToUpsert.ExternalUpdatedDate__c = Date.valueOf(requestBody.updatedAt);

        upsert assetToUpsert;

        return assetToUpsert;
    }

    private static void upsertAccountFinancialRelationship(FinancialResources__c asset, AssetIntegrationModel requestBody, Map<String, Account> accountExternalIdToAccountMap)
    {
        Map<String, AccountFinancialRelationship__c> externalOwnerIdToAssetRelationshipMap = new Map<String, AccountFinancialRelationship__c>();
        for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__r.ExternalId__c, Recurso_Financeiro__c 
                                                                            FROM AccountFinancialRelationship__c 
                                                                            WHERE Recurso_Financeiro__c = :asset.Id])
        {
            externalOwnerIdToAssetRelationshipMap.put(accountRelation.Account__r.ExternalId__c, accountRelation);
        }

        List<AccountFinancialRelationship__c> ownerRelationshipsToUpsert = new List<AccountFinancialRelationship__c>();
        for (AssetIntegrationModel.OwnersModel owner : requestBody.owners)
        {
            if (!accountExternalIdToAccountMap.containsKey(owner.person.id))
            {
                continue;
            }
            AccountFinancialRelationship__c assetOwnerRelationship = new AccountFinancialRelationship__c();
            assetOwnerRelationship.Id = externalOwnerIdToAssetRelationshipMap.get(owner.person.id)?.Id;
            assetOwnerRelationship.Account__c = accountExternalIdToAccountMap.get(owner.person.id).Id;
            assetOwnerRelationship.Recurso_Financeiro__c = asset.Id;

            ownerRelationshipsToUpsert.add(assetOwnerRelationship);
        }

        upsert ownerRelationshipsToUpsert;
                                                   
    }

    public class AssetResponseData
    {
        public String assetId;
        public String message;
    }
}