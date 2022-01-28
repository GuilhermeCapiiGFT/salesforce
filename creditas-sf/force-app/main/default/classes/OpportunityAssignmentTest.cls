/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe de testes da classe OpportunityAssignment
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       25/01/2021      Created     Criação da classe
 **********************************************************************************************************************/
@IsTest
private class OpportunityAssignmentTest {
  static DateTime firstDttm = Datetime.newInstance(2021, 1, 1, 1, 0, 0);
  static DateTime secondDttm = firstDttm.addSeconds(1);
  static Id accountId;
  static Id cSetupId;

  @TestSetup
  static void makeData() {
    // Custom Setup
    CustomSetup__c cSetup = new CustomSetup__c(
      Name = 'Parametrização de Filas e Usuários',
      DateFilter__c = 'Data de Solicitação'
    );
    insert cSetup;
    cSetupId = cSetup.Id;

    // Add Queues
    List<CustomQueue__c> lstCustomQueue = new List<CustomQueue__c>();
    lstCustomQueue.add(makeCustomQueue('DISCHARGE', 10));
    lstCustomQueue.add(makeCustomQueue('REFINANCING', 20));
    lstCustomQueue.add(makeCustomQueue('STORE', 30));
    lstCustomQueue.add(makeCustomQueue('PAYROLL_LOAN', 40));
    lstCustomQueue.add(makeCustomQueue('SALARY_ADVANCE', 50));
    lstCustomQueue.add(makeCustomQueue('PENDENCY_RETURN', 100));
    insert lstCustomQueue;

    // Users
    List<User> lstUsers = TestSetup.getUsers(5, true);

    // Add assigned queues
    List<ProductAssignedUser__c> lstProductUser = new List<ProductAssignedUser__c>();
    lstProductUser.add(makeProductAssignedUser('DISCHARGE', lstUsers[0].Id));
    lstProductUser.add(makeProductAssignedUser('DISCHARGE', lstUsers[1].Id));
    lstProductUser.add(makeProductAssignedUser('REFINANCING', lstUsers[1].Id));
    lstProductUser.add(makeProductAssignedUser('REFINANCING', lstUsers[2].Id));
    lstProductUser.add(makeProductAssignedUser('STORE', lstUsers[2].Id));
    lstProductUser.add(makeProductAssignedUser('STORE', lstUsers[3].Id));
    lstProductUser.add(makeProductAssignedUser('PAYROLL_LOAN', lstUsers[3].Id));
    lstProductUser.add(makeProductAssignedUser('PAYROLL_LOAN', lstUsers[4].Id));
    lstProductUser.add(makeProductAssignedUser('SALARY_ADVANCE', lstUsers[4].Id));
    insert lstProductUser;

    // Account
    Account acc = AccountSetup.createAccount('Test Account', 'Pessoa_Fisica');
    insert acc;
    accountId = acc.Id;
  }

  @isTest
  static void testOpportunityWithOwner(){

    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(makeOppty(1, 'DISCHARGE', firstDttm));
    lstOppty.add(makeOppty(2, 'REFINANCING', firstDttm));
    lstOppty.add(makeOppty(3, 'STORE', firstDttm));
    lstOppty.add(makeOppty(4, 'PAYROLL_LOAN', firstDttm));
    lstOppty.add(makeOppty(5, 'SALARY_ADVANCE', firstDttm));
    lstOppty.add(makeOppty(6, 'DISCHARGE', secondDttm));
    lstOppty.add(makeOppty(9, 'PAYROLL_LOAN', secondDttm));
    lstOppty.add(makeOppty(10, 'SALARY_ADVANCE', secondDttm));

    Opportunity opp7 = makeOppty(7, 'REFINANCING', secondDttm);
    Opportunity opp8 = makeOppty(8, 'REFINANCING', secondDttm);

    opp7.OwnerId = [SELECT Id FROM User WHERE Name = 'Test0'].Id;
    opp8.OwnerId = [SELECT Id FROM User WHERE Name = 'Test3'].Id;

    lstOppty.addAll(new List<Opportunity>{opp7, opp8});

    Test.startTest();

    insert lstOppty;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];

    // Oppty Name Prod Type       Ext Date    Expected Owner
    // Oppty 5   'SALARY_ADVANCE' firstDttm   Test4
    // Oppty 10  'SALARY_ADVANCE' secondDttm  
    // Oppty 4   'PAYROLL_LOAN'   firstDttm   
    // Oppty 9   'PAYROLL_LOAN'   secondDttm  
    // Oppty 3   'STORE'          firstDttm   Test2
    // Oppty 8   'STORE'          secondDttm  Test3
    // Oppty 2   'REFINANCING'    firstDttm   Test1
    // Oppty 7   'REFINANCING'    secondDttm  Test0
    // Oppty 1   'DISCHARGE'      firstDttm   
    // Oppty 6   'DISCHARGE'      secondDttm  

