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
        String varSObjectApiName = 'FinancialResources__c';
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();  
        Map<Account, FinancialResources__c> mapAccountToFinancial = new Map<Account, FinancialResources__c>();  
        Set<Id> setAccountIds = new Set<Id>();
        List<Account> listAccountToUpdate = new List<Account>();

        for(FinancialResources__c newFinancialResource : lstNewFinancialResources)
        {   
            setAccountIds.add(newFinancialResource.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: setAccountIds]); 
        
        for(FinancialResources__c newFinancialResource : lstNewFinancialResources)
        {
            FinancialResources__c oldFinancialResource = mapOldFinancialResources.get(newFinancialResource.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newFinancialResource.get(trackedField) != oldFinancialResource.get(trackedField))
                {     
                    mapAccountToFinancial.put(mapAccounts.get(oldFinancialResource.Account__c), oldFinancialResource);
                }
            }
        }

        if(!mapAccountToFinancial.isEmpty())
        {
            for(Account varAccount : mapAccountToFinancial.keySet())
            {
                varAccount.IsExternallySynched__c = false;
                listAccountToUpdate.add(varAccount);
            }
        }

        TriggerHandler.bypass('AccountTriggerHandler');
        if(!listAccountToUpdate.isEmpty())
        {
            update listAccountToUpdate;
        }
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
}