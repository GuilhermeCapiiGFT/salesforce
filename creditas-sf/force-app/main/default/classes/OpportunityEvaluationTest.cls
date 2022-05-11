@isTest
public class OpportunityEvaluationTest {
  private static final String RECORDTYPENAME_ATWORK = 'AtWork';
  private static final String RECORDTYPENAME_AUTOFIN = 'AutoFin';
  private static final String RECORDTYPENAME_HOME = 'Home';

  private static final String STAGENAME_NEW = 'Novo';
  private static final String STAGENAME_APPROVED_BY_HR = 'Aprovado por RH';
  private static final String STAGENAME_WAITING = 'Aguardando Distribuição de Formalização';
  private static final String STAGENAME_PENDENCY_RETURN = 'Retorno de Pendência de Formalização';
  private static final String STAGENAME_SENT_COMMITTEE = 'Aguardando Distribuição para Comitê de Formalização';

  private static final String QUEUENAME_DISCHARGING = 'DISCHARGING';
  private static final String QUEUENAME_REFINANCING = 'REFINANCING';
  private static final String QUEUENAME_STORE = 'STORE';
  private static final String QUEUENAME_PAYROLL_LOAN = 'PAYROLL_LOAN';
  private static final String QUEUENAME_SALARY_ADVANCE = 'SALARY_ADVANCE';
  private static final String QUEUENAME_PENDENCY_RETURN = 'PENDENCY_RETURN';
  private static final String QUEUENAME_AUTO_FIN = 'AUTO_FIN';
  private static final String QUEUENAME_PRIORITY_REVENUE = 'PRIORITY_REVENUE';
  private static final String QUEUENAME_COMMITTEE = 'COMMITTEE';

  @TestSetup
  static void makeData() {
    Id setupRecordTypeIdAtWork = Util.getRecordTypeIdbyName('CustomSetup__c', RECORDTYPENAME_ATWORK);
    Id setupRecordTypeIdAutoFin = Util.getRecordTypeIdbyName('CustomSetup__c', RECORDTYPENAME_AUTOFIN);

    insert new List<CustomSetup__c>{
      new CustomSetup__c(
        RecordTypeId = setupRecordTypeIdAtWork,
        Name = RECORDTYPENAME_ATWORK,
        DateFilter__c = 'CreatedDate'
      ),
      new CustomSetup__c(
        RecordTypeId = setupRecordTypeIdAutoFin,
        Name = RECORDTYPENAME_AUTOFIN,
        DateFilter__c = 'CreatedDate'
      )
    };

    Id setupIdAtWork;
    Id setupIdAutoFin;
    for (CustomSetup__c setup : [SELECT Id, Name FROM CustomSetup__c]) {
      if (setup.Name == RECORDTYPENAME_ATWORK) {
        setupIdAtWork = setup.Id;
      } else if (setup.Name == RECORDTYPENAME_AUTOFIN) {
        setupIdAutoFin = setup.Id;
      }
    }

    Id queueRecordTypeIdAtWork = Util.getRecordTypeIdbyName('CustomQueue__c', RECORDTYPENAME_ATWORK);
    Id queueRecordTypeIdAutoFin = Util.getRecordTypeIdbyName('CustomQueue__c', RECORDTYPENAME_AUTOFIN);

    insert new List<CustomQueue__c>{
      new CustomQueue__c(
        Name = QUEUENAME_DISCHARGING,
        QueueName__c = QUEUENAME_DISCHARGING,
        CustomSetup__c = setupIdAtWork,
        Points__c = 10,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_REFINANCING,
        QueueName__c = QUEUENAME_REFINANCING,
        CustomSetup__c = setupIdAtWork,
        Points__c = 20,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_STORE,
        QueueName__c = QUEUENAME_STORE,
        CustomSetup__c = setupIdAtWork,
        Points__c = 30,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_PAYROLL_LOAN,
        QueueName__c = QUEUENAME_PAYROLL_LOAN,
        CustomSetup__c = setupIdAtWork,
        Points__c = 40,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_SALARY_ADVANCE,
        QueueName__c = QUEUENAME_SALARY_ADVANCE,
        CustomSetup__c = setupIdAtWork,
        Points__c = 50,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_PENDENCY_RETURN,
        QueueName__c = QUEUENAME_PENDENCY_RETURN,
        CustomSetup__c = setupIdAtWork,
        Points__c = 100,
        RecordTypeId = queueRecordTypeIdAtWork
      ),
      new CustomQueue__c(
        Name = QUEUENAME_AUTO_FIN,
        QueueName__c = QUEUENAME_AUTO_FIN,
        CustomSetup__c = setupIdAutoFin,
        Points__c = 10,
        RecordTypeId = queueRecordTypeIdAutoFin
      ),
      new CustomQueue__c(
        Name = QUEUENAME_PRIORITY_REVENUE,
        QueueName__c = QUEUENAME_PRIORITY_REVENUE,
        CustomSetup__c = setupIdAutoFin,
        Points__c = 20,
        RecordTypeId = queueRecordTypeIdAutoFin
      ),
      new CustomQueue__c(
        Name = QUEUENAME_PENDENCY_RETURN,
        QueueName__c = QUEUENAME_PENDENCY_RETURN,
        CustomSetup__c = setupIdAutoFin,
        Points__c = 100,
        RecordTypeId = queueRecordTypeIdAutoFin
      ),
      new CustomQueue__c(
        Name = QUEUENAME_COMMITTEE,
        QueueName__c = QUEUENAME_COMMITTEE,
        CustomSetup__c = setupIdAutoFin,
        Points__c = 200,
        RecordTypeId = queueRecordTypeIdAutoFin
      )
    };

    Account account = AccountSetup.createAccount('Test', 'Pessoa_Fisica');

    insert account;
  }

