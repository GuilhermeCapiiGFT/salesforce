/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe de testes da classe EvaluationMethods
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       18/01/2021      Created     Classe de testes da classe EvaluationMethods
 **********************************************************************************************************************/
@isTest
private class EvaluationMethodsTest {
  static Id accountId;

  static List<Opportunity> makeOpportunityList(Integer numOpps, Id accountId, String productType) {
    List<Opportunity> lstOpp = new List<Opportunity>();

    for (Integer i = 1; i <= numOpps; i++) {
      Opportunity opp = OpportunitySetup.createOpportunity(accountId, 'AtWork');
      opp.Name = 'Opportunity Test ' + i;
      opp.ProductType__c = productType;
      lstOpp.add(opp);
    }

    return lstOpp;
  }

  static CustomSetup__c makeCustomSetup(String name, String dateFilter) {
    CustomSetup__c cSetup = new CustomSetup__c();
    cSetup.Name = name;
    cSetup.DateFilter__c = dateFilter;
    return cSetup;
  }

  static CustomQueue__c makeCustomQueue(Id cSetupId, String name, String productType, Double points) {
    CustomQueue__c cQueue = new CustomQueue__c();
    cQueue.Name = name;
    cQueue.ProductType__c = productType;
    cQueue.CustomSetup__c = cSetupId;
    cQueue.Points__c = points;

    return cQueue;
  }

  @TestSetup
  static void runSetup() {
    CustomSetup__c cSetup = makeCustomSetup('Parametrização de Filas e Usuários', 'Data de Solicitação');

    insert cSetup;

    List<CustomQueue__c> lstCustomQueue = new List<CustomQueue__c>();
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Quitação', 'DISCHARGE', 10));
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Refinanciamento', 'REFINANCING', 20));
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Store', 'STORE', 30));
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Payroll', 'PAYROLL_LOAN', 40));
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Antecipação', 'SALARY_ADVANCE', 50));
    lstCustomQueue.add(makeCustomQueue(cSetup.Id, 'Retorno de Pendência', 'PENDENCY_RETURN', 100));

    insert lstCustomQueue;

    Account acc = AccountSetup.createAccount('Account Test', 'Pessoa_Fisica');

    insert acc;

    accountId = acc.Id;
  }

