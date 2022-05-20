public with sharing class ProposalAddressesService {
    
    @AuraEnabled
    public static AddressDataSection__c getAddressDataSection(Id opportunityId){
        
        List<AddressDataSection__c> recordsAddressDataSection = new List<AddressDataSection__c>();
        recordsAddressDataSection =    [SELECT Id, 
                                        PostalCode__c,
                                        CEPStatus__c,
                                        CEPPendingReason__c,
                                        CEPRejectReason__c,
                                        CEPobservation__c,
                                        Street__c,
                                        StreetNumber__c,
                                        StreetAddressStatus__c,
                                        StreetAddressPendingReason__c,
                                        StreetAddressRejectReason__c,
                                        StreetAddressObservation__c,
                                        AddressNumberStatus__c,
                                        AddressNumberPendingReason__c,
                                        AddressNumberRejectReason__c,
                                        AddressNumberObservation__c,
                                        Complement__c,
                                        AddOnStatus__c,
                                        AddOnPendingReason__c,
                                        AddOnRejectReason__c,
                                        AddOnObservation__c,
                                        Neighborhood__c,
                                        NeighborhoodStatus__c,
                                        NeighborhoodPendingReason__c,
                                        NeighborhoodRejectReason__c,
                                        NeighborhoodObservation__c,
                                        AreaLevel2__c,
                                        CityStatus__c,
                                        CityPendingReason__c,
                                        CityRejectReason__c,
                                        CityObservation__c,
                                        AreaLevel1__c,
                                        StateStatus__c,
                                        StatePendingReason__c,
                                        StateRejectReason__c,
                                        StateObservation__c,
                                        Country__c,
                                        CountryStatus__c,
                                        CountryObservation__c
                                        FROM AddressDataSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1];
        
        return recordsAddressDataSection.isEmpty() ? new AddressDataSection__c() : recordsAddressDataSection[0];
    }

}