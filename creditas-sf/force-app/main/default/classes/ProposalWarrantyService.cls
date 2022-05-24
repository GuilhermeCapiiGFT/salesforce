public with sharing class ProposalWarrantyService {
    

    public static WarrantyDataSection__c getWarrantyDataSection(String opportunityId){

        List<WarrantyDataSection__c> warrantySection = [SELECT Id, ResourceKey__c,ModelYear__c,UFplateStatus__c,RenavamStatus__c,Plate__c,PlateStatus__c,Model__c,ModelPendingReason__c,
                                                               ModelYearStatus__c,ModelYearRejectReason__c,ModelYearObservation__c,ModelStatus__c,ModelRejectReason__c,ModelObservation__c,
                                                               LicensingStateStatus__c,LicensingStateRejectReason__c,LicensingStateObservation__c,FIPEtableCodeStatus__c,ColorStatus__c,
                                                               ChassiStatus__c,ChassiRejectReason__c,ChassiObservation__c,Brand__c,BrandStatus__c, ManufacturingYear__c,ManufacturingYearStatus__c,
                                                               Color__c,State__c,LicensingState__c,Chassi__c,ExternalCodeOrigin__c
                                                               FROM WarrantyDataSection__c 
                                                               WHERE Opportunity__c = :opportunityId 
                                                               ORDER BY CreatedDate DESC
                                                               LIMIT 1];

        if(warrantySection.isEmpty()){
            return new WarrantyDataSection__c();
        } else {
            return warrantySection[0];
        }
    }

    public static void saveWarrantyDataSection(WarrantyDataSection__c warrantyObject){       
        SObjectUtils.upsertRecord(warrantyObject);    
    }
}