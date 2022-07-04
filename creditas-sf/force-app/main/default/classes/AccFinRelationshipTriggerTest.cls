@isTest
private with sharing class AccFinRelationshipTriggerTest {
  @TestSetup
  static void makeData() {
    Account newAcc = TestSetup.getAccount('Conta', true);

    FinancialResources__c newRecFin = TestSetup.getNewFinRes(
      'Novo Recurso Financeiro',
      true
    );

    FinancialResources__c newRecFin2 = TestSetup.getNewFinRes(
      'Novo Recurso Financeiro2',
      true
    );
  }

  @isTest
  static void insertFinancialRelationship() {
    List<FinancialResources__c> recFinRes = [
      SELECT Id
      FROM FinancialResources__c
    ];

    Account accRes = [SELECT Id FROM Account];

    AccountFinancialRelationship__c newFinRel = new AccountFinancialRelationship__c();
    newFinRel.Account__c = accRes.Id;
    newFinRel.Recurso_Financeiro__c = recFinRes[0].Id;

    Test.startTest();
    insert newFinRel;
    Test.stopTest();

    List<AccountFinancialRelationship__c> res = [
      SELECT Id
      FROM AccountFinancialRelationship__c
    ];

    System.assertNotEquals(0, res.Size());
  }

  @isTest
  static void updateFinancialRelationship() {
    List<FinancialResources__c> recFinRes = [
      SELECT Id
      FROM FinancialResources__c
    ];

    Account accRes = [SELECT Id FROM Account];

    AccountFinancialRelationship__c newFinRel = new AccountFinancialRelationship__c();
    newFinRel.Account__c = accRes.Id;
    newFinRel.Recurso_Financeiro__c = recFinRes[0].Id;
    insert newFinRel;

    AccountFinancialRelationship__c resInserted = [
      SELECT Id, Recurso_Financeiro__c
      FROM AccountFinancialRelationship__c
    ];

    newFinRel.Recurso_Financeiro__c = recFinRes[1].Id;

    Test.startTest();
    update newFinRel;
    Test.stopTest();

    AccountFinancialRelationship__c resUpdated = [
      SELECT Id, Recurso_Financeiro__c
      FROM AccountFinancialRelationship__c
    ];

    System.assertNotEquals(resInserted, resUpdated);
  }
}

