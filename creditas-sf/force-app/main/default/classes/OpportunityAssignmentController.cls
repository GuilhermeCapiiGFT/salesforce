public with sharing class OpportunityAssignmentController {

  public static final String ATWORK = 'AtWork';
  public static final String AUTOFIN = 'AutoFin';
  private static Set<String> recordTypeIdSet = new Set<String>();
  private static Set<String> stageNameSet = new Set<String>();

  public static void handleOpportunitiesAssignment(List<Opportunity> lstOpportunity){
    Boolean runAtWork = checkAtWorkAssignment(lstOpportunity);
    Boolean runAutoFin = checkAutoFinAssignment(lstOpportunity);

    if(runAtWork){
      recordTypeIdSet.add(OpportunityAssignmentService.getRecordTypeId(ATWORK));
      stageNameSet.addAll(new List<String>{OpportunityAssignmentService.APPROVED_BY_HR,OpportunityAssignmentService.FORMALIZATION_PENDENCY_RETURN});
    }

    if(runAutoFin){
      recordTypeIdSet.add(OpportunityAssignmentService.getRecordTypeId(AUTOFIN));
      stageNameSet.addAll(new List<String>{OpportunityAssignmentService.AWAITING_FORMALIZATION_ASSIGNMENT,OpportunityAssignmentService.FORMALIZATION_PENDENCY_RETURN,OpportunityAssignmentService.AWAITING_COMITEE_ASSIGNMENT});
    }
    
    if(runAtWork || runAutoFin){
      runOpportunityAssignment(runAtWork,runAutoFin);
    }
  }

  private static Boolean checkAtWorkAssignment(List<Opportunity> lstOpportunity) {
    OpportunityAssignmentService.opportunityRecordTypeDevName = ATWORK;
    OpportunityAssignmentService.stageNameMap = OpportunityAssignmentService.createStageNameMap(
                                                new List<String>{ OpportunityAssignmentService.NEW_OPP, 
                                                                  OpportunityAssignmentService.APPROVED_BY_HR, 
                                                                  OpportunityAssignmentService.CONSULTING_PENDENCY, 
                                                                  OpportunityAssignmentService.FORMALIZATION_PENDENCY_RETURN, 
                                                                  OpportunityAssignmentService.UNDER_FORMALIZATION_ANALYSIS, 
                                                                  ''  });

    return OpportunityAssignmentService.checkOpportunities(lstOpportunity);
    
  }

  private static Boolean checkAutoFinAssignment(List<Opportunity> lstOpportunity) {
    OpportunityAssignmentService.opportunityRecordTypeDevName = AUTOFIN;
    OpportunityAssignmentService.stageNameMap = OpportunityAssignmentService.createStageNameMap(
                                                new List<String>{ OpportunityAssignmentService.NEW_OPP,
                                                                  OpportunityAssignmentService.AWAITING_FORMALIZATION_ASSIGNMENT,
                                                                  OpportunityAssignmentService.AWAITING_FORMALIZATION_ASSIGNMENT,
                                                                  OpportunityAssignmentService.FORMALIZATION_PENDENCY_RETURN,
                                                                  OpportunityAssignmentService.UNDER_FORMALIZATION_ANALYSIS,
                                                                  OpportunityAssignmentService.UNDER_COMMITEE_ANALYSIS  });
    return OpportunityAssignmentService.checkOpportunities(lstOpportunity);
  }

  private static void runOpportunityAssignment(Boolean runAtWork, Boolean runAutoFin){

    Map<String,List<Opportunity>> oppRecordTypeIdMap = OpportunityAssignmentService.getOpportunitiesMap(recordTypeIdSet, stageNameSet);

    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    if(runAtWork){
      opportunitiesToUpdate.addAll(runAssignment(oppRecordTypeIdMap.get(OpportunityAssignmentService.getRecordTypeId(ATWORK)), ATWORK));
    }

    if(runAutoFin){
      opportunitiesToUpdate.addAll(runAssignment(oppRecordTypeIdMap.get(OpportunityAssignmentService.getRecordTypeId(AUTOFIN)), AUTOFIN));
    }
   
    if(opportunitiesToUpdate.isEmpty()){ return; }
    OpportunityAssignmentService.sendCustomNotification(opportunitiesToUpdate);
    System.debug(opportunitiesToUpdate);
    OpportunityAssignmentService.fireEvent(opportunitiesToUpdate);
    //Database.update(opportunitiesToUpdate, false);
  }
  
  private static List<Opportunity> runAssignment(List<Opportunity> oppsToSort, String recordTypeDevName){
    if(oppsToSort.isEmpty()) { return new List<Opportunity>(); }
    CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType(recordTypeDevName);
    List<Opportunity> sortedOpps = OpportunityAssignmentService.getOpportunitiesSorted(oppsToSort,customSetup.DateFilter__c);
    return OpportunityAssignmentService.assignOpportunities(sortedOpps, customSetup, recordTypeDevName);
  }  
}