/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe SynchOpportunityDataController
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          17/12/2021      Created     Classe de teste para SynchOpportunityDataController
**********************************************************************************************************************************/
@isTest
public class SynchOpportunityDataControllerTest {
    
    @TestSetup
    static void makeData()
    {

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        newAccount.DocumentNumber__c = '58131786277';
        newAccount.IsExternallySynched__c = true;
        newAccount.RecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        newAccount.IsSynchEnabled__c= '	ENABLED';
        insert(newAccount);
               
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId = newAccount.Id;
        newOpp.Name = 'New Opp Synch';
        newOpp.IsExternallySynched__c = true;
        newOpp.IsSynchEnabled__c= '	ENABLED';
        newOpp.StageName = 'Novo';
        newOpp.CloseDate = Date.today().addDays(10);
        
        insert(newOpp);
    }

    @isTest
   	static void getOppData() 
    {
      	             
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        Test.startTest();
        Opportunity res = SynchOpportunityDataController.getSyncInfo(opp.Id);
        Test.stopTest();
                
       	System.assertNotEquals(Null, res);
    }
    
    @isTest
    static void updateOpp() 
    {
        Opportunity opp = [SELECT Id, IsSynchEnabled__c, IsExternallySynched__c FROM Opportunity];
       
        Test.startTest();
        SynchOpportunityDataController.updateSynchingFields(opp);
        Test.stopTest();
    
        Opportunity oppUpdated = [SELECT Id, IsSynchEnabled__c, IsExternallySynched__c FROM Opportunity];
        System.assertNotEquals(opp, oppUpdated);
    }
}