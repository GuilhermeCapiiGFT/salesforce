/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default Controller for trigger GarantiasTrigger
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           13/10/2021      Created     Default Controller for trigger GarantiasTrigger
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
            this.verifyOpportunityRole();
            this.updateOpportunityExternalFields();
        }
        
        public override void afterInsert() 
        {
        }
        
        public override void beforeUpdate()
        {
            this.verifyOpportunityRole();
            this.updateMethod();
            this.updateOpportunityExternalFields();
        }
        
        public override void afterUpdate() 
        {              
        }
        
        private void updateMethod()
        {
            Util.updateIsExternallySyncedOpportunity('Garantias__c', lstNewGarantias, mapOldGarantias);
        }
        
        private void updateOpportunityExternalFields()
        {
            Set<Id> setOpportunityIds = new Set<Id>();
            
            for(Garantias__c varGarantia : lstNewGarantias)
            {
                setOpportunityIds.add(varGarantia.Opportunity__c);
            }
            
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);
            
            for(Garantias__c varGarantia : lstNewGarantias)
            {
                varGarantia.ExternalOpportunityId__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalId__c;
                varGarantia.ExternalOpportunityVersion__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalVersion__c;
                varGarantia.ExternalOpportunityTenant__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalTenant__c;
            }        
        }
        
        public void verifyOpportunityRole()
        {
            Set<Id> opportunityIds = new Set<Id>();
            for (Garantias__c garantiaNew : lstNewGarantias) 
            {
                opportunityIds.add(garantiaNew.Opportunity__c);
            }
            
            Map<Id, String> accountIdToRoleName = new Map<Id, String>();
            for (OpportunityRole__c oppRole : [ SELECT ExternalPersonId__c, Role__c 
                                               FROM OpportunityRole__c 
                                               WHERE Opportunity__c IN :opportunityIds])
            {
                accountIdToRoleName.put(oppRole.ExternalPersonId__c, oppRole.Role__c);
            }
            
            for (Garantias__c garantiaNew : lstNewGarantias) 
            {
                if (accountIdToRoleName.get(garantiaNew.Account__c) != 'COLLATERAL_GUARANTOR')
                {
                    garantiaNew.addError(GARANTIAS_ERROR_MESSAGE);
                }
            }
        }
}