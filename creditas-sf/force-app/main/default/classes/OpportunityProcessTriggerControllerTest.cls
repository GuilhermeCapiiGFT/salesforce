/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Testing Class for the OpportunityProcessTriggerController
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           27/12/2021      Created     Testing Class for the OpportunityProcessTriggerController
**********************************************************************************************************************************/
@isTest
public class OpportunityProcessTriggerControllerTest {    
    
    @TestSetup
    static void makeData()
    {   
        //Accounts to create a setting to Update a OpportunityProcess      
        Account accountJose = TestSetup.getAccount('Jose', true); 
        accountJose.DocumentNumber__c = '276.050.350-04';
        accountJose.IsExternallySynched__c = true;
        update accountJose;
            
        Account accountJoao = TestSetup.getAccount('Joao', true);        
        accountJoao.DocumentNumber__c = '891.582.300-17';
        accountJoao.IsExternallySynched__c = true;
        update accountJoao;
        
        Account accountJosimar = TestSetup.getAccount('Josimar', true);                     
        accountJosimar.DocumentNumber__c = '745.277.860-08';
        accountJosimar.IsExternallySynched__c = true;
        update accountJosimar;
        
        //Opportunities to create a setting to updateIsExternallySync and updateMultipleOpportunityProcess
        Opportunity opportunityJose = TestSetup.getOpportunity(accountJose.Id, true);
        opportunityJose.Name = 'Joao';
        update opportunityJose;
        
        Opportunity opportunityJoao = TestSetup.getOpportunity(accountJoao.Id, true);
        opportunityJoao.Name = 'Jose';
        update opportunityJose;
        
        Opportunity opportunityJosimar = TestSetup.getOpportunity(accountJosimar.Id, true);
        opportunityJosimar.Name = 'Josimar';
        update opportunityJosimar;
		
        //Quotes to create a setting to updateIsExternallySync and updateMultipleOpportunityProcess
        OpportunityProcess__c opportunityProcess = new OpportunityProcess__c();         
        opportunityProcess.Opportunity__c = opportunityJose.Id; 
        opportunityProcess.ExternalOpportunityId__c = opportunityJose.ExternalId__c;
        opportunityProcess.ExternalOpportunityTenant__c = opportunityJose.ExternalTenant__c;
        opportunityProcess.ExternalOpportunityVersion__c = opportunityJose.ExternalVersion__c;
        insert opportunityProcess;

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
        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
    }

    @isTest
    static void updateMultipleOpportunityProcess()
    {	
        Account accountJose = [SELECT Id, Name FROM Account WHERE Name = 'Jose'];        
        Opportunity opportunityJose = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountJose.Id]; 
        
        Account accountJoao = [SELECT Id, Name FROM Account WHERE Name = 'Joao'];        
        Opportunity opportunityJoao = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountJoao.Id]; 
        
        Account accountJosimar = [SELECT Id, Name FROM Account WHERE Name = 'Josimar'];        
        Opportunity opportunityJosimar = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: accountJosimar.Id];
        
        
        List<OpportunityProcess__c> listOppProcessInsert = new List<OpportunityProcess__c>();
        List<OpportunityProcess__c> listOppProcessUpdate = new List<OpportunityProcess__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            OpportunityProcess__c oppProcessJoao = new OpportunityProcess__c();            
            oppProcessJoao.Opportunity__c = opportunityJoao.Id;  
            oppProcessJoao.ExternalOpportunityId__c = opportunityJoao.ExternalId__c;
            oppProcessJoao.ExternalOpportunityTenant__c = opportunityJoao.ExternalTenant__c;
            oppProcessJoao.ExternalOpportunityVersion__c = opportunityJoao.ExternalVersion__c;         
            listOppProcessInsert.add(oppProcessJoao); 
            
            OpportunityProcess__c oppProcessJose = new OpportunityProcess__c();            
            oppProcessJose.Opportunity__c = opportunityJose.Id;  
            oppProcessJose.ExternalOpportunityId__c = opportunityJose.ExternalId__c;
            oppProcessJose.ExternalOpportunityTenant__c = opportunityJose.ExternalTenant__c;
            oppProcessJose.ExternalOpportunityVersion__c = opportunityJose.ExternalVersion__c;         
            listOppProcessInsert.add(oppProcessJose); 
            
            OpportunityProcess__c oppProcessJosimar = new OpportunityProcess__c();            
            oppProcessJosimar.Opportunity__c = opportunityJosimar.Id;  
            oppProcessJosimar.ExternalOpportunityId__c = opportunityJosimar.ExternalId__c;
            oppProcessJosimar.ExternalOpportunityTenant__c = opportunityJosimar.ExternalTenant__c;
            oppProcessJosimar.ExternalOpportunityVersion__c = opportunityJosimar.ExternalVersion__c;         
            listOppProcessInsert.add(oppProcessJosimar); 
        }

        insert listOppProcessInsert;

        for(OpportunityProcess__c varOppProcess : listOppProcessInsert)
        {
            listOppProcessUpdate.add(varOppProcess);
        }
        
        Test.startTest();
        update listOppProcessUpdate;
        Test.stopTest();
		
        Opportunity joaoUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountJoao.Id];
        Opportunity joseUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountJose.Id];
        Opportunity josimarUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountJosimar.Id];

        System.assertEquals(false, joaoUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
        System.assertEquals(false, joseUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
        System.assertEquals(false, josimarUpdate.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
    }   
}