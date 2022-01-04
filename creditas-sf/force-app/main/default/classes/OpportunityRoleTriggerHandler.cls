/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Opportunity Roles (OpportunityRole__c).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           20/10/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Opportunity Roles (OpportunityRole__c)
**********************************************************************************************************************************/
public without sharing class OpportunityRoleTriggerHandler extends TriggerHandler 
{
    private List<OpportunityRole__c> lstNewOpportunityRole;
    private List<OpportunityRole__c> lstOldOpportunityRole;
    private List<OpportunityRole__c> lstNewAccountRecordType;
    private List<OpportunityRole__c> lstOldAccountRecordType;
    private Map<Id, OpportunityRole__c> mapNewOpportunityRole;
    private Map<Id, OpportunityRole__c> mapOldOpportunityRole;
    
    
    public OpportunityRoleTriggerHandler() 
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
    }
    
    public override void afterInsert() 
    {
    }
    
    public override void beforeUpdate()
    {

    }
    
    public override void afterUpdate() 
    {      
		this.checkOpportunityRole();        
    }
    
    /**********************************************************************************************************************************
* ================================================================================================================================
* @description Caso o PRINCIPAL da Oportunidade seja pessoa física, somente será permitido que um dos participantes seja 
* configurado como o titular da conta bancária.
* ================================================================================================================================
* History
* -------
* VERSION     AUTHOR                  DATE            DETAIL      Description
* 1.0         Nathalia Rosa           20/10/21
**********************************************************************************************************************************/
    public void checkOpportunityRole()
    {  
        Boolean oppTitular = false;
        Set<Id> opportunityIds = new Set<Id>();
        
        for(OpportunityRole__c opportunityRoleNew :lstNewOpportunityRole){
            
            if(opportunityRoleNew.Titular_da_Conta__c){
                oppTitular = true;
            }
            opportunityIds.add(opportunityRoleNew.Opportunity__c);
        }
        
        if(oppTitular){
            Map<Id, List<OpportunityRole__c>> opportunityIdToOpportunityRolesMap = new Map<Id, List<OpportunityRole__c>>();
            
            List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c FROM OpportunityRole__c 
                                                            WHERE Opportunity__c IN :opportunityIds AND Titular_da_Conta__c = true AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
            
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
                if (opportunityRoleNew.Titular_da_Conta__c && ( oppRolesList.size() > 1 || (oppRolesList.size() == 1 && Trigger.isInsert))){
                    opportunityRoleNew.addError('JÁ EXISTE UM TITULAR DA CONTA BANCARIA, NÃO PODE ATUALIZAR, CASO NECESSARIO, DESABILITE O TITULAR ATUAL');
                }
            }
        }
    }   
}