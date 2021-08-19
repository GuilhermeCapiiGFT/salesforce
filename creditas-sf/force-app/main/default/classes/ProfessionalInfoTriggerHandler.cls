/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Empregos (ProfessionalInfo).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           13/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Empregos (ProfessionalInfo)
**********************************************************************************************************************************/
public without sharing class ProfessionalInfoTriggerHandler extends TriggerHandler
{
    private List<ProfessionalInfo__c> lstNewProfessionalInfo;
    private List<ProfessionalInfo__c> lstOldProfessionalInfo;
    private Map<Id, ProfessionalInfo__c> mapNewProfessionalInfo;
    private Map<Id, ProfessionalInfo__c> mapOldProfessionalInfo;
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Construtor
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0                    
    **********************************************************************************************************************************/
    public ProfessionalInfoTriggerHandler()
    {
        this.lstNewProfessionalInfo = (List<ProfessionalInfo__c>) Trigger.new;
        this.lstOldProfessionalInfo = (List<ProfessionalInfo__c>) Trigger.old;
        this.mapNewProfessionalInfo = (Map<Id, ProfessionalInfo__c>) Trigger.newMap;
        this.mapOldProfessionalInfo = (Map<Id, ProfessionalInfo__c>) Trigger.oldMap;
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
        String varSObjectApiName = 'ProfessionalInfo__c';
        
        Map<Id, Id> mapProfessionalInfoToAccount = new Map<Id, Id>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();
        
        List<Account> listAccountToUpdate = new List<Account>();

        for(ProfessionalInfo__c newProfessionalInfo : lstNewProfessionalInfo)
        {   
            mapProfessionalInfoToAccount.put(newProfessionalInfo.Id, newProfessionalInfo.Account__c);
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: mapProfessionalInfoToAccount.values()]); 

        for(ProfessionalInfo__c newProfessionalInfo : lstNewProfessionalInfo)
        {
            ProfessionalInfo__c oldProfessionalInfo = mapOldProfessionalInfo.get(newProfessionalInfo.Id);
    
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newProfessionalInfo.get(trackedField) != oldProfessionalInfo.get(trackedField))
                {     
                    Account varAccount = mapAccounts.get(oldProfessionalInfo.Account__c);
                    
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