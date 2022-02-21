/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default handler for the QuoteTrigger
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     	Default handler for the QuoteTrigger
**********************************************************************************************************************************/
public without sharing class QuoteTriggerController extends TriggerHandler
{
    private List<Quote> lstNewQuotes;
    private List<Quote> lstOldQuotes;
    private Map<Id, Quote> mapNewQuotes;
    private Map<Id, Quote> mapOldQuotes;
    
    public QuoteTriggerController()
    {
        this.lstNewQuotes = (List<Quote>) Trigger.new;
        this.lstOldQuotes = (List<Quote>) Trigger.old;
        this.mapNewQuotes = (Map<Id, Quote>) Trigger.newMap;
        this.mapOldQuotes = (Map<Id, Quote>) Trigger.oldMap;
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
        Util.updateIsExternallySyncedOpportunity('Quote', lstNewQuotes, mapOldQuotes);
    }

    private void updateOpportunityExternalFields()
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for(Quote varQuotes : lstNewQuotes)
        {
            setOpportunityIds.add(varQuotes.OpportunityId);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);

        for(Quote varQuotes : lstNewQuotes)
        {
            varQuotes.ExternalOpportunityId__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalId__c;
            varQuotes.ExternalOpportunityVersion__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalVersion__c;
            varQuotes.ExternalOpportunityTenant__c = mapOpportunity.get(varQuotes.OpportunityId).ExternalTenant__c;
        }        
    }
}