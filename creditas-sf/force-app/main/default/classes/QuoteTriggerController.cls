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
   
    public override void beforeInsert(){
        QuoteTriggerService.updateOpportunityExternalFields(lstNewQuotes);
    }
    
    public override void afterInsert(){
        
    }
    
    public override void beforeUpdate(){
        Util.updateIsExternallySyncedOpportunity('Quote', lstNewQuotes, mapOldQuotes);
        QuoteTriggerService.updateOpportunityExternalFields(lstNewQuotes);
    }
    
    public override void afterUpdate(){
        
    }
}