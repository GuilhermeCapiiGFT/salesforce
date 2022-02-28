public without sharing class OpportunityRoleTriggerController extends TriggerHandler 
{
    private List<OpportunityRole__c> newOpportunityRoles;
    private List<OpportunityRole__c> oldOpportunityRoles;
    private Map<Id, OpportunityRole__c> newOpportunityRolesById;
    private Map<Id, OpportunityRole__c> oldOpportunityRolesById;
    
    
    public OpportunityRoleTriggerController() 
    {
        this.newOpportunityRoles = (List<OpportunityRole__c>) Trigger.new;
        this.oldOpportunityRoles = (List<OpportunityRole__c>) Trigger.old;
        this.newOpportunityRolesById = (Map<Id, OpportunityRole__c>) Trigger.newMap;
        this.oldOpportunityRolesById = (Map<Id, OpportunityRole__c>) Trigger.oldMap;        
    }
    
    public override void beforeInsert()
    {
        OpportunityRoleTriggerService.validateOpportunityRoles(newOpportunityRoles);
        OpportunityRoleTriggerService.updateExternalFields(newOpportunityRoles);
    }
    
    public override void afterInsert() 
    {
        OpportunityRoleTriggerService.updateOpportunityIsExternallySynced(newOpportunityRoles, oldOpportunityRolesById);
    }
    
    public override void beforeUpdate()
    {
        OpportunityRoleTriggerService.validateOpportunityRoles(newOpportunityRoles);
        OpportunityRoleTriggerService.updateExternalFields(newOpportunityRoles);
    }
    
    public override void afterUpdate() 
    {
        OpportunityRoleTriggerService.updateOpportunityIsExternallySynced(newOpportunityRoles, oldOpportunityRolesById);
    }    
}