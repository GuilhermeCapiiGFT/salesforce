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
  //Global Variables that will be used throughout the test class
  static DateTime firstDttm = Datetime.newInstance(2021, 1, 1, 1, 0, 0);
  static DateTime secondDttm = firstDttm.addSeconds(1);
  //static Id accountId;
  static Id cSetupId;

  @TestSetup
  static void makeData() {
    // Custom Setup
    String cSetupRecordType = Util.getRecordTypeIdbyName('CustomSetup__C', 'AtWork');
    CustomSetup__c cSetup = new CustomSetup__c(
      Name = 'Parametrização de Filas e Usuários',
      DateFilter__c = 'RequestDate',
      RecordTypeId = cSetupRecordType
    );
    insert cSetup;
    cSetupId = cSetup.Id;

    // Creates a CustomQueue with a number of points for each type of queue
    List<CustomQueue__c> lstCustomQueue = new List<CustomQueue__c>();
    lstCustomQueue.add(makeCustomQueue('DISCHARGE', 10));
    lstCustomQueue.add(makeCustomQueue('REFINANCING', 20));
    lstCustomQueue.add(makeCustomQueue('STORE', 30));
    lstCustomQueue.add(makeCustomQueue('PAYROLL_LOAN', 40));
    lstCustomQueue.add(makeCustomQueue('SALARY_ADVANCE', 50));
    lstCustomQueue.add(makeCustomQueue('PENDENCY_RETURN', 100));
    insert lstCustomQueue;

    // Create users with different LastAttendance__c atribute.
    // LastAttendance__c is the date/time when user finished attending it's last @work ooportunity
    // @Work opportunity assignment considers LastAttendance__c (user with least recent date/time has priority)
    List<User> lstUsers = TestSetup.getUsers(5, false);
    lstUsers[0].LastAttendance__c = DateTime.newInstance(2020, 12, 20);
    lstUsers[1].LastAttendance__c = DateTime.newInstance(2020, 12, 19);
    lstUsers[2].LastAttendance__c = DateTime.newInstance(2020, 12, 18);
    lstUsers[3].LastAttendance__c = DateTime.newInstance(2020, 12, 17);
    lstUsers[4].LastAttendance__c = DateTime.newInstance(2020, 12, 16);
    insert lstUsers;

    // Creates a list of Users assigned to a specific type of queue, only users assigned to that queue are able to recieve an opportunity
    //From the list of users, EX: only user in position [0] named Test0, is only able to recieve opportunities with 'DISCHARGE' and so on
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

    // Create default Account
    // Account acc = AccountSetup.createAccount('Test Account', 'Pessoa_Fisica');
    // insert acc;
    // accountId = acc.Id;

    // Create several Opportunities with different product types and External Created Dates
    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(makeOppty(1, 'DISCHARGE', firstDttm, ''));
    lstOppty.add(makeOppty(2, 'REFINANCING', firstDttm, ''));
    lstOppty.add(makeOppty(3, 'STORE', firstDttm, ''));
    lstOppty.add(makeOppty(4, 'PAYROLL_LOAN', firstDttm, ''));
    lstOppty.add(makeOppty(5, 'SALARY_ADVANCE', firstDttm, ''));
    lstOppty.add(makeOppty(6, 'DISCHARGE', secondDttm, ''));
    lstOppty.add(makeOppty(7, 'REFINANCING', secondDttm, ''));
    lstOppty.add(makeOppty(8, 'STORE', secondDttm, ''));
    lstOppty.add(makeOppty(9, 'PAYROLL_LOAN', secondDttm, ''));
    lstOppty.add(makeOppty(10, 'SALARY_ADVANCE', secondDttm, ''));    
    insert lstOppty;
  }

  @isTest
  static void testOpportunityWithOwner(){

    List<Opportunity> lstOpptyAssignFirst = new List<Opportunity>();
    List<Opportunity> lstOpptyAssignSecond = new List<Opportunity>();

    // Change opportunities to trigger the assignments
    List<Opportunity> lstOppty = [SELECT Id, Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];
    for (Opportunity op : lstOppty) {
      op.StageName = 'Formalização';
      if (op.Name == 'Test Oppty 7' || op.Name == 'Test Oppty 8') {
        lstOpptyAssignFirst.add(op);
      } else {
        lstOpptyAssignSecond.add(op);
      }
    }

    Test.startTest();
    
    // First update will assign users Test2 and Test3, making them unavailable for the next assignment
    // This behavior is them validated on the test asserts
    update lstOpptyAssignFirst;
    update lstOpptyAssignSecond;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%' ORDER BY Name ASC];
    
    // Auxiliary table to verify the asserts, sorted by Priority
    // Oppty Name Prod Type       Ext Date    Expected Owner
    // Oppty 5   'SALARY_ADVANCE' firstDttm   Test4
    // Oppty 10  'SALARY_ADVANCE' secondDttm  
    // Oppty 4   'PAYROLL_LOAN'   firstDttm   
    // Oppty 9   'PAYROLL_LOAN'   secondDttm  
    // Oppty 3   'STORE'          firstDttm   
    // Oppty 8   'STORE'          secondDttm  Test3
    // Oppty 2   'REFINANCING'    firstDttm   Test1
    // Oppty 7   'REFINANCING'    secondDttm  Test2
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
        when 'Test Oppty 5' {
          System.assertEquals('Test4', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 7' {
          System.assertEquals('Test2', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 8' {
          System.assertEquals('Test3', opp.Owner.Name, 'Incorrect owner assignment');
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

    // Change opportunities to trigger the assignments
    List<Opportunity> lstOppty = [SELECT Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];
    for (Opportunity op : lstOppty) {
      op.StageName = 'Formalização';
    }

    Test.startTest();

    update lstOppty;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%' ORDER BY Name ASC];

    // Auxiliary table to verify the asserts, sorted by Priority
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

    // Make users unavailable for assignment
    List<User> lstUser = [SELECT Id FROM User WHERE Name IN ('Test0', 'Test3')];
    for (User u : lstUser) {
      u.UserAvailable__c = false;
    }

    update lstUser;

    // Change opportunities to trigger the assignments
    List<Opportunity> lstOppty = [SELECT Name FROM Opportunity WHERE Name LIKE 'Test Oppty%'];
    for (Opportunity op : lstOppty) {
      op.StageName = 'Formalização';
    }    

    Test.startTest();

    update lstOppty;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name FROM Opportunity WHERE Name LIKE 'Test Oppty%' ORDER BY Name ASC];

    //Auxiliary table to verify the asserts, sorted by Priority
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
        when 'Test Oppty 2' {
          System.assertEquals('Test1', opp.Owner.Name, 'Incorrect owner assignment');
        }
        when 'Test Oppty 3' {
          System.assertEquals('Test2', opp.Owner.Name, 'Incorrect owner assignment');
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
  private static void testMultipleOppsSameAccount(){
    List<Opportunity> oppList = [SELECT Id,AccountId FROM Opportunity WHERE ProductType__c = 'SALARY_ADVANCE'];
    String accountId = oppList[0]?.AccountId;
    
    List<Opportunity> oppsToCreate = new List<Opportunity>{};
    for(Integer i = 11; i <= 211; i++){
      oppsToCreate.add(makeOppty(i, 'SALARY_ADVANCE', secondDttm, accountId));
    }
    insert oppsToCreate;
    oppList.addAll(oppsToCreate);
    for(Opportunity iOpp : oppList){
      iOpp.AccountId =  accountId;
      iOpp.StageName = 'Formalização';
    }
    Test.startTest();
      update oppList;
    Test.stopTest();

    List<Opportunity> oppsAfterUpdate = [SELECT Owner.Name FROM Opportunity WHERE ProductType__c = 'SALARY_ADVANCE'];
    for(Opportunity iOpp : oppsAfterUpdate){
      System.assertEquals('Test4', iOpp.Owner.Name, 'Incorrect Owner assigned');
    }
  }

  //Auxiliary method to return opportunties
  static Opportunity makeOppty(Integer num, String prodType, Datetime externalCreatedDttm, String accountId) {
    if(String.isBlank(accountId)){
      Account account = AccountSetup.createAccount('Conta' + num, 'Pessoa_Fisica');
      insert account;
      accountId = account.Id;
    }
    Opportunity opp = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opp.Name = 'Test Oppty ' + num;
    opp.StageName = 'HR';
    opp.FormalizationStatus__c = 'NewProposal';
    opp.ProductType__c = prodType;
    opp.ExternalCreationDate__c = externalCreatedDttm;
    return opp;
  }

  //Auxiliary method to return ProductAssignedUser
  static ProductAssignedUser__c makeProductAssignedUser(String prodType, Id userId) {
    return new ProductAssignedUser__c(
      CustomSetupUser__c = cSetupId,
      ProductType__c = prodType,
      User__c = userId
    );
  }

  //Auxiliary method to return CustomQueue
  static CustomQueue__c makeCustomQueue(String prodType, Double points) {
    return new CustomQueue__c(Name = 'Test', ProductType__c = prodType, CustomSetup__c = cSetupId, Points__c = points);
  }
}