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
        this.RECORDTYPE_CONTA_PESSOA_FISICA = getAccountRecordTypeId('Pessoa_Fisica');
        this.RECORDTYPE_CONTA_PESSOA_JURIDICA = getAccountRecordTypeId('Pessoa_Juridica');
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
        this.verifyValidDocument();
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
        this.verifyDocumentDuplicates();
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
        this.verifyValidDocument();
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
        this.verifyDocumentDuplicates();
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description pegar id do tipo de registro
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         
    **********************************************************************************************************************************/
    private static Id getAccountRecordTypeId(String recordTypeName)
    {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description verificar se os campos rastreados mudaram de valor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           11/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        String varSObjectApiName = 'Account';
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
                if(newAccount.get(trackedField) != oldAccount.get(trackedField))
                {
                    newAccount.IsExternallySynched__c = false;
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

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description fazer validação do cpf
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           29/09/21
    **********************************************************************************************************************************/
    public void verifyValidDocument()
    {
        for(Account varAccount : lstNewAccount)
        { 
            if(varAccount.RecordTypeId.equals(RECORDTYPE_CONTA_PESSOA_FISICA))
            {
                validaDocumento(varAccount);

                if(String.isNotBlank(varAccount.DocumentNumber__c))
                {
                    String cpf = Util.getMaskedCPF(varAccount.DocumentNumber__c);
                    varAccount.DocumentNumber__c = cpf;
                }
            } else if(varaccount.RecordTypeId.equals(RECORDTYPE_CONTA_PESSOA_JURIDICA))
            {
                validaDocumento(varAccount);

                if(String.isNotBlank(varAccount.DocumentNumber__c))
                {
                    String cnpj = Util.getMaskedCNPJ(varAccount.DocumentNumber__c);
                    varAccount.DocumentNumber__c = cnpj;
                }
            }
        }
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description fazer validação do cpf
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21
    **********************************************************************************************************************************/
    private void validaDocumento(Account varAccount)
    {
        if(String.isNotBlank(varAccount.DocumentNumber__c))
        {
            if(!Util.isValidDocumentNumber(varAccount.DocumentNumber__c) && varAccount.DocumentType__c.equals('CPF'))
            {
                varAccount.DocumentNumber__c.addError('O CPF não é válido.');
            } 

            else if(!Util.isValidDocumentNumber(varAccount.DocumentNumber__c) && varAccount.DocumentType__c.equals('CNPJ'))
            {
                varAccount.DocumentNumber__c.addError('O CNPJ não é válido.');
            }
        }
    }

    /* ================================================================================================================================
    * @description fazer validação do cpf
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Gabriel Vidal          06/10/21
    **********************************************************************************************************************************/
    public void verifyDocumentDuplicates()
    {
        Set<String> documentKeysNew = new Set<String>();
        Set<String> existingDocumentKeys = new Set<String>();

        for(Account varAccount : lstNewAccount)
        {
            if (documentKeysNew.contains(varAccount.DocumentKey__c) && varAccount.DocumentNumber__c != null)
            {
                varAccount.DocumentNumber__c.addError('Já existe uma conta com este número de documento.');
            } else
            {
                documentKeysNew.add(varAccount.DocumentKey__c);
            }

        }

        for(Account acc : [SELECT DocumentKey__c FROM Account WHERE DocumentKey__c IN :documentKeysNew AND Id NOT IN :mapNewAccount.keySet()])
        {
            existingDocumentKeys.add(acc.DocumentKey__c);
        }

        for(Account varAccount : lstNewAccount)
        {
            if (existingDocumentKeys.contains(varAccount.DocumentKey__c) && varAccount.DocumentNumber__c != null)
            {
                varAccount.DocumentNumber__c.addError('Já existe uma conta com este número de documento.');
            }
        }
    }
}