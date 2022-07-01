public virtual class FinancialResourcesRepository extends Repository {
    
    virtual
    public List<FinancialResources__c> findByIds(Set<Id> financialResourcesIds) {

        return [ SELECT ResourceKey__c, Plate__c, ModelYear__c, 
                        ManufacturingYear__c, Brand__c,Model__c, Color__c,
                        LicensingState__c, State__c, ExternalCodeOrigin__c,
                        Chassis__c, RecordTypeId, ExternalId__c, Amount__c,
                        Type__c
                FROM FinancialResources__c
                WHERE Id IN :financialResourcesIds 
                WITH SECURITY_ENFORCED 
                ORDER BY ExternalUpdatedDate__c DESC ];
    }
}