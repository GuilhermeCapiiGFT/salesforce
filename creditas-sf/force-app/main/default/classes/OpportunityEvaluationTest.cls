@isTest
public class OpportunityEvaluationTest {
  @TestSetup
  static void makeData() {
    Id recordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', 'AtWork');

    CustomSetup__c cSetup = new CustomSetup__c(
      RecordTypeId = recordTypeId,
      Name = 'Test',
      DateFilter__c = 'CreatedDate'
    );

    insert cSetup;

    insert new List<CustomQueue__c>{
      new CustomQueue__c(
        Name = 'DISCHARGING',
        ProductType__c = 'DISCHARGING',
        CustomSetup__c = cSetup.Id,
        Points__c = 10
      ),
      new CustomQueue__c(
        Name = 'REFINANCING',
        ProductType__c = 'REFINANCING',
        CustomSetup__c = cSetup.Id,
        Points__c = 20
      ),
      new CustomQueue__c(Name = 'STORE', ProductType__c = 'STORE', CustomSetup__c = cSetup.Id, Points__c = 30),
      new CustomQueue__c(
        Name = 'PAYROLL_LOAN',
        ProductType__c = 'PAYROLL_LOAN',
        CustomSetup__c = cSetup.Id,
        Points__c = 40
      ),
      new CustomQueue__c(
        Name = 'SALARY_ADVANCE',
        ProductType__c = 'SALARY_ADVANCE',
        CustomSetup__c = cSetup.Id,
        Points__c = 50
      ),
      new CustomQueue__c(
        Name = 'PENDENCY_RETURN',
        ProductType__c = 'PENDENCY_RETURN',
        CustomSetup__c = cSetup.Id,
        Points__c = 100
      )
    };

    Account account = AccountSetup.createAccount('Test', 'Pessoa_Fisica');

    insert account;
  }

  @isTest
  public static void testEvaluateByOpportunity() {
    Id accountId = [SELECT Id FROM Account].Id;

    // Insert opportunities and validate Opportunity.PriorityPoints__c
    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity1.ProductType__c = 'DISCHARGING';
    opportunity1.StageName = 'Novo';

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity2.ProductType__c = 'REFINANCING';
    opportunity2.StageName = 'Novo';

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity3.ProductType__c = 'STORE';
    opportunity3.StageName = 'Novo';

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity4.ProductType__c = 'PAYROLL_LOAN';
    opportunity4.StageName = 'Novo';

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity5.ProductType__c = 'SALARY_ADVANCE';
    opportunity5.StageName = 'Novo';

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity6.ProductType__c = 'SALARY_ADVANCE';
    opportunity6.StageName = 'Retorno de Pendência de Formalização';

    List<Opportunity> newOpportunities = new List<Opportunity>{
      opportunity1,
      opportunity2,
      opportunity3,
      opportunity4,
      opportunity5,
      opportunity6
    };

    Test.startTest();

    insert newOpportunities;

    Test.stopTest();

    List<Opportunity> opportunities = [SELECT ProductType__c, PriorityPoints__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      switch on opportunity.ProductType__c {
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
      }
    }
  }

  @isTest
  private static void testEvaluateByOpportunityBulk() {
    Id accountId = [SELECT Id FROM Account].Id;
    List<Opportunity> opportunities = new List<Opportunity>();

    // create 200 opportunities
    do {
      Opportunity opportunity = OpportunitySetup.createOpportunity(accountId, 'AtWork');
      opportunity.ProductType__c = 'DISCHARGING';
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

    // Insert opportunities
    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity1.ProductType__c = 'DISCHARGING';
    opportunity1.StageName = 'Novo';

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity2.ProductType__c = 'REFINANCING';
    opportunity2.StageName = 'Contrato Assinado';

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity3.ProductType__c = 'STORE';
    opportunity3.StageName = 'Aprovado por RH';

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity4.ProductType__c = 'PAYROLL_LOAN';
    opportunity4.StageName = 'Novo';

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity5.ProductType__c = 'SALARY_ADVANCE';
    opportunity5.StageName = 'Novo';

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity6.ProductType__c = 'SALARY_ADVANCE';
    opportunity6.StageName = 'Retorno de Pendência de Formalização';

    List<Opportunity> newOpportunities = new List<Opportunity>{
      opportunity1,
      opportunity2,
      opportunity3,
      opportunity4,
      opportunity5,
      opportunity6
    };

    insert newOpportunities;

    List<CustomQueue__c> customQueues = [SELECT Points__c FROM CustomQueue__c];

    for (CustomQueue__c cQueue : customQueues) {
      cQueue.Points__c += 100;
    }

    Test.startTest();

    update customQueues;

    Test.stopTest();

    List<Opportunity> opportunities = [SELECT ProductType__c, PriorityPoints__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      switch on opportunity.ProductType__c {
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
      }
    }
  }

  @IsTest
  private static void testEvaluateOnUpdate() {
    Id accountId = [SELECT Id FROM Account].Id;

    Opportunity opportunity1 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity1.ProductType__c = 'DISCHARGING';
    opportunity1.StageName = 'Novo';

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity2.ProductType__c = 'REFINANCING';
    opportunity2.StageName = 'Novo';

    List<Opportunity> opportunities = new List<Opportunity>{ opportunity1, opportunity2 };

    insert opportunities;

    opportunities = [SELECT ProductType__c, StageName FROM Opportunity];
    for (Opportunity opportunity : opportunities) {
      opportunity.StageName = opportunity.ProductType__c == 'DISCHARGING'
        ? 'Retorno de Pendência de Formalização'
        : 'Pendenciado para Consultoria';
    }

    Test.startTest();

    update opportunities;

    Test.stopTest();

    opportunities = [SELECT ProductType__c, PriorityPoints__c, StageName FROM Opportunity];

    for (Opportunity opportunity : opportunities) {
      Double points = opportunity.PriorityPoints__c;

      switch on opportunity.ProductType__c {
        when 'DISCHARGING' {
          System.assertEquals(110, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
        when 'REFINANCING' {
          System.assertEquals(20, points, 'Incorrect Opportunity.PriorityPoints__c value');
        }
      }
    }
  }
}