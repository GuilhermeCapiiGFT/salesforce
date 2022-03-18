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
                                            CPFStatus__c, CPFPendingReason__c, CPFRejectReason__c, CPFObservation__c,
                                            BirthCityStatus__c, BirthCountryStatus__c, BirthDateStatus__c,
                                            NationalityStatus__c,
                                            PoliticallyExposedPersonStatus__c, PersonExposedRejectReason__c, PoliticallyExposedPersonObservation__c,
                                            RGStatus__c, RGPendingReason__c, RGobservation__c, RGRejectReason__c,
                                            IssuingAgencyStatus__c,
                                            DispatchDateStatus__c, DispatchDateObservation__c, DateDispatchPendingReason__c,
                                            UFIssuingAgencyStatus__c, 
                                            CNHnumberStatus__c, CNHnumberPendingReason__c, CNHnumberObservation__c,
                                            CNHdispatchDateStatus__c, CNHdispatchDateObservation__c, CNHdispatchDatePendingReason__c,
                                            CNHissuingAgencyStatus__c, CNHissuingAgencyObservation__c, CNHissuingAgencyPendingReason__c

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

    public static Map<String, SObject> getDocuments(String recordId)
    {
        List<Documents__c> documents;
        Map<String, SObject> result = new Map<String, SObject>();

        try {
            documents = [SELECT Id, 
                                Name,
                                Account__c,
                                DocumentNumber__c, 
                                DocumentType__c, 
                                Issuer__c, 
                                IssueDate__c, 
                                IssuerState__c 
                                FROM Documents__c
                                WHERE Account__c = :recordId
                                AND (DocumentType__c = 'RG' OR DocumentType__c = 'CNH')
                                ORDER BY CreatedDate ASC];

                    
            System.debug('TYUMI => ' + JSON.serializePretty(documents));

            if(!documents.isEmpty()) 
            {
                for(Documents__c document : documents) 
                {
                    result.put(document.DocumentType__c, document);
                }
            }

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }
}