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
public without sharing class ProfessionalInfoTriggerController extends TriggerHandler
{
    private List<ProfessionalInfo__c> newProfessionalInfos;
    private List<ProfessionalInfo__c> oldProfessionalInfos;
    private Map<Id, ProfessionalInfo__c> newProfessionalInfosById;
    private Map<Id, ProfessionalInfo__c> oldProfessionalInfosById;

    public ProfessionalInfoTriggerController()
    {
        this.newProfessionalInfos= (List<ProfessionalInfo__c>) Trigger.new;
        this.oldProfessionalInfos = (List<ProfessionalInfo__c>) Trigger.old;
        this.newProfessionalInfosById = (Map<Id, ProfessionalInfo__c>) Trigger.newMap;
        this.oldProfessionalInfosById = (Map<Id, ProfessionalInfo__c>) Trigger.oldMap;
    }

    public override void beforeInsert()
    {
        ProfessionalInfoTriggerService.updateAccountExternalFields(newProfessionalInfos);
    }
    
    public override void beforeUpdate()
    {
        ProfessionalInfoTriggerService.updateIsExternallySynced(newProfessionalInfos, oldProfessionalInfosById);
        ProfessionalInfoTriggerService.updateAccountExternalFields(newProfessionalInfos);
    }
}