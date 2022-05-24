public with sharing class ProposalContactDataService {
    @AuraEnabled
    public static ContactDetailsSection__c getContactDetailsSectionFromOpp(Id opportunityId){
        
        List<ContactDetailsSection__c> recordsContactDetailsSection = new List<ContactDetailsSection__c>();
        recordsContactDetailsSection = [SELECT Id,
                                        Email__c,
                                        Mobile__c,
                                        MobileStatus__c,
                                        MobileRejectReason__c,
                                        MobileObservation__c,
                                        EmailStatus__c,
                                        EmailRejectReason__c,                                       
                                        EmailObservation__c
                                        FROM ContactDetailsSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        ORDER BY CreatedDate  DESC
                                        LIMIT 1];
        
        return recordsContactDetailsSection.isEmpty() ? new ContactDetailsSection__c() : recordsContactDetailsSection[0];
        
    }

    @AuraEnabled
    public static void upsertContactDetailsSection(ContactDetailsSection__c record){
        SObjectUtils.upsertRecord(record);
    }
}