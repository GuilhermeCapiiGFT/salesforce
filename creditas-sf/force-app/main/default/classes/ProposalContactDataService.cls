public with sharing class ProposalContactDataService {
    
     /*@AuraEnabled
    public static Map<String,CommunicationContacts__c> getCommunicationContactFromAccount(Id accountId){
        
        Map<String,CommunicationContacts__c> recordInfo = new Map<String,CommunicationContacts__c>();
        for(CommunicationContacts__c communicationContact :[ SELECT Id, Code__c, Channel__c 
                                                            FROM CommunicationContacts__c 
                                                            WHERE Account__c =:accountId 
                                                            AND (Channel__c = 'EMAIL' OR Channel__c = 'SMS')
                                                            ORDER BY CreatedDate asc]){
                                                                recordInfo.put(communicationContact.Channel__c, communicationContact);
                                                            }
        
        return recordInfo;
        
    }*/

    @AuraEnabled
    public static ContactDetailsSection__c getContactDetailsSectionFromOpp(Id opportunityId){
        
        List<ContactDetailsSection__c> recordsContactDetailsSection = new List<ContactDetailsSection__c>();
        recordsContactDetailsSection = [SELECT Id,
                                        Email__c,
                                        Mobile__c,
                                        MobileStatus__c,
                                        MobileRejectReason__c,
                                        MobilePendingReason__c,
                                        MobileObservation__c,
                                        EmailStatus__c,
                                        EmailRejectReason__c,
                                        EmailPendingReason__c,
                                        EmailObservation__c
                                        FROM ContactDetailsSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        ORDER BY CreatedDate  DESC
                                        LIMIT 1];
        
        return recordsContactDetailsSection.isEmpty() ? new ContactDetailsSection__c() : recordsContactDetailsSection[0];
        
    }

    /*@AuraEnabled
    public static void upsertCommunicationContacts(List<CommunicationContacts__c> records){
        try {
            if(!records.isEmpty()){
                upsert records;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    
    @AuraEnabled
    public static void upsertContactDetailsSection(ContactDetailsSection__c record){
        try {
            SObjectUtils.upsertRecord(record);
         } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}