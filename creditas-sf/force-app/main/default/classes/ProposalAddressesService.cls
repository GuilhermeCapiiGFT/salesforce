public with sharing class ProposalAddressesService {
    
    @AuraEnabled
    public static List<Addresses__c> getAddress(Id accountId) {
        
        List<Addresses__c> recordInfo = new List<Addresses__c>();

        for(Addresses__c address : [SELECT Id, Street__c, Country__c, AreaLevel1__c, AreaLevel2__c, Neighborhood__c, PostalCode__c, Complement__c, StreetNumber__c
                                    FROM Addresses__c 
                                    WHERE Account__c =: accountId 
                                    ORDER BY CreatedDate asc LIMIT 1])
        {
            recordInfo.add(address);
        }

        return recordInfo;
    }

    @AuraEnabled
    public static AddressDataSection__c getAddressDataSection(Id opportunityId){
        
        List<AddressDataSection__c> recordsAddressDataSection = new List<AddressDataSection__c>();
        recordsAddressDataSection =    [SELECT Id, 
                                        CEPStatus__c,
                                        CEPPendingReason__c,
                                        CEPRejectReason__c,
                                        CEPobservation__c,
                                        StreetAddressStatus__c,
                                        StreetAddressPendingReason__c,
                                        StreetAddressRejectReason__c,
                                        StreetAddressObservation__c,
                                        AddressNumberStatus__c,
                                        AddressNumberPendingReason__c,
                                        AddressNumberRejectReason__c,
                                        AddressNumberObservation__c,
                                        AddOnStatus__c,
                                        AddOnPendingReason__c,
                                        AddOnRejectReason__c,
                                        AddOnObservation__c,
                                        NeighborhoodStatus__c,
                                        NeighborhoodPendingReason__c,
                                        NeighborhoodRejectReason__c,
                                        NeighborhoodObservation__c,
                                        CityStatus__c,
                                        CityPendingReason__c,
                                        CityRejectReason__c,
                                        CityObservation__c,
                                        StateStatus__c,
                                        StatePendingReason__c,
                                        StateRejectReason__c,
                                        StateObservation__c,
                                        CountryStatus__c
                                        FROM AddressDataSection__c
                                        WHERE Opportunity__c =: opportunityId
                                        LIMIT 1];
        
        return recordsAddressDataSection.isEmpty() ? new AddressDataSection__c() : recordsAddressDataSection[0];
    }

    @AuraEnabled
    public static void upsertAddress(List<Addresses__c> records){
        try {
            if(!records.isEmpty()){
                upsert records;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void upsertAddressSection(AddressDataSection__c record){
        try {
            upsert record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}