  @isTest
  public static void testEvaluateByOpportunity() {
    Id accountId = [SELECT Id FROM Account].Id;

    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity1.QueueName__c = QUEUENAME_DISCHARGING;
    opportunity1.StageName = STAGENAME_NEW;

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity2.QueueName__c = QUEUENAME_REFINANCING;
    opportunity2.StageName = STAGENAME_APPROVED_BY_HR;

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity3.QueueName__c = QUEUENAME_STORE;
    opportunity3.StageName = STAGENAME_NEW;

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity4.QueueName__c = QUEUENAME_PAYROLL_LOAN;
    opportunity4.StageName = STAGENAME_NEW;

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity5.QueueName__c = QUEUENAME_SALARY_ADVANCE;
    opportunity5.StageName = STAGENAME_NEW;

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity6.QueueName__c = QUEUENAME_SALARY_ADVANCE;
    opportunity6.StageName = STAGENAME_PENDENCY_RETURN;

    Opportunity opportunity7 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity7.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity7.StageName = STAGENAME_NEW;

    Opportunity opportunity8 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity8.QueueName__c = QUEUENAME_PRIORITY_REVENUE;
    opportunity8.StageName = STAGENAME_NEW;

    Opportunity opportunity9 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity9.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity9.StageName = STAGENAME_PENDENCY_RETURN;

    Opportunity opportunity10 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity10.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity10.StageName = STAGENAME_SENT_COMMITTEE;

    Opportunity opportunity11 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_HOME);
    opportunity11.StageName = 'Emissão é Pré-Assinatura';

    List<Opportunity> newOpportunities = new List<Opportunity>{
      opportunity1,
      opportunity2,
      opportunity3,
      opportunity4,
      opportunity5,
      opportunity6,
      opportunity7,
      opportunity8,
      opportunity9,
      opportunity10,
      opportunity11
    };

    Test.startTest();

    insert newOpportunities;

    Test.stopTest();

