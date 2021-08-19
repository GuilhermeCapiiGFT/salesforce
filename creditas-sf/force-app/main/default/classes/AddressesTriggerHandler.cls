/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Endereço (Addresses).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           13/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Endereço (Addresses)
**********************************************************************************************************************************/
public without sharing class AddressesTriggerHandler extends TriggerHandler
{
    private List<Addresses__c> lstNewAddresses;
    private List<Addresses__c> lstOldAddresses;
    private Map<Id, Addresses__c> mapNewAddresses;
    private Map<Id, Addresses__c> mapOldAddresses;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public AddressesTriggerHandler()
    {
        this.lstNewAddresses = (List<Addresses__c>) Trigger.new;
        this.lstOldAddresses = (List<Addresses__c>) Trigger.old;
        this.mapNewAddresses = (Map<Id, Addresses__c>) Trigger.newMap;
        this.mapOldAddresses = (Map<Id, Addresses__c>) Trigger.oldMap;
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
    * @param Addresses
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        String varSObjectApiName = 'Addresses__c';
        
        Set<Id> setAccountIds = new Set<Id>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();
        
        List<Account> listAccountToUpdate = new List<Account>();

        for(Addresses__c newAddress : lstNewAddresses)
        {   
            setAccountIds.add(newAddress.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: setAccountIds]); 
        Map<Account, Addresses__c> mapAccountToAddresses = new Map<Account, Addresses__c>();
    
        for(Addresses__c newAddress : lstNewAddresses)
        {
            Addresses__c oldAddress = mapOldAddresses.get(newAddress.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newAddress.get(trackedField) != oldAddress.get(trackedField))
                {     
                    mapAccountToAddresses.put(mapAccounts.get(oldAddress.Account__c), oldAddress);
                }
            }
        }

        for(Account varAccount : mapAccountToAddresses.keySet())
        {
            varAccount.IsExternallySynched__c = false;
            listAccountToUpdate.add(varAccount);
        }

        System.debug('tymi lista: ' + listAccountToUpdate);

        TriggerHandler.bypass('AccountTriggerHandler');
        if(!listAccountToUpdate.isEmpty())
        {
            update listAccountToUpdate;
        }
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
}