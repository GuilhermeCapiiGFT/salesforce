/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default Controller for trigger GarantiasTrigger
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           13/10/2021      Created     Default Controller for trigger GarantiasTrigger
* 1.1       Nathalia Rosa           28/02/2022      Updated     Created GarantiasTriggerService and sepate methods of calls
**********************************************************************************************************************************/
public without sharing class GarantiasTriggerController extends TriggerHandler 
    {
        private List<Garantias__c> lstNewGarantias;
        private List<Garantias__c> lstOldGarantias;
        private Map<Id, Garantias__c> mapNewGarantias;
        private Map<Id, Garantias__c> mapOldGarantias;
        final String GARANTIAS_ERROR_MESSAGE = System.Label.Garantias_Error_Message;
        
        public GarantiasTriggerController() 
        {
            this.lstNewGarantias = (List<Garantias__c>) Trigger.new;
            this.lstOldGarantias = (List<Garantias__c>) Trigger.old;
            this.mapNewGarantias = (Map<Id, Garantias__c>) Trigger.newMap;
            this.mapOldGarantias = (Map<Id, Garantias__c>) Trigger.oldMap;
        }
        
        public override void beforeInsert()
        {
            GarantiasTriggerService.verifyOpportunityRole(lstNewGarantias);
            GarantiasTriggerService.updateOpportunityExternalFields(lstNewGarantias);        
        }
        
        public override void afterInsert() 
        {
        }
        
        public override void beforeUpdate()
        {
            GarantiasTriggerService.verifyOpportunityRole(lstNewGarantias);
            GarantiasTriggerService.updateMethod(lstNewGarantias, mapOldGarantias);
            GarantiasTriggerService.updateOpportunityExternalFields(lstNewGarantias);
        }
        
        public override void afterUpdate() 
        {              
        }
                
}