    List<Opportunity> opportunities = [SELECT QueueName__c, PriorityPoints__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      switch on opportunity.QueueName__c {
        when 'DISCHARGING' {
          System.assertEquals(10, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'REFINANCING' {
          System.assertEquals(20, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'STORE' {
          System.assertEquals(30, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'PAYROLL_LOAN' {
          System.assertEquals(40, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'SALARY_ADVANCE' {
          Double expected = opportunity.StageName == 'Novo' ? 50 : 150;
          System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'PRIORITY_REVENUE' {
          System.assertEquals(20, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'AUTO_FIN' {
          Double expected;
          if (opportunity.StageName == STAGENAME_NEW) {
            expected = 10;
          } else if (opportunity.StageName == STAGENAME_PENDENCY_RETURN) {
            expected = 110;
          } else if (opportunity.StageName == STAGENAME_SENT_COMMITTEE) {
            expected = 210;
          }
          System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when else {
          System.assertEquals(null, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
      }
    }
  }

  @isTest
  private static void testEvaluateByOpportunityBulk() {
    Id accountId = [SELECT Id FROM Account].Id;
    List<Opportunity> opportunities = new List<Opportunity>();

    do {
      Opportunity opportunity = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
      opportunity.QueueName__c = QUEUENAME_DISCHARGING;
      opportunity.StageName = STAGENAME_NEW;
      opportunities.add(opportunity);
    } while (opportunities.size() <= 200);

    Test.startTest();

    insert opportunities;

    Test.stopTest();

    opportunities = [SELECT PriorityPoints__c FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      System.assertEquals(10, opportunity.PriorityPoints__c, 'Incorrect Opportunity.PriorityPoints__c value');
    }
  }

  @isTest
  public static void testEvaluateByCustomQueue() {
    Id accountId = [SELECT Id FROM Account].Id;

    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity1.QueueName__c = QUEUENAME_DISCHARGING;
    opportunity1.StageName = STAGENAME_NEW;

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity2.QueueName__c = QUEUENAME_REFINANCING;
    opportunity2.StageName = STAGENAME_APPROVED_BY_HR;

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity3.QueueName__c = QUEUENAME_STORE;
    opportunity3.StageName = STAGENAME_NEW;

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity4.QueueName__c = QUEUENAME_PAYROLL_LOAN;
    opportunity4.StageName = STAGENAME_NEW;

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity5.QueueName__c = QUEUENAME_SALARY_ADVANCE;
    opportunity5.StageName = STAGENAME_NEW;

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity6.QueueName__c = QUEUENAME_SALARY_ADVANCE;
    opportunity6.StageName = STAGENAME_PENDENCY_RETURN;

    Opportunity opportunity7 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity7.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity7.StageName = STAGENAME_NEW;

    Opportunity opportunity8 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity8.QueueName__c = QUEUENAME_PRIORITY_REVENUE;
    opportunity8.StageName = STAGENAME_NEW;

    Opportunity opportunity9 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity9.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity9.StageName = STAGENAME_PENDENCY_RETURN;

    Opportunity opportunity10 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity10.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity10.StageName = STAGENAME_SENT_COMMITTEE;

    List<Opportunity> newOpportunities = new List<Opportunity>{
      opportunity1,
      opportunity2,
      opportunity3,
      opportunity4,
      opportunity5,
      opportunity6,
      opportunity7,
      opportunity8,
      opportunity9,
      opportunity10
    };

    insert newOpportunities;

    List<CustomQueue__c> customQueues = [SELECT Points__c FROM CustomQueue__c];

    for (CustomQueue__c cQueue : customQueues) {
      cQueue.Points__c += 100;
    }

    Test.startTest();

    update customQueues;

    Test.stopTest();

    List<Opportunity> opportunities = [SELECT QueueName__c, PriorityPoints__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      switch on opportunity.QueueName__c {
        when 'DISCHARGING' {
          System.assertEquals(110, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'REFINANCING' {
          System.assertEquals(120, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'STORE' {
          System.assertEquals(130, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'PAYROLL_LOAN' {
          System.assertEquals(140, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'SALARY_ADVANCE' {
          Double expected = opportunity.StageName == 'Novo' ? 150 : 350;
          System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'PRIORITY_REVENUE' {
          System.assertEquals(120, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'AUTO_FIN' {
          Double expected;
          if (opportunity.StageName == STAGENAME_NEW) {
            expected = 110;
          } else if (opportunity.StageName == STAGENAME_PENDENCY_RETURN) {
            expected = 310;
          } else if (opportunity.StageName == STAGENAME_SENT_COMMITTEE) {
            expected = 410;
          }
          System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
      }
    }
  }

  @IsTest
  private static void testEvaluateOnUpdate() {
    Id accountId = [SELECT Id FROM Account].Id;

    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity1.Name = 'test-1';
    opportunity1.QueueName__c = QUEUENAME_DISCHARGING;
    opportunity1.StageName = STAGENAME_NEW;

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_ATWORK);
    opportunity2.Name = 'test-2';
    opportunity2.QueueName__c = QUEUENAME_DISCHARGING;
    opportunity2.StageName = STAGENAME_NEW;

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity3.Name = 'test-3';
    opportunity3.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity3.StageName = STAGENAME_NEW;

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity4.Name = 'test-4';
    opportunity4.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity4.StageName = STAGENAME_NEW;

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_AUTOFIN);
    opportunity5.Name = 'test-5';
    opportunity5.QueueName__c = QUEUENAME_AUTO_FIN;
    opportunity5.StageName = STAGENAME_NEW;

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, RECORDTYPENAME_HOME);
    opportunity6.Name = 'test-6';
    opportunity6.StageName = 'Emissão é Pré-Assinatura';    

    List<Opportunity> newOpportunities = new List<Opportunity>{
      opportunity1,
      opportunity2,
      opportunity3,
      opportunity4,
      opportunity5,
      opportunity6
    };

    insert newOpportunities;

    List<Opportunity> opportunities = [SELECT Name, QueueName__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      if (opportunity.Name == 'test-1') {
        opportunity.StageName = STAGENAME_APPROVED_BY_HR;
      } else if (opportunity.Name == 'test-2') {
        opportunity.StageName = STAGENAME_PENDENCY_RETURN;
      } else if (opportunity.Name == 'test-3') {
        opportunity.StageName = STAGENAME_WAITING;
      } else if (opportunity.Name == 'test-4') {
        opportunity.StageName = STAGENAME_PENDENCY_RETURN;
      } else if (opportunity.Name == 'test-5') {
        opportunity.StageName = STAGENAME_SENT_COMMITTEE;
      } else if (opportunity.Name == 'test-6') {
        opportunity.StageName = 'Assinatura';
      }
    }

    Test.startTest();

    update opportunities;

    Test.stopTest();

    opportunities = [SELECT Name, QueueName__c, StageName, PriorityPoints__c FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      if (opportunity.Name == 'test-1') {
        System.assertEquals(10, points, 'Opportunity \'test-1\' points are incorrect');
      } else if (opportunity.Name == 'test-2') {
        System.assertEquals(110, points, 'Opportunity \'test-2\' points are incorrect');
      } else if (opportunity.Name == 'test-3') {
        System.assertEquals(10, points, 'Opportunity \'test-3\' points are incorrect');
      } else if (opportunity.Name == 'test-4') {
        System.assertEquals(110, points, 'Opportunity \'test-4\' points are incorrect');
      } else if (opportunity.Name == 'test-5') {
        System.assertEquals(210, points, 'Opportunity \'test-5\' points are incorrect');
      } else if (opportunity.Name == 'test-6') {
        System.assertEquals(null, points, 'Opportunity \'test-6\' points are incorrect');
      }
    }
  }
}