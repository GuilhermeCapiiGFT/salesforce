public virtual class OpportunityRepository extends Repository {

    virtual
    public Opportunity findById( String oppId ) {

        return [ SELECT Id, RecordType.DeveloperName, ExternalId__c, StageName, CrivoQuery__c,
                        ( Select Recurso_Financeiro__r.ExternalId__c from Garantia__r),
                        Account.ExternalId__c
                 FROM Opportunity
                 WHERE Id =: oppId];
    }

    virtual
    public Opportunity getOpportunityWithChildren(String opportunityId, List<String> objNameList, String numberOfRecords, String order){
        String childrenQuery = '';
        for(String objName : objNameList){
            childrenQuery += buildChildObjectQuery(objName, numberOfRecords, order) + ', ';
        }
        childrenQuery = childrenQuery.removeEnd(', ');

        List<String> sObjectFields = Util.selectAllFields('Opportunity');

        String query = 'SELECT ' +  String.join(sObjectFields, ', ') + ', RecordType.DeveloperName, ' + childrenQuery +
                       ' FROM Opportunity WHERE Id = :opportunityId';

        return Database.query(query.escapeUnicode());
    }

    private static String buildChildObjectQuery(String objName, String numberOfRecords, String order){
        List<String> sObjectFields = Util.selectAllFields(objName+'__c');
        String queryLimit = numberOfRecords == null ? '' : 'LIMIT ' + numberOfRecords;
        return '(SELECT ' + String.join(sObjectFields, ', ') + ' FROM ' + objName + '__r ORDER BY CreatedDate ' + order + ' ' + queryLimit + ' )';
    }
}