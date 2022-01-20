/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Garantias (Garantias__c).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           13/10/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Garantias (Garantias__c)
**********************************************************************************************************************************/
public without sharing class GarantiasTriggerHandler extends TriggerHandler 
{
    private List<Garantias__c> lstNewGarantias;
    private List<Garantias__c> lstOldGarantias;
    private Map<Id, Garantias__c> mapNewGarantias;
    private Map<Id, Garantias__c> mapOldGarantias;
    final String GARANTIAS_ERROR_MESSAGE = System.Label.Garantias_Error_Message;

    public GarantiasTriggerHandler() 
    {
        this.lstNewGarantias = (List<Garantias__c>) Trigger.new;
        this.lstOldGarantias = (List<Garantias__c>) Trigger.old;
        this.mapNewGarantias = (Map<Id, Garantias__c>) Trigger.newMap;
        this.mapOldGarantias = (Map<Id, Garantias__c>) Trigger.oldMap;
    }


    public override void beforeInsert()
    {
        this.verifyOpportunityRole();
    }


    public override void afterInsert() 
    {
    }


    public override void beforeUpdate()
    {
        this.verifyOpportunityRole();
    }


    public override void afterUpdate() 
    {              
    }


    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description somente Recursos Financeiros possuídos por um "COLLATERAL_GUARANTOR" podem ser associados às garantias
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Gabriel Vidal           13/10/21
    **********************************************************************************************************************************/
    public void verifyOpportunityRole()
    {
        Set<Id> opportunityIds = new Set<Id>();
        for (Garantias__c garantiaNew : lstNewGarantias) 
        {
            opportunityIds.add(garantiaNew.Opportunity__c);
        }

        Map<Id, String> accountIdToRoleName = new Map<Id, String>();
        for (OpportunityRole__c oppRole : [ SELECT ExternalPersonId__c, Role__c 
                                            FROM OpportunityRole__c 
                                            WHERE Opportunity__c IN :opportunityIds])
        {
            accountIdToRoleName.put(oppRole.ExternalPersonId__c, oppRole.Role__c);
        }

        for (Garantias__c garantiaNew : lstNewGarantias) 
        {
            if (accountIdToRoleName.get(garantiaNew.Account__c) != 'COLLATERAL_GUARANTOR')
            {
                garantiaNew.addError(GARANTIAS_ERROR_MESSAGE);
            }
        }
    }
}