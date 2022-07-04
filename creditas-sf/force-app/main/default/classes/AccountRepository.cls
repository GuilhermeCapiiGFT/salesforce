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

    virtual
    public List<Account> getPersonAccountData(String externalId){
        List<Account> accList = [ SELECT Id, ExternalId__c,
                (SELECT Id, ExternalId__c FROM CommunicationContacts__r),
                (SELECT Id, ExternalAddressId__c FROM Addresses__r),
                (SELECT Id, ExternalId__c FROM Contas_Relacionadas__r),
                (SELECT Id, ExternalId__c FROM Documents__r),
                (SELECT Id, Recurso_Financeiro__r.Id, Recurso_Financeiro__r.ExternalId__c, Recurso_Financeiro__r.ProfessionalInfo__c FROM AccountFinancialRelationships__r),
                (SELECT Id, ExternalId__c FROM ProfessionalInfo__r),
                (SELECT Id, Type__c, Name__c FROM Filiation__r)
                FROM Account
                WHERE ExternalId__c = :externalId];
        return accList;
    }
}