/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Conta (Account).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           10/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Conta (Account)
**********************************************************************************************************************************/
public without sharing class AccountTriggerHandler extends TriggerHandler
{
    private List<Account> lstNewAccount;
    private List<Account> lstOldAccount;
    private Map<Id, Account> mapNewAccount;
    private Map<Id, Account> mapOldAccount;
    private final Id RECORDTYPE_CONTA_PESSOA_FISICA;
    private final Id RECORDTYPE_CONTA_PESSOA_JURIDICA;
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public AccountTriggerHandler()
    {
        this.lstNewAccount = (List<Account>) Trigger.new;
        this.lstOldAccount = (List<Account>) Trigger.old;
        this.mapNewAccount = (Map<Id, Account>) Trigger.newMap;
        this.mapOldAccount = (Map<Id, Account>) Trigger.oldMap;
        this.RECORDTYPE_CONTA_PESSOA_FISICA = getAccountRecordTypeId('Pessoa Física');
        this.RECORDTYPE_CONTA_PESSOA_JURIDICA = getAccountRecordTypeId('Pessoa Jurídica');
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
        this.firePlatformEventSynchAccount();
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
    * @description pegar id do tipo de registro
    * @return id do tipo de registro
    * @param nome do tipo de registro
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         
    **********************************************************************************************************************************/
    private static Id getAccountRecordTypeId(String recordTypeName)
    {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description verificar se os campos rastreados mudaram de valor
    * @return boolean
    * @param Account
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           11/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        String varSObjectApiName = 'Account';
        
        //String trackedField = '';
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);
        }
        
        for(Account newAccount : mapNewAccount.values())
        {
            Account oldAccount = mapOldAccount.get(newAccount.Id);

            for(String trackedField : mapTrackedFields.keySet())
            {
                System.debug('tracked field: ' + trackedField);

                if(newAccount.get(trackedField) != oldAccount.get(trackedField))
                {
                    newAccount.IsExternallySynched__c = false;
                 
                    System.debug('limit: ' + Limits.getCpuTime());
                    System.debug('campo rastreado >>> ' + trackedField + ' <<< teve seu valor alterado');
                    System.debug('TYUMI => ' + newAccount.IsExternallySynched__c);
                }
            }
        }
    }
    

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description disparar o evento de plataforma quando a conta for sincronizada
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Gabriel Vidal           13/08/2021
    **********************************************************************************************************************************/
    private void firePlatformEventSynchAccount()
    {
        for(Account newAccount : mapNewAccount.values())
        {
            if (newAccount.IsSynchEnabled__c == 'ENABLED')
            {               
                SynchAccount__e synch = new SynchAccount__e(); 
                DataBase.SaveResult sr = EventBus.publish(synch);
            }
        }
    }
}