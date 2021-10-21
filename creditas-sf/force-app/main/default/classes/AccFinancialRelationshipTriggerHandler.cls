/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Relações Financeiras (AccountFinancialRelationship__c).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal           07/10/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Relações Financeiras (AccountFinancialRelationship__c)
**********************************************************************************************************************************/
public without sharing class AccFinancialRelationshipTriggerHandler extends TriggerHandler
{
    private List<AccountFinancialRelationship__c> lstNewAccountFinancialRelationship;
    private List<AccountFinancialRelationship__c> lstOldAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapNewAccountFinancialRelationship;
    private Map<Id, AccountFinancialRelationship__c> mapOldAccountFinancialRelationship;

    public AccFinancialRelationshipTriggerHandler() 
    {
        this.lstNewAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.new;
        this.lstOldAccountFinancialRelationship = (List<AccountFinancialRelationship__c>) Trigger.old;
        this.mapNewAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.newMap;
        this.mapOldAccountFinancialRelationship = (Map<Id, AccountFinancialRelationship__c>) Trigger.oldMap;
    }


    public override void beforeInsert()
    {
    }


    public override void afterInsert() 
    {
        this.updateIsExternallySynced();
    }


    public override void beforeUpdate()
    {
    }


    public override void afterUpdate() 
    {       
        this.updateIsExternallySynced();
    }



    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description atualizar campo isExternallySynced da Conta quando for criada ou atualizada uma Relação Financeira
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Gabriel Vidal           07/10/21
    **********************************************************************************************************************************/
    private void updateIsExternallySynced()
    {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountsToUpdateIds = new Set<Id>();

        for (AccountFinancialRelationship__c accFinancialRelationship : lstNewAccountFinancialRelationship)
        {
            Id accountId = accFinancialRelationship.Account__c;
            if (accountId != null && !accountsToUpdateIds.contains(accountId))
            {
                accountsToUpdateIds.add(accountId);
                
                accountsToUpdate.add(new Account(
                    Id = accFinancialRelationship.Account__c,
                    IsExternallySynched__c = false
                ));
            }
        }

        TriggerHandler.clearBypass('AccountTriggerHandler');
        update accountsToUpdate;
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }


}