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
      stageNameSet.addAl(new List<String>{'Aprovado por RH','Retorno de Pendência de Formalização'});
    }

    if(runAutoFin){
      recordTypeIdSet.add(OpportunityAssignmentService.getRecordTypeId(AUTOFIN));
      stageNameSet.addAl(new List<String>{'Aprovado por RH','Retorno de Pendência de Formalização','Aguardando Distribuição de Comitê'});
    }
    
    if(runAtWork || runAutoFin){
      runOpportunityAssignment(runAtWork,runAutoFin);
    }
  }

  private static Boolean checkAtWorkAssignment(List<Opportunity> lstOpportunity) {
    OpportunityAssignmentService.opportunityRecordTypeDevName = ATWORK;
    OpportunityAssignmentService.stageNameMap = OpportunityAssignmentService.createStageNameMap(new List<String>{'Contrato Assinado', 'Aprovado por RH', 'Pendenciado para Consultoria', 'Retorno de Pendência de Formalização', 'Em Análise de Formalização', ''});
    return OpportunityAssignmentService.checkOpportunities(lstOpportunity);
    
  }

  private static Boolean checkAutoFinAssignment(List<Opportunity> lstOpportunity) {
    OpportunityAssignmentService.opportunityRecordTypeDevName = AUTOFIN;
    OpportunityAssignmentService.stageNameMap = OpportunityAssignmentService.createStageNameMap(new List<String>{'','','','','',''});
    return OpportunityAssignmentService.checkOpportunities(lstOpportunity);
  }

  private static void runOpportunityAssignment(Boolean atWork, Boolean autoFin){

    Map<String,List<Opportunity>> oppRecordTypeIdMap = OpportunityAssignmentService.getOpportunitiesMap(recordTypeIdSet, stageNameSet);

    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    if(atWork){
      opportunitiesToUpdate.addAll(runAssignment(oppRecordTypeIdMap.get(OpportunityAssignmentService.getRecordTypeId(ATWORK)), ATWORK));
    }

    if(autoFin){
      opportunitiesToUpdate.addAll(runAssignment(oppRecordTypeIdMap.get(OpportunityAssignmentService.getRecordTypeId(AUTOFIN)), AUTOFIN));
    }
   
    if(opportunitiesToUpdate.isEmpty()){ return; }
    
    Database.update(opportunitiesToUpdate, false);
  }
  
  private static List<Opportunity> runAssignment(List<Opportunity> oppsToSort, String recordTypeDevName){
    if(oppsToSort.isEmpty()) { return new List<Opportunity>(); }
    CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType(recordTypeDevName);
    List<Opportunity> sortedOpps = OpportunityAssignmentService.getOpportunitiesSorted(oppsToSort,customSetup.DateFilter__c);
    return OpportunityAssignmentService.assignOpportunities(sortedOpps, customSetup, recordTypeDevName);
  }  
}