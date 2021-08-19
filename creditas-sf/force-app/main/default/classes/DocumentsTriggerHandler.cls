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
        
        Map<Id, Id> mapDocumentsToAccount = new Map<Id, Id>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();
        
        List<Account> listAccountToUpdate = new List<Account>();

        for(Documents__c newDocuments : lstnewDocuments)
        {   
            mapDocumentsToAccount.put(newDocuments.Id, newDocuments.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: mapDocumentsToAccount.values()]); 

        for(Documents__c newDocuments : lstNewDocuments)
        {
            Documents__c oldDocuments = mapOldDocuments.get(newDocuments.Id);
    
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newDocuments.get(trackedField) != oldDocuments.get(trackedField))
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