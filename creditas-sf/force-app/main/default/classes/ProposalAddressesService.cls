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
                                        AddressNumberStatus__c,
                                        Complement__c,
                                        AddOnStatus__c,
                                        AddOnRejectReason__c,
                                        AddOnObservation__c,
                                        Neighborhood__c,
                                        NeighborhoodStatus__c,
                                        AreaLevel2__c,
                                        CityStatus__c,
                                        AreaLevel1__c,
                                        StateStatus__c,
                                        Country__c,
                                        CountryStatus__c
                                        FROM AddressDataSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1];
        
        return recordsAddressDataSection.isEmpty() ? new AddressDataSection__c() : recordsAddressDataSection[0];
    }

}