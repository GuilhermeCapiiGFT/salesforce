public with sharing class OpportunityAssignmentService {
  public static final String NEW_OPP = 'Novo';
  public static final String APPROVED_BY_HR = 'Aprovado por RH';
  public static final String AWAITING_FORMALIZATION_ASSIGNMENT = 'Aguardando Distribuição de Formalização';
  public static final String AWAITING_FORMALIZATION_ANALYSIS = 'Aguardando Análise de Formalização';
  public static final String UNDER_FORMALIZATION_ANALYSIS = 'Em Análise de Formalização';
  public static final String AWAITING_COMITEE_ASSIGNMENT = 'Aguardando Distribuição para Comitê de Formalização';
  public static final String AWAITING_COMITEE_ANALYSIS = 'Aguardando Análise de Comitê de Formalização';
  public static final String UNDER_COMMITEE_ANALYSIS = 'Em Análise de Comitê de Formalização';
  public static final String FORMALIZATION_PENDENCY_RETURN = 'Retorno de Pendência de Formalização';
  public static final String CONSULTING_PENDENCY = 'Pendenciado para Consultoria';

  public static string opportunityRecordTypeDevName;
  public static Map<String, String> stageNameMap;

  private static Map<String, Set<String>> mapAssignedOppStages = new Map<String, Set<String>>{
    'AtWork' => new Set<String>{ AWAITING_FORMALIZATION_ANALYSIS, UNDER_FORMALIZATION_ANALYSIS },
    'AutoFin' => new Set<String>{ AWAITING_FORMALIZATION_ANALYSIS, UNDER_FORMALIZATION_ANALYSIS, AWAITING_COMITEE_ANALYSIS, UNDER_COMMITEE_ANALYSIS }
  };

  private static Map<String, String> mapStagesToSet = new Map<String, String>{
    APPROVED_BY_HR => AWAITING_FORMALIZATION_ANALYSIS,
    FORMALIZATION_PENDENCY_RETURN => AWAITING_FORMALIZATION_ANALYSIS,
    AWAITING_COMITEE_ASSIGNMENT => AWAITING_COMITEE_ANALYSIS,
    AWAITING_FORMALIZATION_ASSIGNMENT => AWAITING_FORMALIZATION_ANALYSIS
  };

  private static Map<String, Boolean> userAvaiableMap = new Map<String, Boolean>();
  private static Set<Id> allRegisteredUsers = new Set<Id>();
  private static Set<Id> assignedOpps = new Set<Id>();

  public static Map<String, String> createStageNameMap(List<String> stageNameList) {
    Map<String, String> stageMap = new Map<String, String>{
      'stageNameFrom' => stageNameList.remove(0),
      'stageNameTo' => stageNameList.remove(0),
      'stageNameFromPendency' => stageNameList.remove(0),
      'stageNameToPendency' => stageNameList.remove(0),
      'stageNameUnderAnalysis' => stageNameList.remove(0),
      'stageNameCommiteeAnalysis' => stageNameList.remove(0)
    };
    return stageMap;
  }

  public static Boolean checkOpportunities(List<Opportunity> opportuntitiesInput) {
    if (opportunityRecordTypeDevName == null || stageNameMap == null || stageNameMap.isEmpty()) {
      throw new OpportunityAssignmentException('Please set up the variables for opportunityRecordTypeDevName and fill the stageNameMap with the required variables');
    }

    String oppRecordType = getRecordTypeId(opportunityRecordTypeDevName);
    boolean runAssignment = false;
    for (Opportunity opp : opportuntitiesInput) {
      if (
        opp.RecordTypeId == oppRecordType &&
        (TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFrom'), stageNameMap.get('stageNameTo')) ||
        TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFromPendency'), stageNameMap.get('stageNameToPendency')) ||
        TriggerHelper.changedFrom(opp, 'Stagename', stageNameMap.get('stageNameUnderAnalysis')) ||
        TriggerHelper.changedFrom(opp, 'Stagename', stageNameMap.get('stageNameCommiteeAnalysis')))
      ) {
        runAssignment = true;
        break;
      }
    }

    return runAssignment;
  }

  public static List<Opportunity> assignOpportunities(List<Opportunity> inputOppList, CustomSetup__c cSetup, String recordTypeDevName) {
    List<Opportunity> oppsToAssign = new List<Opportunity>();

    if (cSetup.ProductAssignedUsers__r.isEmpty() || inputOppList.isEmpty()) {
      return oppsToAssign;
    }

    Map<Id, Set<String>> mapUser = createUserMap(cSetup.ProductAssignedUsers__r, recordTypeDevName);

    //Initially this will be a fixed value, but later can be configured via the customSetup Record for each B.U, allowing multiple opps to be distributed to each analyst.
    Integer numberOfOppsPerUser = 1;

    Map<String, String> accountUserIdMap = new Map<String, String>();

    if (OpportunityAssignmentController.ATWORK == recordTypeDevName || OpportunityAssignmentController.AUTOFIN == recordTypeDevName) {
      accountUserIdMap = (Map<String, String>) Cache.Org.getPartition('local.atWorkAssignment').get(recordTypeDevName + 'UserAccountIdMap') == null
        ? new Map<String, String>()
        : (Map<String, String>) Cache.Org.getPartition('local.atWorkAssignment').get(recordTypeDevName + 'UserAccountIdMap');
    }

    if (!accountUserIdMap.isEmpty()) {
      verifyRequestsBySameClient(oppsToAssign, inputOppList, accountUserIdMap);
    }

    for (Id userId : mapUser.keySet()) {
      List<Opportunity> avaiableOpps = filterAvaiableOppsForUser(inputOppList, mapUser.get(userId), numberOfOppsPerUser);

      if (avaiableOpps.isEmpty() || !verifyUserAvaliability(userId)) {
        continue;
      }

      Integer leastAmount = numberOfOppsPerUser < avaiableOpps.size() ? numberOfOppsPerUser : avaiableOpps.size();

      for (Integer i = 0; i <= leastAmount - 1; i++) {
        Opportunity opp = avaiableOpps.get(i);
        setOppFields(opp, userId);
        oppsToAssign.add(opp);
        assignedOpps.add(opp.Id);
        if (!opp.StageName.contains('Comitê')) {
          accountUserIdMap.put(opp.AccountId, userId);
        }
      }
    }

    if (!accountUserIdMap.isEmpty() && (OpportunityAssignmentController.ATWORK == recordTypeDevName || OpportunityAssignmentController.AUTOFIN == recordTypeDevName)) {
      Cache.Org.put('local.atWorkAssignment.' + recordTypeDevName + 'UserAccountIdMap', accountUserIdMap, 43200, Cache.Visibility.ALL, false);
    }

    return oppsToAssign;
  }

  private static Boolean verifyUserAvaliability(String userId) {
    if (!userAvaiableMap.containsKey(userId)) {
      allRegisteredUsers.add(userId);
      fillUserAvaiableMap();
    }
    return userAvaiableMap.get(userId);
  }

  private static void fillUserAvaiableMap() {
    Set<Id> inactiveUsers = new Set<Id>();
    for (User u : [SELECT Id, UserAvailable__c, isActive FROM User WHERE Id IN :allRegisteredUsers]) {
      if (!u.IsActive) {
        inactiveUsers.add(u.Id);
      }
      userAvaiableMap.put(u.Id, (u.UserAvailable__c && u.IsActive));
    }
    if (!inactiveUsers.isEmpty()) {
      deleteInactiveUsersFuture(inactiveUsers);
    }
  }

  @future
  private static void deleteInactiveUsersFuture(Set<Id> inactiveUsers) {
    List<ProductAssignedUser__c> recordsToDelete = [SELECT Id FROM ProductAssignedUser__c WHERE User__c IN :inactiveUsers];
    Database.delete(recordsToDelete);
  }

  private static void verifyRequestsBySameClient(List<Opportunity> oppsToAssign, List<Opportunity> inputOppList, Map<String, String> accountUserIdMap) {
    for (Opportunity op : inputOppList) {
      if (!op.StageName.contains('Comitê') && accountUserIdMap.containsKey(op.AccountId) && verifyUserAvaliability(accountUserIdMap.get(op.AccountId))) {
        setOppFields(op, accountUserIdMap.get(op.AccountId));
        oppsToAssign.add(op);
        assignedOpps.add(op.Id);
      }
    }
  }

  private static List<Opportunity> filterAvaiableOppsForUser(List<Opportunity> oppList, Set<String> avaiableQueueNames, Integer numberOfOpps) {
    List<Opportunity> filteredOpps = new List<Opportunity>();
    for (Opportunity opp : oppList) {
      if (!assignedOpps.contains(opp.Id) && (avaiableQueueNames.contains(opp.QueueName__c) || (avaiableQueueNames.contains('COMMITTEE') && opp.StageName.contains('Comitê')))) {
        filteredOpps.add(opp);
        if (filteredOpps.size() == numberOfOpps) {
          break;
        }
      }
    }

    return filteredOpps;
  }

  private static void setOppFields(Opportunity opportunity, Id ownerId) {
    opportunity.OwnerId = ownerId;
    opportunity.StageName = mapStagesToSet.get(opportunity.StageName);
  }

  private static Set<Id> getUnavailableUsers(List<Opportunity> lstOpp, List<ProductAssignedUser__c> lstProductUser) {
    Set<Id> setAllUsers = new Set<Id>();
    Set<Id> setUnavailableUsers = new Set<Id>();

    for (ProductAssignedUser__c prodUser : lstProductUser) {
      setAllUsers.add(prodUser.User__c);
      if (!prodUser.User__r.UserAvailable__c) {
        setUnavailableUsers.add(prodUser.User__c);
      }
    }

    for (Opportunity op : lstOpp) {
      if (setAllUsers.contains(op.OwnerId)) {
        setUnavailableUsers.add(op.OwnerId);
      }
    }

    return setUnavailableUsers;
  }

  private static Map<Id, Set<String>> createUserMap(List<ProductAssignedUser__c> lstProductUser, String recordTypeDevName) {
    Set<Id> setUnavailableUsers = getUnavailableUsers(getAssignedOpps(recordTypeDevName), lstProductUser);
    Map<Id, Set<String>> userMap = new Map<Id, Set<String>>();

    for (ProductAssignedUser__c productUser : lstProductUser) {
      if (setUnavailableUsers.contains(productUser.User__c)) {
        continue;
      }
      allRegisteredUsers.add(productUser.User__c);
      if (userMap.containsKey(productUser.User__c)) {
        userMap.get(productUser.User__c).add(productUser.QueueName__c);
      } else {
        userMap.put(productUser.User__c, new Set<String>{ productUser.QueueName__c });
      }
    }
    return userMap;
  }

  private static List<Opportunity> getAssignedOpps(String recordTypeDevName) {
    String opportunityRecordTypeId = getRecordTypeId(recordTypeDevName);
    Set<String> stageNameAssignedSet = mapAssignedOppStages.get(recordTypeDevName);
    return [
      SELECT OwnerId
      FROM Opportunity
      WHERE RecordTypeId = :opportunityRecordTypeId AND CreatedDate = LAST_90_DAYS AND StageName IN :stageNameAssignedSet
      WITH SECURITY_ENFORCED
    ];
  }

  public static Map<String, List<Opportunity>> getOpportunitiesMap(Set<String> oppRecordTypeSet, Set<String> stageNameSet) {
    List<Opportunity> atWorkOpps = new List<Opportunity>();
    List<Opportunity> autoFinOpps = new List<Opportunity>();
    String atWorkRecordTypeId = getRecordTypeId(OpportunityAssignmentController.ATWORK);
    String autoFinRecordTypeId = getRecordTypeId(OpportunityAssignmentController.AUTOFIN);
    Map<String, Distribution_Settings__mdt> mapDateLimitMap = Distribution_Settings__mdt.getAll();
    Map<String, List<Opportunity>> recordTypeOppMap = new Map<String, List<Opportunity>>{ atWorkRecordTypeId => atWorkOpps, autoFinRecordTypeId => autoFinOpps };

    for (String oppRT : oppRecordTypeSet) {
      Datetime currentDT = Datetime.now();
      if (atWorkRecordTypeId == oppRT) {
        Datetime filteredDTAtWork = currentDT.addDays(getIntegerValue(mapDateLimitMap.get(OpportunityAssignmentController.ATWORK)?.NumberOfDays__c));
        atWorkOpps = getOppList(atWorkRecordTypeId, stageNameSet, filteredDTAtWork);
        recordTypeOppMap.put(atWorkRecordTypeId, atWorkOpps);
      } else if (autoFinRecordTypeId == oppRT) {
        Datetime filteredDTAutoFin = currentDT.addDays(getIntegerValue(mapDateLimitMap.get(OpportunityAssignmentController.AUTOFIN)?.NumberOfDays__c));
        autoFinOpps = getOppList(autoFinRecordTypeId, stageNameSet, filteredDTAutoFin);
        recordTypeOppMap.put(autoFinRecordTypeId, autoFinOpps);
      }
    }
    return recordTypeOppMap;
  }

  private static Integer getIntegerValue(Decimal input) {
    if (input == null) {
      return -30;
    }
    Integer output = -Integer.valueOf(input);
    return output;
  }

  private static List<Opportunity> getOppList(String recordTypeId, Set<String> stageNameSet, Datetime filteredDT) {
    return [
      SELECT Id, Name, AccountId, ExternalId__c, QueueName__c, PriorityPoints__c, RecordTypeId, CreatedDate, ExternalCreationDate__c, StageName, OwnerId
      FROM Opportunity
      WHERE RecordTypeId = :recordTypeId AND StageName IN :stageNameSet AND ExternalCreationDate__c >= :filteredDT
      WITH SECURITY_ENFORCED
      FOR UPDATE
    ];
  }

  public static List<Opportunity> getOpportunitiesSorted(List<Opportunity> lstOpportunity, String dateFilter) {
    List<Opportunity> lstOpportunitySorted = new List<Opportunity>();

    if (lstOpportunity.isEmpty()) {
      return lstOpportunitySorted;
    }

    List<OpportunityAtWorkComparable> lstOpptyComp = new List<OpportunityAtWorkComparable>();

    for (Opportunity opp : lstOpportunity) {
      lstOpptyComp.add(new OpportunityAtWorkComparable(opp, dateFilter));
    }

    lstOpptyComp.sort();

    for (OpportunityAtWorkComparable oppComp : lstOpptyComp) {
      lstOpportunitySorted.add(oppComp.oppty);
    }

    return lstOpportunitySorted;
  }

  public static void sendCustomNotification(List<Opportunity> oppToUpdateList) {
    Map<String, List<SObject>> mapTypeSObjectList = new Map<String, List<SObject>>{ 'Opportunity' => oppToUpdateList };
    CustomNotificationController.createCustomNotification(mapTypeSObjectList);
  }

  public static String getRecordTypeId(String recordTypeDevName) {
    return Util.getRecordTypeIdbyName('Opportunity', recordTypeDevName);
  }

  public static void fireEvent(List<Opportunity> oppList) {
    List<opportunityAssignment__e> eventList = new List<opportunityAssignment__e>();

    for (Opportunity opp : oppList) {
      opportunityAssignment__e e = new opportunityAssignment__e(ExternalId__c = opp.ExternalId__c, OwnerId__c = opp.OwnerId, StageName__c = opp.StageName);

      eventList.add(e);
    }

    Eventbus.publish(eventList);
  }
}