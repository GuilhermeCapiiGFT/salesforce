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
public class QuotesSynchTriggerHandlerTest {    
    
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
        varOpportunity1.IsExternallySynched__c = true;
                    
        Opportunity varOpportunity2 = TestSetup.getOpportunity(varAccount2.Id, true);
        varOpportunity2.Name = 'Jose';
        varOpportunity2.IsExternallySynched__c = true;

        Opportunity varOpportunity3 = TestSetup.getOpportunity(varAccount3.Id, true);
        varOpportunity3.Name = 'Josimar';
        varOpportunity3.IsExternallySynched__c = true;

        Quote varQuote1 = new Quote();
        varQuote1.Name = 'Quote name';
        varQuote1.Status = 'Em andamento';
        varQuote1.OpportunityId = varOpportunity1.Id;
        insert varQuote1;
        
        Quote varQuote2 = new Quote();
        varQuote2.Name = 'Quote name';
        varQuote2.Status = 'Perdido';
        varQuote2.OpportunityId = varOpportunity2.Id;
        insert varQuote2;
        
        Quote varQuote3 = new Quote();
        varQuote3.Name = 'Quote name';
        varQuote3.Status = 'Finalizado';
        varQuote3.OpportunityId = varOpportunity3.Id;
        insert varQuote3;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Quote varQuote = [SELECT Id, Name, OpportunityId FROM Quote LIMIT 1]; 
        varQuote.ExternalOpportunityTenant__c = 'creditasbr';

        Test.startTest();        
        upsert varQuote;
        Test.stopTest();

        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c,
                              ExternalTenant__c, IsSynchEnabled__c
                              FROM Opportunity
                              WHERE Id =: varQuote.OpportunityId
                              LIMIT 1];

        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultipleQuote()
    {
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        Opportunity varOpportunity = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: varAccount.Id
                                      LIMIT 1];

        List<Quote> listQuoteInsert = new List<Quote>();
        List<Quote> listQuoteUpdate = new List<Quote>();

        for (Integer i = 0; i < 10; i++) 
        {
            Quote varQuote = new Quote();
            varQuote.Name = 'Quote Name';
            varQuote.OpportunityId = varOpportunity.Id;
            varQuote.ExternalOpportunityId__c = '12312312312412412';
            varQuote.ExternalOpportunityTenant__c = varOpportunity.ExternalTenant__c;            

            listQuoteInsert.add(varQuote);    
        }

        insert listQuoteInsert;

        for(Quote varQuote : listQuoteInsert)
        {
            listQuoteUpdate.add(varQuote);
        }  
        
        Test.startTest();
        system.debug('>>>> ' + listQuoteUpdate[0].ExternalOpportunityTenant__c);
        listQuoteUpdate[0].ExternalOpportunityTenant__c = 'creditasmx';
        varOpportunity.ExternalTenant__c = 'creditasmx';
        upsert listQuoteUpdate;
        Test.stopTest();

        Opportunity varOpportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: varAccount.Id LIMIT 1];

        System.assertEquals(false, varOpportunityUpdate.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }
}