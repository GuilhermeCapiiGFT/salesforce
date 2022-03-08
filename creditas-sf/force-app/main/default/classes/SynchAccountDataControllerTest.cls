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
        newAccount.RecordTypeId = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        newAccount.IsSynchEnabled__c= '	ENABLED';
        insert(newAccount);
    }
    
    @isTest
   	static void getAccountSucess() 
    {             
        Account accId = [SELECT Id FROM Account];
        
        Test.startTest();
        Account responseAccount = SynchAccountDataController.getAccountData(accId.Id);
        Test.stopTest();
                
       	System.assertEquals(accId.Id, responseAccount.Id,'Same account should have returned');
    }

    @isTest
   	static void getAccountInvalidId() 
    {             
               
        Test.startTest();
        try{
            Account responseAccount = SynchAccountDataController.getAccountData('invalidId');
        }
        catch(Exception e){
            System.assertEquals(null, SynchAccountDataController.getAccountData('invalidId'),'null should have been returned');
        }
        Test.stopTest();
                
    }
    
    @isTest
    static void updateAccount() 
    {
        Account acc = [SELECT Id, IsSynchEnabled__c FROM Account];
        String beforeUpdate = acc.IsSynchEnabled__c;
       
        Test.startTest();
        SynchAccountDataController.checkSynchingField(acc);
        Test.stopTest();
    
        Account accUpdated = [SELECT Id, IsSynchEnabled__c FROM Account];
        System.assertNotEquals(beforeUpdate, accUpdated.IsSynchEnabled__c, 'Field IsSynchEnabled__c should have changed');
    }
}