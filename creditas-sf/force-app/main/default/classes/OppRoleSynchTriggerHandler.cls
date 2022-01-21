/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto OpportunityRole__c.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          17/12/2021      Created     Implementação de handler voltado para uso da Trigger do objeto OpportunityRole__c
**********************************************************************************************************************************/
public without sharing class OppRoleSynchTriggerHandler extends TriggerHandler
{
    private List<OpportunityRole__c> lstNewOpportunityRole;
    private List<OpportunityRole__c> lstOldOpportunityRole;
    private Map<Id, OpportunityRole__c> mapNewOpportunityRole;
    private Map<Id, OpportunityRole__c> mapOldOpportunityRole;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa          17/12/2021           
    **********************************************************************************************************************************/
    public OppRoleSynchTriggerHandler()
    {
        this.lstNewOpportunityRole = (List<OpportunityRole__c>) Trigger.new;
        this.lstOldOpportunityRole = (List<OpportunityRole__c>) Trigger.old;
        this.mapNewOpportunityRole = (Map<Id, OpportunityRole__c>) Trigger.newMap;
        this.mapOldOpportunityRole = (Map<Id, OpportunityRole__c>) Trigger.oldMap;
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
        Util.updateIsExternallySyncedOpportunity('OpportunityRole__c', lstNewOpportunityRole, mapOldOpportunityRole);
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
        Set<Id> setOpportunityRoleIds = new Set<Id>();
        
        for(OpportunityRole__c varOpportunityRole : lstNewOpportunityRole)
        {
            setOpportunityRoleIds.add(varOpportunityRole.Opportunity__c);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityRoleIds]);

        for(OpportunityRole__c varOpportunityRole : lstNewOpportunityRole)
        {
            varOpportunityRole.ExternalOpportunityId__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalId__c;
            varOpportunityRole.ExternalOpportunityVersion__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalVersion__c;
            varOpportunityRole.ExternalOpportunityTenant__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalTenant__c;
        }        
    }
}