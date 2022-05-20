/**
 * @author Otávio Frank - GFT Brasil
 */
public virtual class PersonalDataSectionRepository {

    virtual 
    public List<PersonalDataSection__c> findLastPersonalDataSectionByOppId( String oppId ) {

        return [ SELECT Id, Name,NameStatus__c, 
                        CNHdispatchDatePendingReason__c, Name__c, 
                        MothersNameStatus__c, Mother__c, BirthDateStatus__c, AgeStatus__c, 
                        GenreFieldStatus__c, CPFStatus__c, RGStatus__c, IssuingAgencyStatus__c, 
                        DispatchDateStatus__c, MaritalStatus__c, PISStatus__c, RegistrationDateStatus__c, 
                        AdmissionDateStatus__c, LastModifyDateStatus__c, Father__c, BirthCountry__c, 
                        BirthDate__c, BirthCity__c, Nationality__c, PoliticallyExposed__c, CPF__c, 
                        RG__c, CNHnumber__c, IssueDate__c, CNHIssueDate__c, CNHIssuer__c, 
                        UFIssuingAgencyStatus__c, PersonalDataExternalId__c, IssuerState__c, Issuer__c, 
                        BirthDateRejectReason__c, CPFRejectReason__c, RGRejectReason__c, CPFPendingReason__c, 
                        RGPendingReason__c, DateDispatchPendingReason__c, Opportunity__c, FathersNameStatus__c, 
                        BirthDateObservation__c, CPFObservation__c, RGobservation__c, DispatchDateObservation__c,
                        CNHnumberStatus__c, CNHnumberObservation__c, CNHdispatchDateStatus__c, CNHdispatchDateObservation__c, 
                        CNHissuingAgencyStatus__c, CNHissuingAgencyObservation__c, BirthCityStatus__c, BirthCountryStatus__c, 
                        NationalityStatus__c, PoliticallyExposedPersonStatus__c, PoliticallyExposedPersonObservation__c, 
                        CNHnumberPendingReason__c, PersonExposedRejectReason__c, CNHissuingAgencyPendingReason__c, PersonalDataPending__c,
                        PersonalDataRejected__c, PersonalDataObservation__c 
                FROM PersonalDataSection__c
                WHERE Opportunity__c =: oppId
                ORDER BY CreatedDate DESC limit 1 ];
    }
}