@isTest
public class OpportunityRoleTriggerTest {
  @TestSetup
  static void makeData() {

    Account account = AccountSetup.createAccount('New Account', 'Pessoa_Fisica');

    insert account;

    Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id, 'Home');
    opportunity.ExternalId__c = 'Test001';
    opportunity.ExternalTenant__c = 'creditasbr';
    opportunity.ExternalVersion__c = 1;
    opportunity.IsExternallySynched__c = true;

    insert opportunity;

    List<OpportunityRole__c> roles = new List<OpportunityRole__c>{
      new OpportunityRole__c(
        Opportunity__c = opportunity.Id,
        ExternalPersonId__c = opportunity.AccountId,
        AccountOwner__c = true
      ),
      new OpportunityRole__c(Opportunity__c = opportunity.Id, ExternalPersonId__c = opportunity.AccountId)
    };

    insert roles;
  }

  @IsTest
  static void testInsertOpportunityRoleSuccess() {
    Opportunity opportunity = [SELECT Id, AccountId FROM Opportunity];

    OpportunityRole__c opportunityRole = new OpportunityRole__c(
      Opportunity__c = opportunity.Id,
      ExternalPersonId__c = opportunity.AccountId
    );

    Test.startTest();

    insert opportunityRole;

    Test.stopTest();

    List<OpportunityRole__c> opportunityRoles = [
      SELECT
        ExternalOpportunityId__c,
        ExternalOpportunityTenant__c,
        ExternalOpportunityVersion__c,
        Opportunity__r.IsExternallySynched__c
      FROM OpportunityRole__c
    ];

    System.assertEquals(3, opportunityRoles.size(), 'Incorrect number of Opportunity Roles');

    for (OpportunityRole__c role : opportunityRoles) {
      System.assertEquals(
        'Test001',
        role.ExternalOpportunityId__c,
        'Incorrect value for Opportunity Role ExternalOpportunityId__c'
      );
      System.assertEquals(
        'creditasbr',
        role.ExternalOpportunityTenant__c,
        'Incorrect value for Opportunity Role ExternalOpportunityTenant__c'
      );
      System.assertEquals(
        1,
        role.ExternalOpportunityVersion__c,
        'Incorrect value for Opportunity Role ExternalOpportunityVersion__c'
      );
    }
  }

  @IsTest
  static void testUpdateOpportunityRoleSuccess() {
    OpportunityRole__c opportunityRole = [SELECT AccountOwner__c FROM OpportunityRole__c WHERE AccountOwner__c = TRUE];

    opportunityRole.AccountOwner__c = false;

    Test.startTest();

    update opportunityRole;

    Test.stopTest();

    List<OpportunityRole__c> opportunityRoles = [
      SELECT
        AccountOwner__c,
        ExternalOpportunityId__c,
        ExternalOpportunityTenant__c,
        ExternalOpportunityVersion__c,
        Opportunity__r.IsExternallySynched__c
      FROM OpportunityRole__c
    ];

    System.assertEquals(2, opportunityRoles.size(), 'Incorrect number of Opportunity Roles');

    for (OpportunityRole__c role : opportunityRoles) {
      System.assertEquals(false, role.AccountOwner__c, 'Incorret value for Opportunity Role AccountOwner__c');
    }
  }

  @IsTest
  static void testInsertOpportunityRoleFail() {
    Opportunity opportunity = [SELECT Id, AccountId FROM Opportunity];

    OpportunityRole__c opportunityRole = new OpportunityRole__c(
      Opportunity__c = opportunity.Id,
      ExternalPersonId__c = opportunity.AccountId,
      AccountOwner__c = true
    );

    Exception testException;

    try {
      Test.startTest();
      insert opportunityRole;
      Test.stopTest();
    } catch (Exception e) {
      testException = e;
    }

    List<OpportunityRole__c> opportunityRoles = [
      SELECT ExternalOpportunityId__c, ExternalOpportunityTenant__c, ExternalOpportunityVersion__c
      FROM OpportunityRole__c
    ];

    System.assertEquals(2, opportunityRoles.size(), 'Incorrect number of Opportunity Roles');
    System.assertNotEquals(null, testException, 'Variable testException shouldn\'t be null');
    System.assert(
      testException.getMessage()
        .contains(
          'Não foi possível criar/atualizar o registro pois já existe um titular da conta bancária. Caso necessário, desabilite o titular atual.'
        ),
      'Incorrect exception message'
    );
  }

  @IsTest
  static void testUpdateOpportunityRoleFail() {
    OpportunityRole__c opportunityRole = [SELECT AccountOwner__c FROM OpportunityRole__c WHERE AccountOwner__c = FALSE];

    opportunityRole.AccountOwner__c = true;

    Exception testException;

    try {
      Test.startTest();
      update opportunityRole;
      Test.stopTest();
    } catch (Exception e) {
      testException = e;
    }

    List<OpportunityRole__c> opportunityRoles = [
      SELECT ExternalOpportunityId__c, ExternalOpportunityTenant__c, ExternalOpportunityVersion__c
      FROM OpportunityRole__c
    ];

    System.assertEquals(2, opportunityRoles.size(), 'Incorrect number of Opportunity Roles');
    System.assertNotEquals(null, testException, 'Variable testException shouldn\'t be null');
    System.assert(
      testException.getMessage()
        .contains(
          'Não foi possível criar/atualizar o registro pois já existe um titular da conta bancária. Caso necessário, desabilite o titular atual.'
        ),
      'Incorrect exception message'
    );
  }
}
