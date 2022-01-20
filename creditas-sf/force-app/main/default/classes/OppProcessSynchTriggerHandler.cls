/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do botão de sincronizar do Objeto OppProcessSynchTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     Implementação de handler voltado para uso da trigger do botão de 
															   sincronizar do Objeto OppProcessSynchTriggerHandler
**********************************************************************************************************************************/
public without sharing class OppProcessSynchTriggerHandler extends TriggerHandler
{
    private List<OpportunityProcess__c> lstNewOppProcess;
    private List<OpportunityProcess__c> lstOldOppProcess;
    private Map<Id, OpportunityProcess__c> mapNewOppProcess;
    private Map<Id, OpportunityProcess__c> mapOldOppProcess;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021           
    **********************************************************************************************************************************/
    public OppProcessSynchTriggerHandler()
    {
        this.lstNewOppProcess = (List<OpportunityProcess__c>) Trigger.new;
        this.lstOldOppProcess = (List<OpportunityProcess__c>) Trigger.old;
        this.mapNewOppProcess = (Map<Id, OpportunityProcess__c>) Trigger.newMap;
        this.mapOldOppProcess = (Map<Id, OpportunityProcess__c>) Trigger.oldMap;
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
        Util.updateIsExternallySyncedOpportunity('OpportunityProcess__c', lstNewOppProcess, mapOldOppProcess);
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