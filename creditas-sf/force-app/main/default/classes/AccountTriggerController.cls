/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Handler padrão para a trigger do Objeto Conta (Account).
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           10/08/2021      Created     Implementação de handler voltado para uso da Trigger do objeto Conta (Account)
**********************************************************************************************************************************/
public without sharing class AccountTriggerController extends TriggerHandler
{
    private List<Account> lstNewAccount;
    private List<Account> lstOldAccount;
    private Map<Id, Account> mapNewAccount;
    private Map<Id, Account> mapOldAccount;
    
    public AccountTriggerController()
    {
        this.lstNewAccount = (List<Account>) Trigger.new;
        this.lstOldAccount = (List<Account>) Trigger.old;
        this.mapNewAccount = (Map<Id, Account>) Trigger.newMap;
        this.mapOldAccount = (Map<Id, Account>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        AccountTriggerService.verifyValidDocument(lstNewAccount);
    }
    
   public override void afterInsert() {
    }
    
    public override void beforeUpdate() {
        if(Test.isRunningTest()) { TriggerHelperClassToTest.metodoTeste(lstNewAccount); }
        AccountTriggerService.verifyValidDocument(lstNewAccount);
        AccountTriggerService.updateExternallySynced(lstNewAccount);
        AccountTriggerService.firePlatformEventSynchAccount(lstNewAccount);
    }
    
    public override void afterUpdate() {
    }
}