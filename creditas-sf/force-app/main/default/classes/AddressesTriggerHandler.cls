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
        this.updateMethod();
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
    * @param Addresses
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21
    **********************************************************************************************************************************/
    private void updateMethod()
    {
        Util.updateIsExternallySynced('Addresses__c', lstNewAddresses, mapOldAddresses);
    }

     /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description preenche os campos de external id, version e tenant dos objetos relacionados à account
    * @return void
    * @param Addresses
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           11/08/21
    **********************************************************************************************************************************/
    private void updateAccountExternalFields()
    {
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Addresses__c varAddress : lstNewAddresses)
        {
             setAccountIds.add(varAddress.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(Addresses__c varAddress : lstNewAddresses)
        {
            varAddress.ExternalAccountId__c = mapAccounts.get(varAddress.Account__c).ExternalId__c;
            varAddress.ExternalAccountVersion__c = mapAccounts.get(varAddress.Account__c).ExternalVersion__c;
            varAddress.ExternalAccountTenant__c = mapAccounts.get(varAddress.Account__c).ExternalTenant__c;
        }        
    }
}