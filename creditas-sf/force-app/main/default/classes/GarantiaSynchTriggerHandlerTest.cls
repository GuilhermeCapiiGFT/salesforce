/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe GarantiaSynchTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           27/12/2021      Created     Classe de teste para a classe GarantiaSynchTriggerHandler
**********************************************************************************************************************************/
@isTest
public class GarantiaSynchTriggerHandlerTest {    
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount1 = TestSetup.getAccount('Jose', true); 
        varAccount1.DocumentNumber__c = '276.050.350-04';
        varAccount1.isExternallySynched__C = true;
        update varAccount1;
            
        Account varAccount2 = TestSetup.getAccount('Joao', true);        
        varAccount2.DocumentNumber__c = '891.582.300-17';
        varAccount2.isExternallySynched__C = true;
        update varAccount2;
        
        Account varAccount3 = TestSetup.getAccount('Josimar', true);                     
        varAccount3.DocumentNumber__c = '745.277.860-08';
        varAccount3.isExternallySynched__C = true;
        update varAccount3;
        
        Opportunity varOpportunity1 = TestSetup.getOpportunity(varAccount1.Id, true);
        varOpportunity1.Name = 'Joao';
        
        Opportunity varOpportunity2 = TestSetup.getOpportunity(varAccount2.Id, true);
        varOpportunity1.Name = 'Jose';
        
        Opportunity varOpportunity3 = TestSetup.getOpportunity(varAccount3.Id, true);
        varOpportunity1.Name = 'Josimar';
        
        OpportunityRole__c varOppoRole1 = TestSetup.getOppRole(varAccount1, varOpportunity1, 'COLLATERAL_GUARANTOR', false, true);
        varOppoRole1.Role__c = 'COLLATERAL_GUARANTOR';
        
            
        OpportunityRole__c varOppoRole2 = TestSetup.getOppRole(varAccount2, varOpportunity2, 'COLLATERAL_GUARANTOR', false, true);
        varOppoRole2.Role__c = 'COLLATERAL_GUARANTOR';
        
        OpportunityRole__c varOppoRole3 = TestSetup.getOppRole(varAccount3, varOpportunity3, 'COLLATERAL_GUARANTOR', false, true);
        varOppoRole3.Role__c = 'COLLATERAL_GUARANTOR';
        
        FinancialResources__c varFinancialResources1 = TestSetup.getNewFinRes('Recurso Financeiro 1', true);     
        FinancialResources__c varFinancialResources2 = TestSetup.getNewFinRes('Recurso Financeiro 2', true);
        FinancialResources__c varFinancialResources3 = TestSetup.getNewFinRes('Recurso Financeiro 3', true); 
        
        Garantias__c varGuarantees1 = TestSetup.getGuarantees(varAccount1, varOpportunity1, varFinancialResources1, true);
        Garantias__c varGuarantees2 = TestSetup.getGuarantees(varAccount2, varOpportunity2, varFinancialResources2, true);
        Garantias__c varGuarantees3 = TestSetup.getGuarantees(varAccount3, varOpportunity3, varFinancialResources3, true); 

    }

    @isTest
    static void updateIsExternallySync() 
    {
        Garantias__c varGuarantees = [SELECT Id, Name, Opportunity__c, ExternalOpportunityTenant__c FROM Garantias__c LIMIT 1]; 
        varGuarantees.ExternalOpportunityTenant__c = 'creditasbr';
        Test.startTest();
        varGuarantees.ExternalOpportunityTenant__c = 'creditasmx';
        update varGuarantees;
        Test.stopTest();

        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c,
                              ExternalTenant__c, IsSynchEnabled__c
                              FROM Opportunity
                              WHERE Id =: varGuarantees.Opportunity__c 
                              LIMIT 1];

        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultipleOpportunityRole()
    {
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        Opportunity varOpportunity = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: varAccount.Id 
                                      LIMIT 1];
        
        FinancialResources__c varFinancialResources = [SELECT Id, Name FROM FinancialResources__c LIMIT 1];
        
        List<Garantias__c> listGuaranteesInsert = new List<Garantias__c>();
        List<Garantias__c> listGuaranteesUpdate = new List<Garantias__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            Garantias__c varGuarantees = new Garantias__c();
            varGuarantees.Account__c = varAccount.Id;
            varGuarantees.Opportunity__c = varOpportunity.Id;
            varGuarantees.Recurso_Financeiro__c = varFinancialResources.Id;
            varGuarantees.ExternalOpportunityId__c = varOpportunity.ExternalId__c;
            varGuarantees.ExternalOpportunityTenant__c = varOpportunity.ExternalTenant__c;
            varGuarantees.ExternalOpportunityVersion__c = varOpportunity.ExternalVersion__c;  

            listGuaranteesInsert.add(varGuarantees);    
        }

        insert listGuaranteesInsert;

        for(Garantias__c varGuarantees : listGuaranteesInsert)
        {
            listGuaranteesUpdate.add(varGuarantees);
        }
        
        Test.startTest();
        update listGuaranteesUpdate;
        Test.stopTest();

        Opportunity varOpportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: varAccount.Id LIMIT 1];
        System.assertEquals(false, varOpportunityUpdate.IsExternallySynched__c);
    }
   
}