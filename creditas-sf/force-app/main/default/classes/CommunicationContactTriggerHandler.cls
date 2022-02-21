/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto CommunicationContact (CommunicationContact).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           23/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Empregos (CommunicationContact)
**********************************************************************************************************************************/
public without sharing class CommunicationContactTriggerHandler extends TriggerHandler
{
    private List<CommunicationContacts__c> lstNewCommunicationContact;
    private List<CommunicationContacts__c> lstOldCommunicationContact;
    private Map<Id, CommunicationContacts__c> mapNewCommunicationContact;
    private Map<Id, CommunicationContacts__c> mapOldCommunicationContact;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public CommunicationContactTriggerHandler()
    {
        this.lstNewCommunicationContact = (List<CommunicationContacts__c>) Trigger.new;
        this.lstOldCommunicationContact = (List<CommunicationContacts__c>) Trigger.old;
        this.mapNewCommunicationContact = (Map<Id, CommunicationContacts__c>) Trigger.newMap;
        this.mapOldCommunicationContact = (Map<Id, CommunicationContacts__c>) Trigger.oldMap;
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
    * @param CommunicationContact
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           23/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        Util.updateIsExternallySynced('CommunicationContacts__c', lstNewCommunicationContact, mapOldCommunicationContact);
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
        
        for(CommunicationContacts__c varComunicationContacts : lstNewCommunicationContact)
        {
             setAccountIds.add(varComunicationContacts.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(CommunicationContacts__c varComunicationContacts : lstNewCommunicationContact)
        {
            varComunicationContacts.ExternalAccountId__c = mapAccounts.get(varComunicationContacts.Account__c)?.ExternalId__c;
            varComunicationContacts.ExternalAccountVersion__c = mapAccounts.get(varComunicationContacts.Account__c)?.ExternalVersion__c;
            varComunicationContacts.ExternalAccountTenant__c = mapAccounts.get(varComunicationContacts.Account__c)?.ExternalTenant__c;
        }        
    }
}