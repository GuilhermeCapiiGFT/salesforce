/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe para atribuição de oportunidades de forma automática
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       25/01/2021      Created     Criação da classe
 * 2.0       Guilherme Sampaio       14/02/2022      Updated 
 **********************************************************************************************************************/
public with sharing class OpportunityAssignmentController {

  private static final String ATWORK = 'AtWork';

  public static void handleAtWorkOpportunityAssignment(List<Opportunity> lstOpportunity) {
    OpportunityAssignmentService.opportunityRecordTypeDevName = ATWORK;
    OpportunityAssignmentService.stageNameFrom = 'HR';
    OpportunityAssignmentService.stageNameTo = 'Formalização';
    OpportunityAssignmentService.statusFormalizationFrom = OpportunityFormalizationStatus.UNDER_ANALYSIS;
    OpportunityAssignmentService.statusFormalizationSet = new Set<String>{OpportunityFormalizationStatus.NEW_PROPOSAL};
    runOpportunityAssignment(lstOpportunity);
  }

  private static void runOpportunityAssignment(List<Opportunity> lstOpportunity){
    //checks if trigger should run assignments
    Boolean runOpportunities = OpportunityAssignmentService.checkOpportunities(lstOpportunity);
    
    if(!runOpportunities) { return; }

    CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType(ATWORK);
    //queries and sorts opportunity list based on parameters defined in the custom Setup
    List<Opportunity> opportunitiesToAssign = OpportunityAssignmentService.getOpportunitiesSorted(customSetup.DateFilter__c);

    if(opportunitiesToAssign.isEmpty()) { return; }

    //filters which opportunities should be updated from the list of all opportunities avaiable
    Map<Id,Opportunity> opportunitiesToUpdate = OpportunityAssignmentService.runOpportunityAssignment(opportunitiesToAssign, customSetup);
    
    if(opportunitiesToUpdate.isEmpty()){ return; }
    
    //returns a set of ids of opporturnities that were succesfully updated
    Set<Id> successOpportunityIdSet = OpportunityAssignmentService.updateOpportunities(opportunitiesToUpdate);

    if(successOpportunityIdSet.isEmpty()){ return; }
    
    //creates custom notifications for the set of id's passed to the method
    SendCustomNotificationController.SendCustomOpportunityNotification(successOpportunityIdSet);

  }

  
}