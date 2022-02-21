/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default Controller for trigger OpportunityProcessTrigger
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     Default Controller for trigger OpportunityProcessTrigger
**********************************************************************************************************************************/
public without sharing class OpportunityProcessTriggerController extends TriggerHandler
{
    private List<OpportunityProcess__c> lstNewOppProcess;
    private List<OpportunityProcess__c> lstOldOppProcess;
    private Map<Id, OpportunityProcess__c> mapNewOppProcess;
    private Map<Id, OpportunityProcess__c> mapOldOppProcess;
 
    public OpportunityProcessTriggerController()
    {
        this.lstNewOppProcess = (List<OpportunityProcess__c>) Trigger.new;
        this.lstOldOppProcess = (List<OpportunityProcess__c>) Trigger.old;
        this.mapNewOppProcess = (Map<Id, OpportunityProcess__c>) Trigger.newMap;
        this.mapOldOppProcess = (Map<Id, OpportunityProcess__c>) Trigger.oldMap;
    }
   
    public override void beforeInsert()
    {
        this.updateOpportunityExternalFields();
    }
    
    public override void afterInsert() 
    {
        
    }
    
    public override void beforeUpdate()
    {
        this.updateMethod();
        this.updateOpportunityExternalFields();
    }
    
    public override void afterUpdate()
    {

    }

    private void updateMethod()
    {
        Util.updateIsExternallySyncedOpportunity('OpportunityProcess__c', lstNewOppProcess, mapOldOppProcess);
    }

    private void updateOpportunityExternalFields()
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for(OpportunityProcess__c varOppProcess : lstNewOppProcess)
        {
            setOpportunityIds.add(varOppProcess.Opportunity__c);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);

        for(OpportunityProcess__c varOppProcess : lstNewOppProcess)
        {
            varOppProcess.ExternalOpportunityId__c = mapOpportunity.get(varOppProcess.Opportunity__c).ExternalId__c;
            varOppProcess.ExternalOpportunityVersion__c = mapOpportunity.get(varOppProcess.Opportunity__c).ExternalVersion__c;
            varOppProcess.ExternalOpportunityTenant__c = mapOpportunity.get(varOppProcess.Opportunity__c).ExternalTenant__c;
        }        
    }
}