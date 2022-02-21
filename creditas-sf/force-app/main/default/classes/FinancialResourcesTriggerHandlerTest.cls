/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe FinancialResources
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o FinancialResourcesHandler
**********************************************************************************************************************************/
@isTest
public class FinancialResourcesTriggerHandlerTest {
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = true;
    }

}