    for (Opportunity opp : lstOppty) {
      switch on opp.Name {
        when 'Test Oppty 5' {
          System.assertEquals('Test4', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 3' {
          System.assertEquals('Test2', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 8' {
          System.assertEquals('Test3', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 2' {
          System.assertEquals('Test1', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 7' {
          System.assertEquals('Test0', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when else {
          System.assert(
            opp.Owner.Name.startsWith('Test') == false,
            opp.Name +
            ' with incorrect owner assignment: ' +
            opp.Owner.Name
          );
        }
      }
    }    
  }  

  @isTest
  static void testOpportunityWithoutOwner() {

    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(makeOppty(1, 'DISCHARGE', firstDttm));
    lstOppty.add(makeOppty(2, 'REFINANCING', firstDttm));
    lstOppty.add(makeOppty(3, 'STORE', firstDttm));
    lstOppty.add(makeOppty(4, 'PAYROLL_LOAN', firstDttm));
    lstOppty.add(makeOppty(5, 'SALARY_ADVANCE', firstDttm));
    lstOppty.add(makeOppty(6, 'DISCHARGE', secondDttm));
    lstOppty.add(makeOppty(7, 'REFINANCING', secondDttm));
    lstOppty.add(makeOppty(8, 'STORE', secondDttm));
    lstOppty.add(makeOppty(9, 'PAYROLL_LOAN', secondDttm));
    lstOppty.add(makeOppty(10, 'SALARY_ADVANCE', secondDttm));

    Test.startTest();

    insert lstOppty;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];

    // Oppty Name Prod Type       Ext Date    Expected Owner
    // Oppty 5   'SALARY_ADVANCE' firstDttm   Test4
    // Oppty 10  'SALARY_ADVANCE' secondDttm  
    // Oppty 4   'PAYROLL_LOAN'   firstDttm   Test3
    // Oppty 9   'PAYROLL_LOAN'   secondDttm  
    // Oppty 3   'STORE'          firstDttm   Test2
    // Oppty 8   'STORE'          secondDttm  
    // Oppty 2   'REFINANCING'    firstDttm   Test1
    // Oppty 7   'REFINANCING'    secondDttm  
    // Oppty 1   'DISCHARGE'      firstDttm   Test0
    // Oppty 6   'DISCHARGE'      secondDttm  

    for (Opportunity opp : lstOppty) {
      switch on opp.Name {
        when 'Test Oppty 1' {
          System.assertEquals('Test0', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 2' {
          System.assertEquals('Test1', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 3' {
          System.assertEquals('Test2', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 4' {
          System.assertEquals('Test3', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 5' {
          System.assertEquals('Test4', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when else {
          System.assert(
            opp.Owner.Name.startsWith('Test') == false,
            opp.Name +
            ' with incorrect owner assignment: ' +
            opp.Owner.Name
          );
        }
      }
    }
  }  

  @isTest
  static void testUnavailableUser(){

    User u1 = [SELECT Id FROM User WHERE Name = 'Test0'];
    User u2 = [SELECT Id FROM User WHERE Name = 'Test3'];

    u1.UserAvailable__c = false;
    u2.UserAvailable__c = false;

    update new List<User>{u1, u2};

    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(makeOppty(1, 'DISCHARGE', firstDttm));
    lstOppty.add(makeOppty(2, 'REFINANCING', firstDttm));
    lstOppty.add(makeOppty(3, 'STORE', firstDttm));
    lstOppty.add(makeOppty(4, 'PAYROLL_LOAN', firstDttm));
    lstOppty.add(makeOppty(5, 'SALARY_ADVANCE', firstDttm));
    lstOppty.add(makeOppty(6, 'DISCHARGE', secondDttm));
    lstOppty.add(makeOppty(7, 'REFINANCING', secondDttm));
    lstOppty.add(makeOppty(8, 'STORE', secondDttm));
    lstOppty.add(makeOppty(9, 'PAYROLL_LOAN', secondDttm));
    lstOppty.add(makeOppty(10, 'SALARY_ADVANCE', secondDttm));    

    Test.startTest();

    insert lstOppty;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];

    // Oppty Name Prod Type       Ext Date    Expected Owner
    // Oppty 5   'SALARY_ADVANCE' firstDttm   Test4
    // Oppty 10  'SALARY_ADVANCE' secondDttm  
    // Oppty 4   'PAYROLL_LOAN'   firstDttm   
    // Oppty 9   'PAYROLL_LOAN'   secondDttm  
    // Oppty 3   'STORE'          firstDttm   Test2
    // Oppty 8   'STORE'          secondDttm  
    // Oppty 2   'REFINANCING'    firstDttm   Test1
    // Oppty 7   'REFINANCING'    secondDttm  
    // Oppty 1   'DISCHARGE'      firstDttm   
    // Oppty 6   'DISCHARGE'      secondDttm      

    for (Opportunity opp : lstOppty) {
      switch on opp.Name {
        when 'Test Oppty 5' {
          System.assertEquals('Test4', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 3' {
          System.assertEquals('Test2', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 2' {
          System.assertEquals('Test1', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when else {
          System.assert(
            opp.Owner.Name.startsWith('Test') == false,
            opp.Name +
            ' with incorrect owner assignment: ' +
            opp.Owner.Name
          );
        }
      }
    }      
  }

  static Opportunity makeOppty(Integer num, String prodType, Datetime externalCreatedDttm) {
    Opportunity opp = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opp.Name = 'Test Oppty ' + num;
    opp.ProductType__c = prodType;
    opp.ExternalCreationDate__c = externalCreatedDttm;
    return opp;
  }

  static ProductAssignedUser__c makeProductAssignedUser(String prodType, Id userId) {
    return new ProductAssignedUser__c(
      Name = 'Test',
      CustomSetupUser__c = cSetupId,
      ProductType__c = prodType,
      User__c = userId
    );
  }

  static CustomQueue__c makeCustomQueue(String prodType, Double points) {
    return new CustomQueue__c(Name = 'Test', ProductType__c = prodType, CustomSetup__c = cSetupId, Points__c = points);
  }
}