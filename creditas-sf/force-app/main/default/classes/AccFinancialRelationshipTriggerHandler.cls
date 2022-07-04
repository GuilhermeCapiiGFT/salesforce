public without sharing class AccFinancialRelationshipTriggerHandler extends TriggerHandler
{
    private List<AccountFinancialRelationship__c> lstNewAccountFinancialRelationship;
    private List<AccountFinancialRelationship__c> lstOldAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapNewAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapOldAccountFinancialRelationship;

    public AccFinancialRelationshipTriggerHandler() 
    {
        this.lstNewAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.new;
        this.lstOldAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.old;
        this.mapNewAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.newMap;
        this.mapOldAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.oldMap;
    }


    public override void beforeInsert()
    {
    }


    public override void afterInsert() 
    {
        this.updateIsExternallySynced();
    }


    public override void beforeUpdate()
    {
    }


    public override void afterUpdate() 
    {       
        this.updateIsExternallySynced();
    }

    private void updateIsExternallySynced()
    {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountsToUpdateIds = new Set<Id>();

        for (AccountFinancialRelationship__c accFinancialRelationship : lstNewAccountFinancialRelationship)
        {
            String accountId = accFinancialRelationship?.Account__c;
            if (String.isNotBlank(accountId) && !accountsToUpdateIds.contains(accountId))
            {
                accountsToUpdateIds.add(accountId);
                
                accountsToUpdate.add(new Account(
                    Id = accountId,
                    IsExternallySynched__c = false
                ));
            }
        }
        TriggerHandler.bypass('AccountTriggerController');
        update accountsToUpdate;
        TriggerHandler.clearBypass('AccountTriggerController');
    }


}