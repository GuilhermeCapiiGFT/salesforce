@IsTest
private class OpportunityAssignmentTest {
  //Global Variables that will be used throughout the test class
  private static DateTime firstDttm = Datetime.now();
  private static DateTime secondDttm = firstDttm.addSeconds(1);
  private static Id cSetupId;
  private static string oppApprovedByRH = 'Aprovado por RH';
  private static String awaitingFormalizationAssignment = 'Aguardando Distribuição de Formalização';

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
    lstCustomQueue.add(makeCustomQueue('DISCHARGING', 10, 'AtWork'));
    lstCustomQueue.add(makeCustomQueue('REFINANCING', 20, 'AtWork'));
    lstCustomQueue.add(makeCustomQueue('STORE', 30, 'AtWork'));
    lstCustomQueue.add(makeCustomQueue('PAYROLL_LOAN', 40, 'AtWork'));
    lstCustomQueue.add(makeCustomQueue('SALARY_ADVANCE', 50, 'AtWork'));
    lstCustomQueue.add(makeCustomQueue('PENDENCY_RETURN', 100, 'AtWork'));
    insert lstCustomQueue;

    String cSetupAutoFinRT = Util.getRecordTypeIdbyName('CustomSetup__C', 'AutoFin');
    CustomSetup__c cSetupAutoFin = new CustomSetup__c(
      Name = 'Parametrização de Filas e Usuários',
      DateFilter__c = 'RequestDate',
      RecordTypeId = cSetupAutoFinRT
    );
    insert cSetupAutoFin;
    cSetupId = cSetupAutoFin.Id;
    CustomQueue__c cQueue = makeCustomQueue('AUTO_FIN', 50, 'AutoFin');
    insert cQueue;

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

    ProductAssignedUser__c prodUserAuto = makeProductAssignedUser('AUTO_FIN', lstUsers[0].Id);
    insert prodUserAuto;

    cSetupId = cSetup.Id;
    // Creates a list of Users assigned to a specific type of queue, only users assigned to that queue are able to recieve an opportunity
    //From the list of users, EX: only user in position [0] named Test0, is only able to recieve opportunities with 'DISCHARGING' and so on
    List<ProductAssignedUser__c> lstProductUser = new List<ProductAssignedUser__c>();
    lstProductUser.add(makeProductAssignedUser('DISCHARGING', lstUsers[0].Id));
    lstProductUser.add(makeProductAssignedUser('DISCHARGING', lstUsers[1].Id));
    lstProductUser.add(makeProductAssignedUser('REFINANCING', lstUsers[1].Id));
    lstProductUser.add(makeProductAssignedUser('REFINANCING', lstUsers[2].Id));
    lstProductUser.add(makeProductAssignedUser('STORE', lstUsers[2].Id));
    lstProductUser.add(makeProductAssignedUser('STORE', lstUsers[3].Id));
    lstProductUser.add(makeProductAssignedUser('PAYROLL_LOAN', lstUsers[3].Id));
    lstProductUser.add(makeProductAssignedUser('PAYROLL_LOAN', lstUsers[4].Id));
    lstProductUser.add(makeProductAssignedUser('SALARY_ADVANCE', lstUsers[4].Id));
    insert lstProductUser;


    // Create several Opportunities with different product types and External Created Dates
    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(makeOppty(1, 'DISCHARGING', firstDttm, ''));
    lstOppty.add(makeOppty(2, 'REFINANCING', firstDttm, ''));
    lstOppty.add(makeOppty(3, 'STORE', firstDttm, ''));
    lstOppty.add(makeOppty(4, 'PAYROLL_LOAN', firstDttm, ''));
    lstOppty.add(makeOppty(5, 'SALARY_ADVANCE', firstDttm, ''));
    lstOppty.add(makeOppty(6, 'DISCHARGING', secondDttm, ''));
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
    List<Opportunity> lstOppty = [SELECT Id, Name FROM Opportunity WHERE Name LIKE 'Test Oppty%' AND RecordType.DeveloperName = 'AtWork'];
    for (Opportunity op : lstOppty) {
      op.StageName = oppApprovedByRH;
      if (op.Name == 'Test Oppty 7' || op.Name == 'Test Oppty 8') {
        lstOpptyAssignFirst.add(op);
      } else {
        lstOpptyAssignSecond.add(op);
      }
    }
    String testUser2Id = [SELECT Id FROM User WHERE Name = 'Test2']?.Id;
    String testUser3Id = [SELECT Id FROM User WHERE Name = 'Test3']?.Id;
    for(Opportunity opp : lstOpptyAssignFirst){
      opp.StageName = 'Em Análise de Formalização';
      if(opp.Name == 'Test Oppty 7'){
        opp.OwnerId = testUser2Id;
      } else {
        opp.OwnerId = testUser3Id;
      }
    }
    update lstOpptyAssignFirst;
    Test.startTest();
    // First update will assign users Test2 and Test3, making them unavailable for the next assignment
      update lstOpptyAssignSecond;

