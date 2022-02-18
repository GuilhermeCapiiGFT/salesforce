/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Test class for OpportunityEvaluationController
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       15/02/2021      Created     Class creation
 **********************************************************************************************************************/
@isTest
public class OpportunityEvaluationTest {
  @TestSetup
  static void makeData() {

    Id recordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', 'AtWork');

    CustomSetup__c cSetup = new CustomSetup__c(RecordTypeId=recordTypeId, Name = 'Test', DateFilter__c = 'CreatedDate');

    insert cSetup;

    insert new List<CustomQueue__c>{
      new CustomQueue__c(Name = 'DISCHARGE', ProductType__c = 'DISCHARGE', CustomSetup__c = cSetup.Id, Points__c = 10),
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
    opportunity1.ProductType__c = 'DISCHARGE';

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity2.ProductType__c = 'REFINANCING';

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity3.ProductType__c = 'STORE';

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity4.ProductType__c = 'PAYROLL_LOAN';

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity5.ProductType__c = 'SALARY_ADVANCE';

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity6.ProductType__c = 'SALARY_ADVANCE';
    opportunity6.PendencyReturn__c = true;

    List<Opportunity> newOpportunities = new List<Opportunity>{ opportunity1, opportunity2, opportunity3, opportunity4, opportunity5, opportunity6 };

    for (Opportunity opp : newOpportunities) {
        opp.StageName = 'HR';
        opp.FormalizationStatus__c = OpportunityFormalizationStatus.NEW_PROPOSAL;
    }

    Test.startTest();

    insert newOpportunities;

    Test.stopTest();

    List<Opportunity> opportunities = [SELECT ProductType__c, PriorityPoints__c, PendencyReturn__c FROM Opportunity];

    for (Opportunity opportunity : opportunities) {

        Double points = opportunity.PriorityPoints__c;

        switch on opportunity.ProductType__c {
            when 'DISCHARGE' {
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
                Double expected = opportunity.PendencyReturn__c ? 150 : 50;
                System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
            }
        }
    }
  }

  @isTest
  private static void testEvaluateByOpportunityBulk() {
    Id accountId = [SELECT Id FROM Account].Id;
    List<Opportunity> opportunities = new List<Opportunity>();

    // create 200 ooportunities
    do {
      Opportunity opportunity = OpportunitySetup.createOpportunity(accountId, 'AtWork');
      opportunity.ProductType__c = 'DISCHARGE';
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
    opportunity1.ProductType__c = 'DISCHARGE';

    Opportunity opportunity2 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity2.ProductType__c = 'REFINANCING';

    Opportunity opportunity3 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity3.ProductType__c = 'STORE';

    Opportunity opportunity4 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity4.ProductType__c = 'PAYROLL_LOAN';

    Opportunity opportunity5 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity5.ProductType__c = 'SALARY_ADVANCE';

    Opportunity opportunity6 = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opportunity6.ProductType__c = 'SALARY_ADVANCE';
    opportunity6.PendencyReturn__c = true;

    List<Opportunity> newOpportunities = new List<Opportunity>{ opportunity1, opportunity2, opportunity3, opportunity4, opportunity5, opportunity6 };

    for (Opportunity opp : newOpportunities) {
        opp.StageName = 'HR';
        opp.FormalizationStatus__c = OpportunityFormalizationStatus.NEW_PROPOSAL;
    }

    insert newOpportunities;

    List<CustomQueue__c> customQueues = [SELECT Points__c FROM CustomQueue__c];

    for (CustomQueue__c cQueue : customQueues) {
        cQueue.Points__c += 100;
    }

    Test.startTest();

    update customQueues;

    Test.stopTest();
    
    List<Opportunity> opportunities = [SELECT ProductType__c, PriorityPoints__c, PendencyReturn__c FROM Opportunity];

    for (Opportunity opportunity : opportunities) {

        Double points = opportunity.PriorityPoints__c;

        switch on opportunity.ProductType__c {
            when 'DISCHARGE' {
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
                Double expected = opportunity.PendencyReturn__c ? 350 : 150;
                System.assertEquals(expected, points, 'Incorrect Opportunity.PriorityPoints__c value');
            }
        }
    }      
  }
}
