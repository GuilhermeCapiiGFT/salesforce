/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Quote.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          21/12/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Quote.
**********************************************************************************************************************************/
public without sharing class GarantiaSynchTriggerHandler extends TriggerHandler
{
    private List<Garantias__c> lstNewGarantia;
    private List<Garantias__c> lstOldGarantia;
    private Map<Id, Garantias__c> mapNewGarantia;
    private Map<Id, Garantias__c> mapOldGarantia;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          21/12/2021           
    **********************************************************************************************************************************/
    public GarantiaSynchTriggerHandler()
    {
        this.lstNewGarantia = (List<Garantias__c>) Trigger.new;
        this.lstOldGarantia = (List<Garantias__c>) Trigger.old;
        this.mapNewGarantia = (Map<Id, Garantias__c>) Trigger.newMap;
        this.mapOldGarantia = (Map<Id, Garantias__c>) Trigger.oldMap;
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
    * 1.0         Nathalia Rosa          21/12/2021
    **********************************************************************************************************************************/
    private void updateMethod()
    {
        Util.updateIsExternallySyncedOpportunity('Garantias__c', lstNewGarantia, mapOldGarantia);
    }

     /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description preenche os campos de external id, version e tenant dos objetos relacionados à account
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          21/12/2021
    **********************************************************************************************************************************/
    private void updateOpportunityExternalFields()
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for(Garantias__c varGarantia : lstNewGarantia)
        {
            setOpportunityIds.add(varGarantia.Opportunity__c);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);

        for(Garantias__c varGarantia : lstNewGarantia)
        {
            varGarantia.ExternalOpportunityId__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalId__c;
            varGarantia.ExternalOpportunityVersion__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalVersion__c;
            varGarantia.ExternalOpportunityTenant__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalTenant__c;
        }        
    }
}