    Test.stopTest();

    lstOppty = [SELECT Name, Owner.Name, StageName FROM Opportunity WHERE Name LIKE 'Test Oppty%' ORDER BY Name ASC];
    
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
    // Oppty 1   'DISCHARGING'      firstDttm   Test0
    // Oppty 6   'DISCHARGING'      secondDttm  

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
      op.StageName = oppApprovedByRH;
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
    // Oppty 1   'DISCHARGING'      firstDttm   Test0
    // Oppty 6   'DISCHARGING'      secondDttm  

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
      op.StageName = oppApprovedByRH;
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
    // Oppty 1   'DISCHARGING'      firstDttm   
    // Oppty 6   'DISCHARGING'      secondDttm      

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
    List<Opportunity> oppList = [SELECT Id,AccountId FROM Opportunity];
    delete oppList;

    Account acc = AccountSetup.createAccount('VAI_BRASIL', 'Pessoa_Fisica');
    insert acc;
    String accountId = acc.Id;

    Opportunity firstOpp = makeOppty(666, 'SALARY_ADVANCE', secondDttm, accountId);
    insert firstOpp;
    firstOpp.StageName = oppApprovedByRH;
    update firstOpp;

    List<Opportunity> oppsToCreate = new List<Opportunity>{};
    for(Integer i = 11; i <= 211; i++){
      oppsToCreate.add(makeOppty(i, 'SALARY_ADVANCE', secondDttm, accountId));
    }

    insert oppsToCreate;

    for(Opportunity opp : oppsToCreate){
      opp.StageName = oppApprovedByRH;
    }
    Test.startTest();
      update oppsToCreate;
    Test.stopTest();