  @isTest
  static void runInsertAtWorkOpportunity() {
    List<Opportunity> lstOpp = makeOpportunityList(1, accountId, 'PAYROLL_LOAN');
    lstOpp.addAll(makeOpportunityList(1, accountId, ''));

    Test.startTest();

    insert lstOpp;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c FROM Opportunity WHERE Id IN :lstOpp]) {
      if (opp.ProductType__c == 'PAYROLL_LOAN') {
        System.assertEquals(40, opp.PriorityPoints__c, 'Opportunity priority points should be 40');
      } else {
        System.assertEquals(0, opp.PriorityPoints__c, 'Opportunity priority points should be 0');
      }
    }
  }

  @isTest
  static void runBulkInsertAtWorkOpportunity() {
    Map<String, Double> mapQueuePoints = new Map<String, Double>();
    for (CustomQueue__c cQueue : [SELECT Id, ProductType__c, Points__c FROM CustomQueue__c]) {
      mapQueuePoints.put(cQueue.ProductType__c, cQueue.Points__c);
    }

    List<Opportunity> lstOpp = makeOpportunityList(40, accountId, 'DISCHARGE');
    lstOpp.addAll(makeOpportunityList(40, accountId, 'REFINANCING'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'STORE'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'PAYROLL_LOAN'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'SALARY_ADVANCE'));

    Test.startTest();

    insert lstOpp;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c FROM Opportunity WHERE Id IN :lstOpp]) {
      System.assertEquals(
        mapQueuePoints.get(opp.ProductType__c),
        opp.PriorityPoints__c,
        'Opportunity priority points should be ' + mapQueuePoints.get(opp.ProductType__c)
      );
    }
  }

  @isTest
  static void runUpdateOneCustomQueue() {
    List<Opportunity> lstOpp = makeOpportunityList(1, accountId, 'DISCHARGE');
    lstOpp.addAll(makeOpportunityList(1, accountId, 'REFINANCING'));
    lstOpp.addAll(makeOpportunityList(1, accountId, 'STORE'));
    lstOpp.addAll(makeOpportunityList(1, accountId, ''));

    insert lstOpp;

    CustomQueue__c cQueue = [SELECT Id, ProductType__c FROM CustomQueue__c WHERE ProductType__c = 'DISCHARGE' LIMIT 1];
    cQueue.Points__c = 22;

    Test.startTest();

    update cQueue;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c FROM Opportunity WHERE Id IN :lstOpp]) {
      if (opp.ProductType__c == 'DISCHARGE') {
        System.assertEquals(22, opp.PriorityPoints__c, 'Opportunity priority points should be 22');
      } else if (opp.ProductType__c == 'REFINANCING' || opp.ProductType__c == 'STORE') {
        System.assertNotEquals(22, opp.PriorityPoints__c, 'Opportunity priority points should not be 22');
      } else {
        System.assertEquals(0, opp.PriorityPoints__c, 'Opportunity priority points should be 0');
      }
    }
  }

  @isTest
  static void runUpdateMultipleCustomQueue() {
    List<Opportunity> lstOpp = makeOpportunityList(40, accountId, 'DISCHARGE');
    lstOpp.addAll(makeOpportunityList(40, accountId, 'REFINANCING'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'STORE'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'PAYROLL_LOAN'));
    lstOpp.addAll(makeOpportunityList(40, accountId, ''));

    insert lstOpp;

    List<CustomQueue__c> lstCustomQueue = [
      SELECT Id, ProductType__c
      FROM CustomQueue__c
      WHERE ProductType__c IN ('DISCHARGE', 'REFINANCING', 'STORE', 'PAYROLL_LOAN')
    ];

    for (CustomQueue__c cQueue : lstCustomQueue) {
      if (cQueue.ProductType__c == 'DISCHARGE') {
        cQueue.Points__c = 11;
      } else if (cQueue.ProductType__c == 'REFINANCING') {
        cQueue.Points__c = 21;
      } else if (cQueue.ProductType__c == 'STORE') {
        cQueue.Points__c = 31;
      } else if (cQueue.ProductType__c == 'PAYROLL_LOAN') {
        cQueue.Points__c = 41;
      }
    }

    Test.startTest();

    update lstCustomQueue;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c FROM Opportunity WHERE Id IN :lstOpp]) {
      if (opp.ProductType__c == 'DISCHARGE') {
        System.assertEquals(
          11,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'DISCHARGE\' should have 11 Priority Points'
        );
      } else if (opp.ProductType__c == 'REFINANCING') {
        System.assertEquals(
          21,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'REFINANCING\' should have 21 Priority Points'
        );
      } else if (opp.ProductType__c == 'STORE') {
        System.assertEquals(
          31,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'STORE\' should have 31 Priority Points'
        );
      } else if (opp.ProductType__c == 'PAYROLL_LOAN') {
        System.assertEquals(
          41,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'PAYROLL_LOAN\' should have 41 Priority Points'
        );
      } else {
        System.assertEquals(
          0,
          opp.PriorityPoints__c,
          'Opportunities with no Product Type should have 0 Priority Points'
        );
      }
    }
  }

  @isTest
  private static void testPendencyReturnOpps(){
    List<Opportunity> lstOpp = makeOpportunityList(40, accountId, 'DISCHARGE');
    lstOpp.addAll(makeOpportunityList(40, accountId, 'REFINANCING'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'STORE'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'PAYROLL_LOAN'));
    lstOpp.addAll(makeOpportunityList(40, accountId, 'SALARY_ADVANCE'));
    for(Opportunity iOpp : lstOpp){
      iOpp.PendencyReturn__c = true;
    }

    insert lstOpp;

    List<CustomQueue__c> lstCustomQueue = [
      SELECT Id, ProductType__c
      FROM CustomQueue__c
      WHERE ProductType__c IN ('DISCHARGE', 'REFINANCING', 'STORE', 'PAYROLL_LOAN')
    ];

    for (CustomQueue__c cQueue : lstCustomQueue) {
      if (cQueue.ProductType__c == 'DISCHARGE') {
        cQueue.Points__c = 11;
      } else if (cQueue.ProductType__c == 'REFINANCING') {
        cQueue.Points__c = 21;
      } else if (cQueue.ProductType__c == 'STORE') {
        cQueue.Points__c = 31;
      } else if (cQueue.ProductType__c == 'PAYROLL_LOAN') {
        cQueue.Points__c = 41;
      }
    }

    Test.startTest();

    update lstCustomQueue;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c FROM Opportunity WHERE Id IN :lstOpp]) {
      if (opp.ProductType__c == 'DISCHARGE') {
        System.assertEquals(
          111,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'DISCHARGE\' should have 111 Priority Points'
        );
      } else if (opp.ProductType__c == 'REFINANCING') {
        System.assertEquals(
          121,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'REFINANCING\' should have 121 Priority Points'
        );
      } else if (opp.ProductType__c == 'STORE') {
        System.assertEquals(
          131,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'STORE\' should have 131 Priority Points'
        );
      } else if (opp.ProductType__c == 'PAYROLL_LOAN') {
        System.assertEquals(
          141,
          opp.PriorityPoints__c,
          'Opportunities with Product Type \'PAYROLL_LOAN\' should have 41 Priority Points'
        );
      } else {
        System.assertEquals(
          150,
          opp.PriorityPoints__c,
          'Opportunities with no Product Type SALARY_ADVANCE should have 150 Priority Points'
        );
      }
    }
  }

  @isTest
  static void testUpdatePendencyCustomQueue() {
    List<Opportunity> lstOpp = makeOpportunityList(1, accountId, 'DISCHARGE');
    lstOpp[0].PendencyReturn__c = true;
    lstOpp.addAll(makeOpportunityList(1, accountId, 'REFINANCING'));
    lstOpp.addAll(makeOpportunityList(1, accountId, 'STORE'));
    lstOpp.addAll(makeOpportunityList(1, accountId, ''));

    insert lstOpp;

    CustomQueue__c cQueue = [SELECT Id, ProductType__c FROM CustomQueue__c WHERE ProductType__c = 'PENDENCY_RETURN' LIMIT 1];
    cQueue.Points__c = 150;

    Test.startTest();

    update cQueue;

    Test.stopTest();

    for (Opportunity opp : [SELECT ProductType__c, PriorityPoints__c, PendencyReturn__c FROM Opportunity WHERE Id IN :lstOpp]) {
      if (opp.PendencyReturn__c) {
        System.assertEquals(160, opp.PriorityPoints__c, 'Opportunity priority points should be 160');
      } else if (opp.ProductType__c == 'REFINANCING' || opp.ProductType__c == 'STORE') {
        System.assertNotEquals(22, opp.PriorityPoints__c, 'Opportunity priority points should not be 22');
      } else {
        System.assertEquals(0, opp.PriorityPoints__c, 'Opportunity priority points should be 0');
      }
    }
  }
}