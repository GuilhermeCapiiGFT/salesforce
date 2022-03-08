public with sharing class ProposalService {
    
    public static Map<String, SObject> getPersonalDataSectionRecord(String recordId) 
    {
        List<PersonalDataSection__c> personalDataSection = new List<PersonalDataSection__c>();
        Map<String, SObject> result = new Map<String, SObject>();

        try {
            personalDataSection = [SELECT   Id, 
                                            Opportunity__c, 
                                            Name, 
                                            NameStatus__c, 
                                            FathersNameStatus__c,
                                            MothersNameStatus__c,
                                            CPFStatus__c,
                                            CPFPendingReason__c,
                                            CPFRejectReason__c,
                                            CPFDescription__c,
                                            BirthCityStatus__c,
                                            BirthCountryStatus__c,
                                            BirthDateStatus__c,
                                            NationalityStatus__c,
                                            PoliticallyExposedPersonStatus__c 
                                            FROM PersonalDataSection__c
                                            WHERE Opportunity__c =: recordId
                                            LIMIT 1];
            
            if(!personalDataSection.isEmpty()) {
                result.put('dadosPessoais', personalDataSection[0]);
            }

            return result;
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}