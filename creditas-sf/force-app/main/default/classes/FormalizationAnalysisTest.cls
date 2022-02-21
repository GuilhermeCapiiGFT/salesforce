/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * Purpose: Classe de teste para a classe FormalizationAnalysisController
 * =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       09/02/2022      Created     Classe de teste para classe FormalizationAnalysisController
 **********************************************************************************************************************/
@isTest
public class FormalizationAnalysisTest {
  @TestSetup
  static void makeData() {
    Account newAccount = new Account(
      Name = 'Test Account',
      FirstName__c = 'Firstname',
      Mother__c = 'Mother',
      BirthDate__c = Date.newInstance(2000, 5, 20)
    );

    Opportunity newOppty = new Opportunity(
      Name = 'Test Oppty',
      StageName = 'Assinatura',
      CloseDate = Date.today().addDays(10)
    );

    TriggerHandler.bypass('AccountTriggerHandler');
    TriggerHandler.bypass('OpportunityTriggerHandler');

    insert newAccount;

    newOppty.AccountId = newAccount.Id;

    insert newOppty;

    TriggerHandler.clearAllBypasses();
  }

  @isTest
  public static void testGetInformationSuccess() {
    Test.startTest();

    Id opptyId = [SELECT Id FROM Opportunity WHERE Name = 'Test Oppty' LIMIT 1].Id;
    Account createdAccount = formalizationAnalysisController.getInformation(opptyId);

    Test.stopTest();

    System.assert(
      createdAccount != null,
      'No account was returned as a result of calling FormalizationAnalysisController.getInformation method'
    );

    System.assertEquals(createdAccount.FirstName__c, 'Firstname', 'Account FirstName__c is incorrect');
    System.assertEquals(createdAccount.Mother__c, 'Mother', 'Account Mother__c is incorrect');
    System.assertEquals(
      createdAccount.BirthDate__c,
      Date.newInstance(2000, 5, 20),
      'Account BirthDate__c is incorrect'
    );
  }

  @isTest
  public static void testGetInformationFailure() {
    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

    try {
      Test.startTest();
      Account createdAccount = formalizationAnalysisController.getInformation(accountId);
      Test.stopTest();

      System.assert(createdAccount == null, 'No account should\'ve been returned.');
    } catch (Exception e) {
      System.assert(
        e.getTypeName() == 'System.AuraHandledException',
        'Wrong exception type, expected System.AuraHandledException'
      );
    }
  }
}