    List<Opportunity> oppsAfterUpdate = [SELECT Name,QueueName__c,Owner.Name FROM Opportunity WHERE QueueName__c = 'SALARY_ADVANCE'];
    for(Opportunity opp : oppsAfterUpdate){
      System.assertEquals('Test4', opp.Owner.Name, 'Incorrect Owner assigned');
    }
  }

  @isTest
  private static void testAutoFinApprovedDistributionOneOpp(){
    List<Opportunity> oppList = new List<Opportunity>();
    oppList.add(makeOpptyAuto(1,'AUTO_FIN',firstDttm,''));
    oppList.add(makeOpptyAuto(2,'AUTO_FIN',secondDttm,''));
    insert oppList;
    String ownerName;
    List<Opportunity> oppAutoList = [SELECT Owner.Name,StageName FROM Opportunity WHERE RecordType.DeveloperName = 'AutoFin' ORDER BY ExternalCreationDate__c ASC];
    for(Opportunity opp : oppAutoList){
      opp.StageName = 'Aguardando Distribuição de Formalização';
      ownerName = opp.Owner.Name;
    }
    Test.startTest();
      update oppAutoList;
    Test.stopTest();

    List<Opportunity> oppAutoListAfterUpdate = [SELECT Owner.Name,StageName FROM Opportunity WHERE RecordType.DeveloperName = 'AutoFin' ORDER BY ExternalCreationDate__c ASC];
    System.assertEquals('Test0', oppAutoListAfterUpdate[0].Owner.Name, 'Opportunity was not assigned');
    System.assertEquals(ownerName, oppAutoListAfterUpdate[1].Owner.Name, 'Opportunity should not be assigned');
  }

  @isTest
  private static void testAutoFinApprovedDistribution(){
    List<Opportunity> oppList = new List<Opportunity>();
    oppList.add(makeOpptyAuto(1,'AUTO_FIN',firstDttm,''));
    oppList.add(makeOpptyAuto(2,'AUTO_FIN',secondDttm,''));
    insert oppList;
    String ownerName;
    List<Opportunity> oppAutoList = [SELECT Owner.Name,StageName FROM Opportunity WHERE RecordType.DeveloperName = 'AutoFin' ORDER BY ExternalCreationDate__c ASC];
    for(Opportunity opp : oppAutoList){
      opp.StageName = awaitingFormalizationAssignment;
      ownerName = opp.Owner.Name;
    }
    update oppAutoList;
    Test.startTest();
      oppAutoList[0].StageName = 'Em Análise de Formalização';
      update oppAutoList;
      oppAutoList[0].StageName = 'Aguardando emissão de contrato';
      update oppAutoList;
    Test.stopTest();
    List<Opportunity> oppAutoListLastUpdate = [SELECT Owner.Name,StageName FROM Opportunity WHERE RecordType.DeveloperName = 'AutoFin' ORDER BY ExternalCreationDate__c ASC];
    System.assertEquals('Test0', oppAutoListLastUpdate[0].Owner.Name, 'Opportunity was not assigned');
    System.assertEquals('Test0', oppAutoListLastUpdate[1].Owner.Name, 'Opportunity was not assigned');
  }

  @isTest
  private static void testDeletingInactiveUser(){
    
    List<User> allUsers = [SELECT Id FROM User WHERE EmployeeNumber LIKE 'TER01984%' AND CreatedDate = TODAY];
    for(User u : allUsers){
      u.IsActive = false;
    }
    Id myId = UserInfo.getUserId();
    System.runAs(new User(Id = myId)){
      update allUsers;
    }
    
    List<Opportunity> allOpps = [SELECT Id, RecordType.DeveloperName FROM Opportunity];
    for(Opportunity opp : allOpps){
      opp.StageName = opp.RecordType.DeveloperName == 'AtWork' ? oppApprovedByRH : awaitingFormalizationAssignment;
    }
    Test.startTest();
      update allOpps;
    Test.stopTest();
    List<Opportunity> allOppsAfterUpdate = [SELECT Id,OwnerId FROM Opportunity];
    
    for(Opportunity opp : allOppsAfterUpdate){
      System.assertEquals(myId, opp.OwnerId, 'No Opportunities should have been assigned');
    }
    System.assertEquals(0, [SELECT Count() FROM ProductAssignedUser__c], 'All ProductAssignedUser records should have been deleted');
    
  }

  @isTest
  private static void testOldOpportunityUpdate(){
    List<Opportunity> oppToDelete = [SELECT Id FROM Opportunity];
    delete oppToDelete;
    Datetime oldDt = Datetime.now().addMonths(-4);
    Opportunity oldOpp = makeOppty(2077, 'DISCHARGING', oldDt, '');
    insert oldOpp;
    oldOpp.StageName = oppApprovedByRH;
    Test.startTest();
    update oldOpp;
    Test.stopTest();
    Opportunity opp = [SELECT StageName, OwnerId FROM Opportunity LIMIT 1];
    System.assertEquals(oppApprovedByRH, opp.StageName, 'Opportunity StageName should not be updated');
    System.assertEquals(opp.OwnerId, UserInfo.getUserId(), 'Opportunity Owner should not be updated');

  }

  private static Opportunity makeOpptyAuto(Integer num, String queueName, Datetime externalCreatedDttm, String accountId){
    Opportunity oppAuto = makeOppty(num, queueName, externalCreatedDttm, accountId);
    oppAuto.RecordTypeId = Util.getRecordTypeIdbyName('Opportunity','AutoFin');
    return oppAuto;
  }

  //Auxiliary method to return opportunties
  private static Opportunity makeOppty(Integer num, String queueName, Datetime externalCreatedDttm, String accountId) {
    if(String.isBlank(accountId)){
      Account account = AccountSetup.createAccount('Conta' + num, 'Pessoa_Fisica');
      insert account;
      accountId = account.Id;
    }
    Opportunity opp = OpportunitySetup.createOpportunity(accountId, 'AtWork');
    opp.Name = 'Test Oppty ' + num;
    opp.StageName = 'Novo';
    opp.QueueName__c = queueName;
    opp.ExternalCreationDate__c = externalCreatedDttm;
    return opp;
  }

  //Auxiliary method to return ProductAssignedUser
  static ProductAssignedUser__c makeProductAssignedUser(String queueName, Id userId) {
    String recordTypeName = queueName == 'AUTO_FIN' ? 'AutoFin' : 'AtWork';
    String rtId = Util.getRecordTypeIdbyName('ProductAssignedUser__c', recordTypeName);
    return new ProductAssignedUser__c(
      CustomSetupUser__c = cSetupId,
      QueueName__c = queueName,
      User__c = userId,
      RecordTypeId = rtId
    );
  }

  //Auxiliary method to return CustomQueue
  static CustomQueue__c makeCustomQueue(String queueName, Double points, String recordTypeDevName) {
    String cQUeueRT = Util.getRecordTypeIdbyName('CustomQueue__c', recordTypeDevName);
    return new CustomQueue__c(Name = 'Test', QueueName__c = queueName, CustomSetup__c = cSetupId, Points__c = points, RecordTypeId = cQUeueRT);
  }
}