public with sharing class ProposalWarrantyService {
    
    public static FinancialResources__c getGuarantee(String opportunityId){
        String financialResourceAutoId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Auto');
        Set<Id> financialResourceIdSet = new Set<Id>();
        for(Garantias__c garantia : [SELECT Recurso_Financeiro__c,Recurso_Financeiro__r.RecordTypeId FROM Garantias__c WHERE Opportunity__c = :opportunityId WITH SECURITY_ENFORCED]){
            if(financialResourceAutoId == garantia.Recurso_Financeiro__r.RecordTypeId){
                financialResourceIdSet.add(garantia.Recurso_Financeiro__c);
            }
        }
        if(financialResourceIdSet.isEmpty()){
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> resourceList = [SELECT ResourceKey__c,Plate__c,ModelYear__c,ManufacturingYear__c,Brand__c,Model__c,Color__c,LicensingState__c,State__c,ExternalCodeOrigin__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet WITH SECURITY_ENFORCED ORDER BY ExternalUpdatedDate__c DESC];
            return resourceList[0];
        }
    }

    public static void saveFinancialResource(FinancialResources__c financialResource){
        Database.UpsertResult upsertResult = Database.upsert(financialResource);
    }

    public static WarrantyDataSection__c getWarrantyDataSection(String opportunityId){
        List<WarrantyDataSection__c> warrantySection = [SELECT Id,UFplateStatus__c,RenavamStatus__c,RenavamPendingReason__c,RenavamRejectReason__c,RenavamObservation__c,PlateStatus__c,ModelYearStatus__c,ModelYearRejectReason__c,ModelYearObservation__c,ModelStatus__c,ModelRejectReason__c,ModelObservation__c,LicensingStateStatus__c,LicensingStateRejectReason__c,LicensingStateObservation__c,FIPEtableCodeStatus__c,ColorStatus__c,ChassiStatus__c,ChassiRejectReason__c,ChassiObservation__c,BrandStatus__c FROM WarrantyDataSection__c WHERE Opportunity__c = :opportunityId WITH SECURITY_ENFORCED];

        if(warrantySection.isEmpty()){
            return new WarrantyDataSection__c();
        } else {
            return warrantySection[0];
        }

    }

    public static void saveWarrantyDataSection(WarrantyDataSection__c warrantyObject){
        Database.UpsertResult upsertResult = Database.upsert(warrantyObject);
    }
}