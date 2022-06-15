public virtual class OpportunityRepository extends Repository {

    virtual
    public Opportunity findById( String oppId ) {

        return [ SELECT Id, RecordType.DeveloperName, ExternalId__c, StageName,
                        ( Select Recurso_Financeiro__r.ExternalId__c from Garantia__r),
                        Account.ExternalId__c
                 FROM Opportunity
                 WHERE Id =: oppId];
    }
}