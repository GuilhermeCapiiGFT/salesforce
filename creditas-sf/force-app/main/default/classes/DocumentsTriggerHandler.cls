/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Documentos (Documents).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           13/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Documentos (Documents)
**********************************************************************************************************************************/
public without sharing class DocumentsTriggerHandler extends TriggerHandler
{
    private List<Documents__c> lstNewDocuments;
    private List<Documents__c> lstOldDocuments;
    private Map<Id, Documents__c> mapNewDocuments;
    private Map<Id, Documents__c> mapOldDocuments;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public DocumentsTriggerHandler()
    {
        this.lstNewDocuments = (List<Documents__c>) Trigger.new;
        this.lstOldDocuments = (List<Documents__c>) Trigger.old;
        this.mapNewDocuments = (Map<Id, Documents__c>) Trigger.newMap;
        this.mapOldDocuments = (Map<Id, Documents__c>) Trigger.oldMap;
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
        String varSObjectApiName = 'Documents__c';
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();  
        Map<Account, Documents__c> mapAccountToDocuments = new Map<Account, Documents__c>();  
        Set<Id> setAccountIds = new Set<Id>();
        List<Account> listAccountToUpdate = new List<Account>();

        for(Documents__c newDocument : lstNewDocuments)
        {   
            setAccountIds.add(newDocument.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: setAccountIds]); 
        
        for(Documents__c newDocument : lstNewDocuments)
        {
            Documents__c oldDocument = mapOldDocuments.get(newDocument.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newDocument.get(trackedField) != oldDocument.get(trackedField))
                {     
                    mapAccountToDocuments.put(mapAccounts.get(oldDocument.Account__c), oldDocument);
                }
            }
        }

        if(!mapAccountToDocuments.isEmpty())
        {
            for(Account varAccount : mapAccountToDocuments.keySet())
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