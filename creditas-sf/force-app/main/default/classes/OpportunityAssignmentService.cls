public with sharing class OpportunityAssignmentService {

    private static final String AWAITING_FORMALIZATION_ANALYSIS = 'Aguardando Análise de Formalização';
    private static final String UNDER_FORMALIZATION_ANALYSIS = 'Em Análise de Formalização';
    private static final String AWAITING_COMITEE = 'Aguardando Distribuição de Comitê';
    private static final String AWAITING_COMITEE_ANALYSIS = 'Aguardando Análise de Comitê';

    public static string opportunityRecordTypeDevName;
    public static Map<String,String> stageNameMap;

    private static Map<String, Set<String>> mapAssignedOppStages;
    private static Map<String,String> mapStagesToSet = new Map<String,String>();

    public static Boolean saveToCache = false;

    public static Map<String,String> createStageNameMap(List<String> stageNameList){

      Map<String,String> stageMap = new Map<String,String>{ 'stageNameFrom' => stageNameList.remove(0), 
                                                            'stageNameTo' => stageNameList.remove(0),
                                                            'stageNameFromPendency' => stageNameList.remove(0),
                                                            'stageNameToPendency' => stageNameList.remove(0),
                                                            'stageNameUnderAnalysis' => stageNameList.remove(0),
                                                            'stageNameCommiteeAnalysis' => stageNameList.remove(0)};

      mapAssignedOppStages = new Map<String,Set<String>>{
        'AtWork' => new Set<String>{AWAITING_FORMALIZATION_ANALYSIS,UNDER_FORMALIZATION_ANALYSIS},
        'AutoFin' => new Set<String>{AWAITING_FORMALIZATION_ANALYSIS,UNDER_FORMALIZATION_ANALYSIS,AWAITING_COMITEE_ANALYSIS}
      };

      mapStagesToSet = new Map<String,String>{
        'Aprovado por RH' => AWAITING_FORMALIZATION_ANALYSIS,
        'Retorno de Pendência de Formalização' => AWAITING_FORMALIZATION_ANALYSIS,
        AWAITING_COMITEE => AWAITING_COMITEE_ANALYSIS
      };

      return stageMap;
    }
    
    public static Boolean checkOpportunities(List<Opportunity> opportuntitiesInput){
      if(opportunityRecordTypeDevName == null || stageNameMap == null || stageNameMap.isEmpty()){
        throw new OpportunityAssignmentException('Please set up the variables for opportunityRecordTypeDevName and fill the stageNameMap with the required variables');
      }

      String oppRecordType = getRecordTypeId(opportunityRecordTypeDevName);
      boolean runAssignment = false;
      for(Opportunity opp : opportuntitiesInput){
        
          if(opp.RecordTypeId == oppRecordType &&
                                ( TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFrom'), stageNameMap.get('stageNameTo')) ||
                                  TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFromPendency'), stageNameMap.get('stageNameToPendency')) ||
                                  TriggerHelper.changedFrom(opp, 'Stagename', stageNameMap.get('stageNameUnderAnalysis')) ||
                                  TriggerHelper.changedFrom(opp, 'Stagename', stageNameMap.get('stageNameCommiteeAnalysis')) )){
              runAssignment = true;
              break;
          }
      }
      
      return runAssignment;
    }

    public static List<Opportunity> assignOpportunities(List<Opportunity> inputOppList, CustomSetup__c cSetup, String recordTypeDevName) {

      List<Opportunity> lstOpptyToAssign = new List<Opportunity>();
      
      if (cSetup.ProductAssignedUsers__r.isEmpty() || inputOppList.isEmpty()) { return lstOpptyToAssign; }

      Set<Id> setUnavailableUsers = getUnavailableUsers(getAssignedOpps(recordTypeDevName), cSetup.ProductAssignedUsers__r);
      
      Map<String, List<Id>> mapUsersByProductType = createMapUsersByProductType(cSetup.ProductAssignedUsers__r);
      
      Map<String,String> accountUserIdMap = new Map<String,String>();

      if(OpportunityAssignmentController.ATWORK == recordTypeDevName || OpportunityAssignmentController.AUTOFIN == recordTypeDevName){
        accountUserIdMap = (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get(recordTypeDevName+'UserAccountIdMap') == null ? new Map<String,String>() : (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get(recordTypeDevName+'UserAccountIdMap');
      } 
 
      for (Opportunity op : inputOppList) {
        
        if(!op.StageName.contains('Comitê') && accountUserIdMap.containsKey(op.AccountId)){
          setOppFields(op, accountUserIdMap.get(op.AccountId));
          lstOpptyToAssign.add(op);
          setUnavailableUsers.add(accountUserIdMap.get(op.AccountId));
          continue;
        }
        
        if (mapUsersByProductType.isEmpty()) { break; }

        List<Id> lstProductTypeUsers = mapUsersByProductType.get(op.ProductType__c);
        
        if (lstProductTypeUsers == null || lstProductTypeUsers.isEmpty()) {
            mapUsersByProductType.remove(op.ProductType__c);
            continue;
        }

        Id selectedUserId;
        
        for (Integer i = 0; i < lstProductTypeUsers.size(); i++) {
            Id userId = lstProductTypeUsers.get(i);

            if (setUnavailableUsers.contains(userId)) { continue; }

            selectedUserId = userId;
            mapUsersByProductType.get(op.ProductType__c).remove(i);
            break;
        }
        
        if (selectedUserId != null) {
            setOppFields(op, selectedUserId);
            lstOpptyToAssign.add(op);
            setUnavailableUsers.add(selectedUserId);
            if(!op.StageName.contains('Comitê')){
              accountUserIdMap.put(op.AccountId, selectedUserId);
            }
        }
      }

      if(OpportunityAssignmentController.ATWORK == recordTypeDevName || OpportunityAssignmentController.AUTOFIN == recordTypeDevName){
        Cache.Org.put('local.atWorkAssignment.'+recordTypeDevName+'UserAccountIdMap', accountUserIdMap, 43200, Cache.Visibility.ALL, false);
      }       
      
      if (lstOpptyToAssign.isEmpty()) { return lstOpptyToAssign; }

      return lstOpptyToAssign;
    }

    private static void setOppFields(Opportunity opportunity, Id ownerId){
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
    
    private static Map<String, List<Id>> createMapUsersByProductType(List<ProductAssignedUser__c> lstProductUser) {
        Map<String, Set<Id>> mapSetUsersByProductType = new Map<String, Set<Id>>();

        for (ProductAssignedUser__c productUser : lstProductUser) {
          if (mapSetUsersByProductType.containsKey(productUser.ProductType__c)) {
            mapSetUsersByProductType.get(productUser.ProductType__c).add(productUser.User__c);
          } else {
            mapSetUsersByProductType.put(productUser.ProductType__c, new Set<Id>{ productUser.User__c });
          }
        }

        Map<String, List<Id>> mapListUsersByProductType = new Map<String, List<Id>>();

        for (String prodType : mapSetUsersByProductType.keySet()) {
            mapListUsersByProductType.put(prodType, new List<Id>(mapSetUsersByProductType.get(prodType)));
        }

        return mapListUsersByProductType;
    }

    private static List<Opportunity> getAssignedOpps(String recordTypeDevName) {
      String opportunityRecordTypeId = getRecordTypeId(recordTypeDevName);
      Set<String> stageNameAssignedSet = mapAssignedOppStages.get(recordTypeDevName);
      return [  SELECT OwnerId
                FROM Opportunity
                WHERE RecordTypeId = :opportunityRecordTypeId AND
                CreatedDate = THIS_WEEK AND StageName IN :stageNameAssignedSet
                WITH SECURITY_ENFORCED ];
      }

    public static Map<String,List<Opportunity>> getOpportunitiesMap(Set<String> oppRecordTypeSet, Set<String> stageNameSet) {
      List<Opportunity> atWorkOpps = new List<Opportunity>();
      List<Opportunity> autoFinOpps = new List<Opportunity>();
      String atWorkRecordTypeId = getRecordTypeId(OpportunityAssignmentController.ATWORK);
      String autoFinRecordTypeId = getRecordTypeId(OpportunityAssignmentController.AUTOFIN);
      Map<String,List<Opportunity>> recordTypeOppMap = new Map<String,List<Opportunity>>{atWorkRecordTypeId => atWorkOpps, autoFinRecordTypeId => autoFinOpps};

      for(Opportunity opportunity : [ SELECT Id, Name, AccountId, ProductType__c, PriorityPoints__c, RecordTypeId, CreatedDate, ExternalCreationDate__c, StageName, OwnerId
                                      FROM Opportunity
                                      WHERE RecordTypeId IN :oppRecordTypeSet AND
                                      StageName IN :stageNameSet
                                      WITH SECURITY_ENFORCED
                                      FOR UPDATE
                                    ]){
          if(atWorkRecordTypeId == opportunity.RecordTypeId){
            atWorkOpps.add(opportunity);
          } else if (autoFinRecordTypeId == opportunity.RecordTypeId){
            autoFinOpps.add(opportunity);
          }
      }

      if(oppRecordTypeSet.contains(atWorkRecordTypeId)){
        recordTypeOppMap.put(atWorkRecordTypeId,atWorkOpps);
      } else if(oppRecordTypeSet.contains(autoFinRecordTypeId)){
        recordTypeOppMap.put(autoFinRecordTypeId,autoFinOpps);
      }

      return recordTypeOppMap;  
    }

    public static List<Opportunity> getOpportunitiesSorted(List<Opportunity> lstOpportunity, String dateFilter) {
        List<Opportunity> lstOpportunitySorted = new List<Opportunity>();
    
        if (lstOpportunity.isEmpty()) { return lstOpportunitySorted; }

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

    public static String getRecordTypeId(String recordTypeDevName){
      return Util.getRecordTypeIdbyName('Opportunity', recordTypeDevName);
    }
}