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
    * @param Documents
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        String varSObjectApiName = 'FinancialResources__c';
        
        Map<Id, Id> mapFinancialToAccount = new Map<Id, Id>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();
        
        List<Account> listAccountToUpdate = new List<Account>();

        for(FinancialResources__c newFinancial : lstNewFinancialResources)
        {   
            mapFinancialToAccount.put(newFinancial.Id, newFinancial.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: mapFinancialToAccount.values()]); 

        for(FinancialResources__c newFinancial : lstNewFinancialResources)
        {
            FinancialResources__c oldDocuments = mapOldFinancialResources.get(newFinancial.Id);
    
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newFinancial.get(trackedField) != oldDocuments.get(trackedField))
                {     
                    Account varAccount = mapAccounts.get(oldDocuments.Account__c);
                    
                    varAccount.IsExternallySynched__c = false;
                    listAccountToUpdate.add(varAccount);

                    System.debug('campo rastreado >>> ' + trackedField + ' <<< teve seu valor alterado');
                    System.debug('tyumi => new value: ' +  varAccount.IsExternallySynched__c);
                }
            }
        }

        update listAccountToUpdate;
    }
}