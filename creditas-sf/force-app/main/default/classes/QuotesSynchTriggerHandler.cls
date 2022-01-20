/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Quote.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Quote.
**********************************************************************************************************************************/
public without sharing class QuotesSynchTriggerHandler extends TriggerHandler
{
    private List<Quote> lstNewQuotes;
    private List<Quote> lstOldQuotes;
    private Map<Id, Quote> mapNewQuotes;
    private Map<Id, Quote> mapOldQuotes;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021           
    **********************************************************************************************************************************/
    public QuotesSynchTriggerHandler()
    {
        this.lstNewQuotes = (List<Quote>) Trigger.new;
        this.lstOldQuotes = (List<Quote>) Trigger.old;
        this.mapNewQuotes = (Map<Id, Quote>) Trigger.newMap;
        this.mapOldQuotes = (Map<Id, Quote>) Trigger.oldMap;
    }
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Método contextualizado before insert
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public override void beforeInsert()
    {
        this.updateOpportunityExternalFields();
    }
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Método contextualizado after insert
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public override void afterInsert() 
    {
        
    }
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Método contextualizado before update
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021           
    **********************************************************************************************************************************/
    public override void beforeUpdate()
    {
        this.updateMethod();
        this.updateOpportunityExternalFields();
    }
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Método contextualizado after update
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public override void afterUpdate() 

    {
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description atualizar campo isExternallySynced da Conta quando for PF
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021
    **********************************************************************************************************************************/
    private void updateMethod()
    {
        Util.updateIsExternallySyncedQuoteOpportunity('OpportunityId', lstNewQuotes, mapOldQuotes);
    }

     /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description preenche os campos de external id, version e tenant dos objetos relacionados à account
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021
    **********************************************************************************************************************************/
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