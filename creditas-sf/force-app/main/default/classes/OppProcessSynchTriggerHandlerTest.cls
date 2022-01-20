/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe OppProcessSynchTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           27/12/2021      Created     Classe de teste para a classe OppProcessSynchTriggerHandler
**********************************************************************************************************************************/
@isTest
public class OppProcessSynchTriggerHandlerTest {    
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount1 = TestSetup.getAccount('Jose', true); 
        varAccount1.DocumentNumber__c = '276.050.350-04';
        varAccount1.IsExternallySynched__c = true;
        update varAccount1;
            
        Account varAccount2 = TestSetup.getAccount('Joao', true);        
        varAccount2.DocumentNumber__c = '891.582.300-17';
        varAccount2.IsExternallySynched__c = true;
        update varAccount2;
        
        Account varAccount3 = TestSetup.getAccount('Josimar', true);                     
        varAccount3.DocumentNumber__c = '745.277.860-08';
        varAccount3.IsExternallySynched__c = true;
        update varAccount3;
        
        Opportunity varOpportunity1 = TestSetup.getOpportunity(varAccount1.Id, true);
        varOpportunity1.Name = 'Joao';
        
        Opportunity varOpportunity2 = TestSetup.getOpportunity(varAccount2.Id, true);
        varOpportunity1.Name = 'Jose';
        
        Opportunity varOpportunity3 = TestSetup.getOpportunity(varAccount3.Id, true);
        varOpportunity1.Name = 'Josimar';
		
        OpportunityProcess__c varOppProcess1 = new OpportunityProcess__c();         
        varOppProcess1.Opportunity__c = varOpportunity1.Id; 
        varOppProcess1.ExternalOpportunityId__c = varOpportunity1.ExternalId__c;
        varOppProcess1.ExternalOpportunityTenant__c = varOpportunity1.ExternalTenant__c;
        varOppProcess1.ExternalOpportunityVersion__c = varOpportunity1.ExternalVersion__c;
       
         insert varOppProcess1;

    }

    @isTest
    static void updateIsExternallySync() 
    {
        OpportunityProcess__c varGuarantees = [SELECT Id, Name, Opportunity__c FROM OpportunityProcess__c LIMIT 1]; 

        Test.startTest();
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
        
        
        List<OpportunityProcess__c> listOppProcessInsert = new List<OpportunityProcess__c>();
        List<OpportunityProcess__c> listOppProcessUpdate = new List<OpportunityProcess__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            OpportunityProcess__c varOppProcess = new OpportunityProcess__c();            
            varOppProcess.Opportunity__c = varOpportunity.Id;  
            varOppProcess.ExternalOpportunityId__c = varOpportunity.ExternalId__c;
            varOppProcess.ExternalOpportunityTenant__c = varOpportunity.ExternalTenant__c;
            varOppProcess.ExternalOpportunityVersion__c = varOpportunity.ExternalVersion__c; 
          

            listOppProcessInsert.add(varOppProcess);    
        }

        insert listOppProcessInsert;

        for(OpportunityProcess__c varOppProcess : listOppProcessInsert)
        {
            listOppProcessUpdate.add(varOppProcess);
        }
        
        Test.startTest();
        update listOppProcessUpdate;
        Test.stopTest();

        Opportunity varOpportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: varAccount.Id LIMIT 1];

        System.assertEquals(false, varOpportunityUpdate.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }
   
}