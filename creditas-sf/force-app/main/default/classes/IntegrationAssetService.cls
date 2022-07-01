public with sharing class IntegrationAssetService {
    public class UpsertAssertException extends Exception{}
    public class InsertAccountException extends Exception{}
    public static final String VEHICLE_RECORD_TYPE_NAME = 'Auto';
    public static final String REAL_ESTATE_RECORD_TYPE_NAME = 'Imovel';
    public static final String CERTIFICATE_RECORD_TYPE_NAME = 'Certificado';
    public static final String OTHERS_RECORD_TYPE_NAME = 'Outros';
    private static Map<String,String> mapAdditionalKeys = new Map<String,String>();
    private static String resourceType;

    public static Map<String, String> upsertAsset(IntegrationAssetVO requestBodyObj) {
        Map<String, String> returnMap = new Map<String, String>();

        try {
            Map<String, Account> accountExternalIdToAccountMap = getOwners(requestBodyObj);

            Id recordTypeId = getRecordTypeId(requestBodyObj);

            Id assetId = commitTransactions(accountExternalIdToAccountMap, requestBodyObj, recordTypeId);
            if(assetId == null) {
                returnMap.put('statusCode', '500');
                returnMap.put('errorMessage', requestBodyObj.errorMessage);
                returnMap.put('exceptionMessage', requestBodyObj.errorMessage);
            } else {
                returnMap.put('statusCode', '200');
                returnMap.put('assetId', assetId);
            }
            return returnMap;
        } catch (Exception e) {
            returnMap.put('statusCode', '500');
            returnMap.put('errorMessage', 'An unexpected error has occurred. Please, contact a Salesforce Administrator.');
            returnMap.put('exceptionMessage', e.getMessage());
            return returnMap;
        }
    }

    public static Map<String, Account> getOwners(IntegrationAssetVO requestBodyObj) {
        Map<String, Account> accountExternalIdToAccountMap = new Map<String, Account>();

        if (requestBodyObj.owners == null || requestBodyObj.owners.isEmpty()) {
            return accountExternalIdToAccountMap;
        }

        Set<String> ownerExternalIds = new Set<String>();
        for (IntegrationAssetVO.Owners owner : requestBodyObj.owners) {
            if(String.isNotBlank(owner.person.id)) {
                ownerExternalIds.add(owner.person.id);           
            }
        }

        for (Account acc : [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :ownerExternalIds]) {
            accountExternalIdToAccountMap.put(acc.ExternalId__c, acc);
        }
        return accountExternalIdToAccountMap;
    }

    public static Id getRecordTypeId(IntegrationAssetVO requestBodyObj) {
        String recordTypeDeveloperName = '';
        if (requestBodyObj.type == 'VEHICLE') {
            recordTypeDeveloperName = VEHICLE_RECORD_TYPE_NAME;
            resourceType = requestBodyObj?.assetDetail?.type;
        } else if (requestBodyObj.type == 'REAL_ESTATE') {
            recordTypeDeveloperName = REAL_ESTATE_RECORD_TYPE_NAME;
            resourceType = requestBodyObj?.assetDetail?.realEstateType;
        } else if (requestBodyObj.type == 'CERTIFICATE') {
            recordTypeDeveloperName = CERTIFICATE_RECORD_TYPE_NAME;
        } else {
            recordTypeDeveloperName = OTHERS_RECORD_TYPE_NAME;
        }
        return Util.getRecordTypeIdbyName('FinancialResources__c', recordTypeDeveloperName);
    }

    public static Id commitTransactions(Map<String, Account> accountExternalIdToAccountMap, IntegrationAssetVO requestBodyObj, Id recordTypeId) {
        Id assetId;

        Savepoint sp = Database.setSavepoint();

        try {
            Database.UpsertResult resultAsset = upsertAsset(requestBodyObj, recordTypeId);
            assetId = resultAsset.getId();
            upsertAccountFinancialRelationship(accountExternalIdToAccountMap, requestBodyObj, assetId);
        } catch(Exception e) {
            requestBodyObj.hasError = true;
            requestBodyObj.errorMessage =  e.getMessage();
            Database.rollback(sp);
        }

        return assetId;
    }

    private static Database.UpsertResult upsertAsset(IntegrationAssetVO requestBodyObj, Id recordTypeId){
        for(IntegrationAssetVO.AdditionalKeys addKey : requestBodyObj.assetDetail.additionalKeys){
            mapAdditionalKeys.put(addKey.key, addKey.code);
        }

        for(IntegrationAssetVO.ExternalCodes code : requestBodyObj.assetDetail.externalCodes){
            mapAdditionalKeys.put(code.origin, code.code);
        }
        FinancialResources__c assetObject = new FinancialResources__c(
            recordTypeId = recordTypeId,
            ExternalId__c = requestBodyObj.id,
            External_Version__c = requestBodyObj.version,
            Type__c = resourceType,
            CurrencyIsoCode = requestBodyObj?.value?.amount?.currencyCode,
            Amount__c  = getDecimalValue(requestBodyObj?.value?.amount?.amount),
            FinancialInstitution__c = requestBodyObj?.alienation?.financialInstitution,
            AppraisalDate__c = getDateValue(requestBodyObj?.value?.appraisalDate),
            ExternalCreationDate__c = getDateValue(requestBodyObj?.createdAt),
            ExternalUpdatedDate__c =  getDateValue(requestBodyObj?.updatedAt),
            ResourceKey__c = mapAdditionalKeys.get('RENAVAN'),
            ExternalCodeOrigin__c = mapAdditionalKeys.get('FIPE'),
            Plate__c = requestBodyObj?.assetDetail?.plate,
            ManufacturingYear__c = getStringValue(requestBodyObj?.assetDetail?.manufacturingYear),
            ModelYear__c = getStringValue(requestBodyObj?.assetDetail?.modelYear),
            Brand__c = requestBodyObj?.assetDetail?.brand,
            Model__c = requestBodyObj?.assetDetail?.model,
            Color__c = requestBodyObj?.assetDetail?.color,
            State__c = requestBodyObj?.assetDetail?.state,
            LicensingState__c = getUF(requestBodyObj?.assetDetail?.licensing?.address?.administrativeAreaLevel1),
            Chassis__c = requestBodyObj?.assetDetail?.chassis
        );

        Schema.SObjectField externalField = FinancialResources__c.Fields.ExternalId__c;
        Database.UpsertResult ur = Database.upsert(assetObject, externalField, false);
        if(!ur.isSuccess()){
            throw new UpsertAssertException('Error upserting Asset ' + buildErrorString(ur.getErrors()));
        }
        return ur;
    }

    private static String buildErrorString(List<Database.Error> errorList){
        String response = '';
        for(Database.Error error : errorList){
            response += 'Fields: ' + error.getFields() + ' Message: ' + error.getMessage();
        }
        return response;
    }

    private static String getStringValue(Integer inputValue){
        String output;
        if(String.isBlank(String.valueOf(inputValue))) { return output; }
        output =  String.valueOf(inputValue);
        return output;
    }

    private static Decimal getDecimalValue(String inputValue){
        Decimal output;
        if(String.isBlank(inputValue)) { return output; }
        output =  Decimal.valueOf(inputValue);
        return output;
    }

    private static Date getDateValue(String inputDate){
        Date output;
        if(String.isBlank(inputDate)) { return output; }
        output =  Date.valueOf(inputDate);
        return output;
    }

    private static void upsertAccountFinancialRelationship(Map<String, Account> accountExternalIdToAccountMap, IntegrationAssetVO requestBodyObj, Id assetId) {
  
        List<AccountFinancialRelationship__c> toDelete = new List<AccountFinancialRelationship__c>();
        List<AccountFinancialRelationship__c> toInsert = new List<AccountFinancialRelationship__c>();
        Set<String> existingFinancialRelationships = new Set<String>();
        
        for(AccountFinancialRelationship__c accountRelation : [SELECT Account__c,Account__r.ExternalId__c FROM AccountFinancialRelationship__c WHERE Recurso_Financeiro__c = :assetId]) {
            if(accountExternalIdToAccountMap.containsKey(accountRelation.Account__r.ExternalId__c)) {
                existingFinancialRelationships.add(accountRelation.Account__c);
            } else {
                toDelete.add(accountRelation);
            }
        }

        for(Account acc : accountExternalIdToAccountMap.values())
        {
            if(existingFinancialRelationships.contains(acc.Id)){ continue; }
            AccountFinancialRelationship__c newFinancialRelationship = new AccountFinancialRelationship__c(
                Account__c = acc.Id,
                Recurso_Financeiro__c = assetId
            );
            toInsert.add(newFinancialRelationship);
        }
        if(toDelete.isEmpty() && toInsert.isEmpty()) { return; }
        
        if(!toDelete.isEmpty()){
            Database.delete(toDelete);
        }

        if(!toInsert.isEmpty()){
            List<Database.SaveResult> srList = Database.insert(toInsert, false);
            for(Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    throw new InsertAccountException('Error inserting AccountFinancialRelationship ' + buildErrorString(sr.getErrors()));
                }
            }
        }
    }

    @TestVisible
    private static String getUF(String inputState){
        if(String.isBlank(inputState)){ return null; }

        String clearString = Util.removeDiacritics(inputState).replaceAll('\\s','').toLowerCase();

        switch on clearString {
            when 'acre' {
                return 'AC';
            } 
            when 'alagoas' {
                return 'AL';
            }
            when 'amapa' {
                return 'AP';
            }
            when 'amazonas' {
                return 'AM';
            }
            when 'bahia' {
                return 'BA';
            }
            when 'ceara' {
                return 'CE';
            }
            when 'distritofederal' {
                return 'DF';
            }
            when 'espiritosanto' {
                return 'ES';
            }
            when 'goias' {
                return 'GO';
            }
            when 'maranhao' {
                return 'MA';
            }
            when 'matogrosso' {
                return 'MT';
            }
            when 'matogrossodosul' {
                return 'MS';
            }
            when 'minasgerais' {
                return 'MG';
            }
            when 'para' {
                return 'PA';
            }
            when 'paraiba' {
                return 'PB';
            }
            when 'parana' {
                return 'PR';
            }
            when 'pernambuco' {
                return 'PE';
            }
            when 'piaui' {
                return 'PI';
            }
            when 'riodejaneiro' {
                return 'RJ';
            }
            when 'riograndedonorte' {
                return 'RN';
            }
            when 'riograndedosul' {
                return 'RS';
            }
            when 'rondonia' {
                return 'RO';
            }
            when 'roraima' {
                return 'RR';
            }
            when 'santacatarina' {
                return 'SC';
            }
            when 'saopaulo' {
                return 'SP';
            }
            when 'sergipe' {
                return 'SE';
            }
            when 'tocantins' {
                return 'TO';
            }
            when else {
                return inputState;
            }
        }
    }
}