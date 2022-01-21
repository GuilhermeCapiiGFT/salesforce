/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe SynchAccountDataController
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/10/2021      Created     Classe de teste para SynchAccountDataController
**********************************************************************************************************************************/
@isTest
public class SynchAccountDataControllerTest {
    
    @TestSetup
    static void makeData()
    {
        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        newAccount.DocumentNumber__c = '58131786277';
        newAccount.IsExternallySynched__c = true;
        newAccount.RecordTypeId = '01203000000CpjkAAC';
        newAccount.IsSynchEnabled__c= '	ENABLED';
        insert(newAccount);
    }
    
    @isTest
   	static void getAccount() 
    {
      //List<Id> listId = new  List<Id>();
              
        Account accId = [SELECT Id FROM Account];
        
        Test.startTest();
        Account res = SynchAccountDataController.getAccountData(accId.Id);
        Test.stopTest();
                
       	System.assertNotEquals(Null, res);
    }
    
    @isTest
    static void updateAccount() 
    {
        Account acc = [SELECT Id, IsSynchEnabled__c FROM Account];
       
        Test.startTest();
        SynchAccountDataController.checkSynchingField(acc);
        Test.stopTest();
    
        Account accUpdated = [SELECT Id, IsSynchEnabled__c FROM Account];
        System.assertNotEquals(acc, accUpdated);
    }
}