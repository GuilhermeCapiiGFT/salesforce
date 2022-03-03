public with sharing class FinancialResourcesTriggerController extends TriggerHandler {
    private List<FinancialResources__c> lstNewFinancialResources;
    private List<FinancialResources__c> lstOldFinancialResources;
    private Map<Id, FinancialResources__c> mapNewFinancialResources;
    private Map<Id, FinancialResources__c> mapOldFinancialResources;
    
    public FinancialResourcesTriggerController() {
        this.lstNewFinancialResources = (List<FinancialResources__c>) Trigger.new;
        this.lstOldFinancialResources = (List<FinancialResources__c>) Trigger.old;
        this.mapNewFinancialResources = (Map<Id, FinancialResources__c>) Trigger.newMap;
        this.mapOldFinancialResources = (Map<Id, FinancialResources__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
    }
    
    public override void afterInsert() {
    }
    
    public override void beforeUpdate() {
        FinancialResourcesTriggerService.updateIsExternallySynced(lstNewFinancialResources);
    }
    
    
    public override void afterUpdate(){
    }
}