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
    OpportunityAssignmentService.stageNameMap = new Map<String,String>{ 'stageNameFrom' => 'Contrato Assinado', 
                                                                        'stageNameTo' => 'Aprovado por RH',
                                                                        'stageNameFromPendency' => 'Pendenciado para Consultoria',
                                                                        'stageNameToPendency' => 'Retorno de Pendência de Formalização',
                                                                        'stageNameAwaitingAnalysis' => 'Aguardando Análise de Formalização',
                                                                        'stageNameUnderAnalysis' => 'Em Análise de Formalização'};
    runOpportunityAssignment(lstOpportunity);
  }

  private static void runOpportunityAssignment(List<Opportunity> lstOpportunity){

    Boolean runOpportunities = OpportunityAssignmentService.checkOpportunities(lstOpportunity);
    
    if(!runOpportunities) { return; }

    CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType(ATWORK);
      
    List<Opportunity> opportunitiesToAssign = OpportunityAssignmentService.getOpportunitiesSorted(customSetup.DateFilter__c);

    if(opportunitiesToAssign.isEmpty()) { return; }

    List<Opportunity> opportunitiesToUpdate = OpportunityAssignmentService.runOpportunityAssignment(opportunitiesToAssign, customSetup);
    
    if(opportunitiesToUpdate.isEmpty()){ return; }
    
    Database.update(opportunitiesToUpdate, false);

  }

  
}