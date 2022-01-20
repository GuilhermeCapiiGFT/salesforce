/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe OppRoleSynchTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           22/12/2021      Created     Classe de teste para o OppRoleSynchTriggerHandler
**********************************************************************************************************************************/
@isTest
public class OppRoleSynchTriggerHandlerTest {    
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount1 = TestSetup.getAccount('Jose', true); 
        varAccount1.DocumentNumber__c = '276.050.350-04';
        update varAccount1;
            
        Account varAccount2 = TestSetup.getAccount('Joao', true);        
        varAccount2.DocumentNumber__c = '891.582.300-17';
        update varAccount2;
        
        Account varAccount3 = TestSetup.getAccount('Josimar', true);                     
        varAccount3.DocumentNumber__c = '745.277.860-08';
        update varAccount3;
        
        Opportunity varOpportunity1 = TestSetup.getOpportunity(varAccount1.Id, true);
        varOpportunity1.Name = 'Joao';
        
        Opportunity varOpportunity2 = TestSetup.getOpportunity(varAccount2.Id, true);
        varOpportunity1.Name = 'Jose';
        
        Opportunity varOpportunity3 = TestSetup.getOpportunity(varAccount3.Id, true);
        varOpportunity1.Name = 'Josimar';
        
        OpportunityRole__c varOppoRole1 = TestSetup.getOppRole(varAccount1, varOpportunity1, 'PRINCIPAL', false, true);
        OpportunityRole__c varOppoRole2 = TestSetup.getOppRole(varAccount2, varOpportunity2, 'SOLIDARY_DEBTOR', false, true);
        OpportunityRole__c varOppoRole3 = TestSetup.getOppRole(varAccount3, varOpportunity3, 'COLLATERAL_GUARANTOR', false, true); 
    }

    @isTest
    static void updateIsExternallySync() 
    {
        OpportunityRole__c varOpportunityRole = [SELECT Id, Name, Opportunity__c FROM OpportunityRole__c LIMIT 1]; 

        Test.startTest();
        update varOpportunityRole;
        Test.stopTest();

        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c,
                              ExternalTenant__c, IsSynchEnabled__c
                              FROM Opportunity
                              WHERE Id =: varOpportunityRole.Opportunity__c 
                              LIMIT 1];

        System.debug('NROSA');
        System.debug(varOpportunityRole);
        System.debug(varOpportunity);

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
        List<OpportunityRole__c> listOpportunityRoleInsert = new List<OpportunityRole__c>();
        List<OpportunityRole__c> listOpportunityRoleUpdate = new List<OpportunityRole__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            OpportunityRole__c varOpportunityRole = new OpportunityRole__c();
            varOpportunityRole.Opportunity__c = varOpportunity.Id;
            varOpportunityRole.ExternalOpportunityId__c = varOpportunity.ExternalId__c;
            varOpportunityRole.ExternalOpportunityTenant__c = varOpportunity.ExternalTenant__c;
            varOpportunityRole.ExternalOppVersion__c = varOpportunity.ExternalVersion__c;
            varOpportunityRole.ExternalPersonId__c = varAccount.Id;

            listOpportunityRoleInsert.add(varOpportunityRole);    
        }

        insert listOpportunityRoleInsert;

        for(OpportunityRole__c varOpportunityRole : listOpportunityRoleInsert)
        {
            listOpportunityRoleUpdate.add(varOpportunityRole);
        }
        
        Test.startTest();
        update listOpportunityRoleUpdate;
        Test.stopTest();

        Opportunity varOpportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: varAccount.Id LIMIT 1];

        System.debug('nrosa opportunityUpdate => ' + varOpportunityUpdate);

        System.assertEquals(false, varOpportunityUpdate.IsExternallySynched__c);
    }
   
}