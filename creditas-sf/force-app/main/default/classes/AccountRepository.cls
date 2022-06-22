public virtual class AccountRepository extends Repository {
    
    virtual
    public Account getAccountWithChildren(String accId, List<String> objNameList){
        String childrenQuery = '';
        for(String objName : objNameList){
            childrenQuery += buildChildObjectQuery(objName) + ', ';
        }
        childrenQuery = childrenQuery.removeEnd(', ');

        List<String> sObjectFields = Util.selectAllFields('Account');

        String query = 'SELECT ' +  String.join(sObjectFields, ', ') + ', RecordType.DeveloperName, ' + childrenQuery +
                       ' FROM Account WHERE Id = :accId';

        return Database.query(query.escapeUnicode());
    }

    private static String buildChildObjectQuery(String objName){
        List<String> sObjectFields = Util.selectAllFields(objName+'__c');
        return '(SELECT ' + String.join(sObjectFields, ', ') + ' FROM ' + objName + '__r ORDER BY CreatedDate DESC)';
    }
}