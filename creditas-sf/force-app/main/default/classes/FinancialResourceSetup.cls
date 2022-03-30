@isTest
public with sharing class FinancialResourceSetup {
    
    public static FinancialResources__c createFinancialResource(String recordTypeDevName){
        String finRT = Util.getRecordTypeIdbyName('FinancialResources__c', recordTypeDevName);
        FinancialResources__c finResource = new FinancialResources__c(
            RecordTypeId = finRT,
            Name = 'Test Financial Resource',
            ExternalId__c = 'FIN-RESOURCE-2077',
            ExternalCreationDate__c = Datetime.now().addDays(-5),
            ExternalUpdatedDate__c = Datetime.now(),
            State__c = 'SP',
            Amount__c = 20777702
        );
        if('Auto' == recordTypeDevName){
            finResource.ResourceKeyType__c = 'RENAVAM';
            finResource.ResourceKey__c = '14522325';
            finResource.Plate__c = 'DBZ-2077';
            finResource.ModelYear__c = String.valueOf(Date.today().year());
            finResource.ManufacturingYear__c = String.valueOf(Date.today().year());
            finResource.Brand__c = 'Tesla';
            finResource.Model__c = 'Y';
            finResource.Color__c = 'Frost White';
            finResource.LicensingState__c = 'SP';
            finResource.ExternalCodeOrigin__c = '10771989';
        } else if('Certificado' == recordTypeDevName){
            finResource.Source__c = 'INVESTMENT';
            finResource.Type__c = 'MONTHLY_INCOME';
        } else if('Imovel' == recordTypeDevName){
            finResource.ResourceKeyType__c = 'DEED_NUMBER';
            finResource.ResourceKey__c = '14522325';
            finResource.Type__c = 'APARTMENT';
        } else {
            finResource.Source__c = 'RENTS';
            finResource.Type__c = 'NET_MONTHLY_INCOME';
        }

        return finResource;
    }
}
