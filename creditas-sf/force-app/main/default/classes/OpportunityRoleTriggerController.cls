/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Default Controller for trigger OpportunityRoleTrigger.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           20/10/2021      Created     Default Controller for trigger OpportunityRoleTrigger.
**********************************************************************************************************************************/
public without sharing class OpportunityRoleTriggerController extends TriggerHandler 
{
    private List<OpportunityRole__c> lstNewOpportunityRole;
    private List<OpportunityRole__c> lstOldOpportunityRole;
    private List<OpportunityRole__c> lstNewAccountRecordType;
    private List<OpportunityRole__c> lstOldAccountRecordType;
    private Map<Id, OpportunityRole__c> mapNewOpportunityRole;
    private Map<Id, OpportunityRole__c> mapOldOpportunityRole;
    
    
    public OpportunityRoleTriggerController() 
    {
        this.lstNewOpportunityRole = (List<OpportunityRole__c>) Trigger.new;
        this.lstOldOpportunityRole = (List<OpportunityRole__c>) Trigger.old;
        this.lstNewAccountRecordType = (List<OpportunityRole__c>) Trigger.new;
        this.lstOldAccountRecordType = (List<OpportunityRole__c>) Trigger.old;
        this.mapNewOpportunityRole = (Map<Id, OpportunityRole__c>) Trigger.newMap;
        this.mapOldOpportunityRole = (Map<Id, OpportunityRole__c>) Trigger.oldMap;        
    }
    
    public override void beforeInsert()
    {
        this.checkOpportunityRole();
        this.updateOpportunityExternalFields();
    }
    
    public override void afterInsert() 
    {
    }
    
    public override void beforeUpdate()
    {
        this.updateMethod();
        this.updateOpportunityExternalFields();
    }
    
    public override void afterUpdate() 
    {      
		this.checkOpportunityRole();        
    }

    private void updateMethod()
    {
        Util.updateIsExternallySyncedOpportunity('OpportunityRole__c', lstNewOpportunityRole, mapOldOpportunityRole);
    }

    private void updateOpportunityExternalFields()
    {
        Set<Id> setOpportunityRoleIds = new Set<Id>();
        
        for(OpportunityRole__c varOpportunityRole : lstNewOpportunityRole)
        {
            setOpportunityRoleIds.add(varOpportunityRole.Opportunity__c);
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityRoleIds]);

        for(OpportunityRole__c varOpportunityRole : lstNewOpportunityRole)
        {
            varOpportunityRole.ExternalOpportunityId__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalId__c;
            varOpportunityRole.ExternalOpportunityVersion__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalVersion__c;
            varOpportunityRole.ExternalOpportunityTenant__c = mapOpportunity.get(varOpportunityRole.Opportunity__c).ExternalTenant__c;
        }        
    }
 
    public void checkOpportunityRole()
    {  
        Boolean accountOwner = false;
        Set<Id> opportunityIds = new Set<Id>();
        
        for(OpportunityRole__c opportunityRoleNew :lstNewOpportunityRole){
            
            if(opportunityRoleNew.AccountOwner__c){
                accountOwner = true;
            }
            opportunityIds.add(opportunityRoleNew.Opportunity__c);
        }
        
        if(accountOwner){
            Map<Id, List<OpportunityRole__c>> opportunityIdToOpportunityRolesMap = new Map<Id, List<OpportunityRole__c>>();
            
            List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c FROM OpportunityRole__c 
                                                            WHERE Opportunity__c IN :opportunityIds AND AccountOwner__c = true AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
            
            for(OpportunityRole__c opportunityRoleNew :listOpportunityRole){
                if(!opportunityIdToOpportunityRolesMap.containsKey(opportunityRoleNew.Opportunity__c)){
                    opportunityIdToOpportunityRolesMap.put(opportunityRoleNew.Opportunity__c, new List<OpportunityRole__c>());
                }
                opportunityIdToOpportunityRolesMap.get(opportunityRoleNew.Opportunity__c).add(opportunityRoleNew);
                
            }
            for(OpportunityRole__c opportunityRoleNew :lstNewOpportunityRole){
                List<OpportunityRole__c> oppRolesList = opportunityIdToOpportunityRolesMap.get(opportunityRoleNew.Opportunity__c);
                
                if (oppRolesList == null){
                    continue;
                }
                if (opportunityRoleNew.AccountOwner__c && ( oppRolesList.size() > 1 || (oppRolesList.size() == 1 && Trigger.isInsert))){
                   
                    opportunityRoleNew.addError('JÁ EXISTE UM TITULAR DA CONTA BANCARIA, NÃO PODE ATUALIZAR, CASO NECESSARIO, DESABILITE O TITULAR ATUAL');
                }
            }
        }
    }   
}