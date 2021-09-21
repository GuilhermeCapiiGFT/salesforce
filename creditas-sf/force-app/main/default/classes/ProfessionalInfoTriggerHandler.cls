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
    * @param Documents
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        Util.updateIsExternallySynced('ProfessionalInfo__c', lstNewProfessionalInfo, mapOldProfessionalInfo);
    }

     /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description preenche os campos de external id, version e tenant dos objetos relacionados à account
    * @return void
    * @param ProfessionalInfo
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           11/08/21
    **********************************************************************************************************************************/
    private void updateAccountExternalFields()
    {
        Set<Id> setAccountIds = new Set<Id>();
        
        for(ProfessionalInfo__c varProfessionalInfo : lstNewProfessionalInfo)
        {
             setAccountIds.add(varProfessionalInfo.Account__c);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Account WHERE Id IN :setAccountIds]);

        for(ProfessionalInfo__c varProfessionalInfo : lstNewProfessionalInfo)
        {
            varProfessionalInfo.ExternalAccountId__c = mapAccounts.get(varProfessionalInfo.Account__c).ExternalId__c;
            varProfessionalInfo.ExternalAccountVersion__c = mapAccounts.get(varProfessionalInfo.Account__c).ExternalVersion__c;
            varProfessionalInfo.ExternalAccountTenant__c = mapAccounts.get(varProfessionalInfo.Account__c).ExternalTenant__c;
        }        
    }
}