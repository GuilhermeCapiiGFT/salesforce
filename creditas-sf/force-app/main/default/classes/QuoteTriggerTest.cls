/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Testing Class for the QuoteTriggerTest
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           22/12/2021      Created     Testing Class for the QuoteTriggerController
**********************************************************************************************************************************/
@isTest
public class QuoteTriggerTest {    
    
    @TestSetup
    static void makeData()
    {   //Accounts to create a setting to Update a Multiple Quotes
        List<Account> accountList = new List<Account>();   
        Account accountJose = AccountSetup.createAccount('Jose', 'Pessoa_Fisica'); 
        accountJose.DocumentNumber__c = '276.050.350-04';
        accountJose.IsExternallySynched__c = true;
        accountList.add(accountJose);
            
        Account accountJoao = AccountSetup.createAccount('Joao', 'Pessoa_Fisica');     
        accountJoao.DocumentNumber__c = '891.582.300-17';
        accountJoao.IsExternallySynched__c = true;
        accountList.add(accountJoao);        
        
        Account accountJosimar = AccountSetup.createAccount('Josimar', 'Pessoa_Fisica');                   
        accountJosimar.DocumentNumber__c = '745.277.860-08';
        accountJosimar.IsExternallySynched__c = true;
        accountList.add(accountJosimar);

        insert accountList;
        

        //Opportunities to create a setting to updateIsExternallySync and Update a Multiple Quotes
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opportunityJoao = OpportunitySetup.createOpportunity(accountJoao.Id, 'Home');
        opportunityJoao.Name = 'Joao';
        opportunityJoao.IsExternallySynched__c = true;
        opportunityList.add(opportunityJoao);
                    
        Opportunity opportunityJose = OpportunitySetup.createOpportunity(accountJose.Id, 'Home');
        opportunityJose.Name = 'Jose';
        opportunityJose.IsExternallySynched__c = true;
        opportunityList.add(opportunityJose);
        
        Opportunity opportunityJosimar = OpportunitySetup.createOpportunity(accountJosimar.Id, 'Home');
        opportunityJosimar.Name = 'Josimar';
        opportunityJosimar.IsExternallySynched__c = true;
        opportunityList.add(opportunityJosimar);

        insert opportunityList;

        //Quotes to create a setting to updateIsExternallySync and Update a Multiple Quotes
        List<Quote> quoteList = new List<Quote>{
            new Quote(
                Name = 'Quote In Progress',
                Status = 'Em andamento',
                OpportunityId = opportunityJoao.Id
            ),
            new Quote(
                Name = 'Quote Lost',
                Status = 'Perdido',
                OpportunityId = opportunityJose.Id
            ),
            new Quote(
                Name = 'Quote name',
                Status = 'Finalizado',
                OpportunityId = opportunityJosimar.Id
            )

        };
        insert quoteList;
    }

    @isTest
    static void updateIsExternallySync() 
    {	//Create a setting of Quotes to Update
        Quote varQuote = [SELECT Id, Name, OpportunityId,Opportunity.isExternallySynched__c FROM Quote WHERE Name = 'Quote In Progress' LIMIT 1]; 
        varQuote.MonthlyIntRateCompValue__c = 400;   

        Test.startTest(); 
        //Testing Update Quotes
        update varQuote;
        Test.stopTest();
        
        //Assert for the field IsExternallySynched__c need to be false
        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalTenant__c, IsSynchEnabled__c
                                      FROM Opportunity
                                      WHERE Id =: varQuote.OpportunityId
                                      LIMIT 1];		
        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
    }

    @isTest
    static void updateMultipleQuote()
    {	//Create a setting of Account/Opportunity for Quote In Progress
        Account accountInProgress = [SELECT Id, Name FROM Account WHERE Name ='Joao'];        
        Opportunity opportunityInProgress = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountInProgress.Id
                                      LIMIT 1];
        
        //Create a setting of Account/Opportunity for Quote Lost
        Account accountLost = [SELECT Id, Name FROM Account WHERE Name ='Jose'];        
        Opportunity opportunityLost = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountLost.Id
                                      LIMIT 1];
        
        //Create a setting of Account/Opportunity for Quote Finished
        Account accountFinished = [SELECT Id, Name FROM Account WHERE Name ='Josimar'];        
        Opportunity opportunityFinished = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountFinished.Id
                                      LIMIT 1];
        
		//Create a Lists to test update and Insert 
        List<Quote> listQuoteInsert = new List<Quote>();
        List<Quote> listQuoteUpdate = new List<Quote>();
		
        //Insert Guarantees and populate the list
        for (Integer i = 0; i < 10; i++) 
        {
            Quote quoteInProgress = new Quote();
            quoteInProgress.Name = 'Quote In Progress';
            quoteInProgress.OpportunityId = opportunityInProgress.Id;
            quoteInProgress.ExternalOpportunityId__c = '12312312312412412';
            quoteInProgress.ExternalOpportunityTenant__c = opportunityInProgress.ExternalTenant__c;           
            listQuoteInsert.add(quoteInProgress); 
            
            Quote quoteLost = new Quote();
            quoteLost.Name = 'Quote Lost';
            quoteLost.OpportunityId = opportunityLost.Id;
            quoteLost.ExternalOpportunityId__c = '5656565856512';
            quoteLost.ExternalOpportunityTenant__c = opportunityLost.ExternalTenant__c;           
            listQuoteInsert.add(quoteLost);
            
            Quote quoteFinished = new Quote();
            quoteFinished.Name = 'Quote Finished';
            quoteFinished.OpportunityId = opportunityFinished.Id;
            quoteFinished.ExternalOpportunityId__c = '78787855412';
            quoteFinished.ExternalOpportunityTenant__c = opportunityFinished.ExternalTenant__c;           
            listQuoteInsert.add(quoteFinished);
        }

        insert listQuoteInsert;

        for(Quote varQuote : listQuoteInsert)
        {
            listQuoteUpdate.add(varQuote);
        }  
        
        Test.startTest(); 
        //Testing Update Multiple Quotes
        listQuoteUpdate[0].ExternalOpportunityTenant__c = 'creditasmx';
        opportunityInProgress.ExternalTenant__c = 'creditasmx';
        opportunityLost.ExternalTenant__c = 'creditasmx';
        opportunityFinished.ExternalTenant__c = 'creditasmx';
        
        upsert listQuoteUpdate;
        Test.stopTest();
		
        //Assert for the field IsExternallySynched__c need to be false
        Opportunity inProgressUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountInProgress.Id];
        Opportunity lostUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountLost.Id];
        Opportunity finishedUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountFinished.Id];
        
        System.assertEquals(false, inProgressUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
        System.assertEquals(false, lostUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
        System.assertEquals(false, finishedUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
    }
}