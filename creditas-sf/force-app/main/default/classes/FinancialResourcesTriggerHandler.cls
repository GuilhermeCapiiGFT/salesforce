/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Recursos Financeiros (FinancialResources).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           13/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Recursos Financeiros (FinancialResources)
**********************************************************************************************************************************/
public without sharing class FinancialResourcesTriggerHandler extends TriggerHandler
{
    private List<FinancialResources__c> lstNewFinancialResources;
    private List<FinancialResources__c> lstOldFinancialResources;
    private Map<Id, FinancialResources__c> mapNewFinancialResources;
    private Map<Id, FinancialResources__c> mapOldFinancialResources;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public FinancialResourcesTriggerHandler()
    {
        this.lstNewFinancialResources = (List<FinancialResources__c>) Trigger.new;
        this.lstOldFinancialResources = (List<FinancialResources__c>) Trigger.old;
        this.mapNewFinancialResources = (Map<Id, FinancialResources__c>) Trigger.newMap;
        this.mapOldFinancialResources = (Map<Id, FinancialResources__c>) Trigger.oldMap;
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
        this.updateAccountExternalFields();
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
    * 1.0                    
    **********************************************************************************************************************************/
    public override void beforeUpdate()
    {
        this.updateIsExternallySynced();
        this.updateAccountExternalFields();
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
    * @return void
    * @param Financial Resource
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        Util.updateIsExternallySynced('FinancialResources__c', lstNewFinancialResources, mapOldFinancialResources);
    }

     /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description preenche os campos de external id, version e tenant dos objetos relacionados à account
    * @return void
    * @param FinancialResources
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           11/08/21
    **********************************************************************************************************************************/
    private void updateAccountExternalFields()
    {
        Set<Id> setAccountIds = new Set<Id>();
        
        for(FinancialResources__c varFinancialResources : lstNewFinancialResources)
        {
             setAccountIds.add(varFinancialResources.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(FinancialResources__c varFinancialResources : lstNewFinancialResources)
        {
            varFinancialResources.ExternalAccountId__c = mapAccounts.get(varFinancialResources.Account__c).ExternalId__c;
            varFinancialResources.ExternalAccountVersion__c = mapAccounts.get(varFinancialResources.Account__c).ExternalVersion__c;
            varFinancialResources.ExternalAccountTenant__c = mapAccounts.get(varFinancialResources.Account__c).ExternalTenant__c;
        }        
    }
}