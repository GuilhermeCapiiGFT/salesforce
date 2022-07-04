public with sharing class AccFinRelationshipTriggerController extends TriggerHandler {
    private List<AccountFinancialRelationship__c> lstNewAccountFinancialRelationship;
    private List<AccountFinancialRelationship__c> lstOldAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapNewAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapOldAccountFinancialRelationship;

    public AccFinRelationshipTriggerController() {
        this.lstNewAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.new;
        this.lstOldAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.old;
        this.mapNewAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.newMap;
        this.mapOldAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
    }

    public override void afterInsert() {
        AccFinRelationshipTriggerService.updateIsExternallySynced(lstNewAccountFinancialRelationship);
    }

    public override void beforeUpdate() {
    }

    public override void afterUpdate() {
        AccFinRelationshipTriggerService.updateIsExternallySynced(lstNewAccountFinancialRelationship);
    }
}

