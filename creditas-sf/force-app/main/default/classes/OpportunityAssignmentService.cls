public with sharing class OpportunityAssignmentService {

    public static string opportunityRecordTypeDevName;
    private static String opportunityRecordTypeId;
    public static Map<String,String> stageNameMap;
    
    public static Boolean checkOpportunities(List<Opportunity> opportuntitiesInput){
      if(opportunityRecordTypeDevName == null || stageNameMap == null || stageNameMap.isEmpty() || stageNameMap.size() < 6){
        throw new OpportunityAssignmentException('Please set up the variables for opportunityRecordTypeDevName and fill the stageNameMap with the required variables: stageNameFrom, stageNameTo, stageNameFromPendency, stageNameToPendency, stageNameAwaitingAnalysis and stageNameUnderAnalysis');
      }

      opportunityRecordTypeId = Util.getRecordTypeIdbyName('Opportunity', opportunityRecordTypeDevName);
      boolean runAssignment = false;
      for(Opportunity opp : opportuntitiesInput){
        
          if(opp.RecordTypeId == opportunityRecordTypeId && 
                                  
                                ( TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFrom'), stageNameMap.get('stageNameTo')) ||
                                  
                                  TriggerHelper.changedFromTo(opp, 'Stagename', stageNameMap.get('stageNameFromPendency'), stageNameMap.get('stageNameToPendency')) ||
                                  
                                  TriggerHelper.changedFrom(opp, 'Stagename', stageNameMap.get('stageNameUnderAnalysis')))){
              runAssignment = true;
              break;
          }
      }
      
      return runAssignment;
    }

    public static List<Opportunity> runOpportunityAssignment(List<Opportunity> inputOppList, CustomSetup__c cSetup) {

      List<Opportunity> lstOpptyToAssign = new List<Opportunity>();
      
      if (cSetup.ProductAssignedUsers__r.isEmpty() || inputOppList.isEmpty()) { return lstOpptyToAssign; }

      Set<Id> setUnavailableUsers = getUnavailableUsers(getAssignedOpps(), cSetup.ProductAssignedUsers__r);
      
      Map<String, List<Id>> mapUsersByProductType = createMapUsersByProductType(cSetup.ProductAssignedUsers__r);
      
      Map<String,String> accountUserIdMap = (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId') == null ? new Map<String,String>() : (Map<String,String>) Cache.Org.getPartition('local.atWorkAssignment').get('mapUserAccountId');
 
      for (Opportunity op : inputOppList) {
        
        if(accountUserIdMap.containsKey(op.AccountId)){
          setOppFields(op, accountUserIdMap.get(op.AccountId), stageNameMap.get('stageNameAwaitingAnalysis'));
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
            setOppFields(op, selectedUserId, stageNameMap.get('stageNameAwaitingAnalysis'));
            lstOpptyToAssign.add(op);
            setUnavailableUsers.add(selectedUserId);
            accountUserIdMap.put(op.AccountId, selectedUserId);
        }
      }

      Cache.Org.put('local.atWorkAssignment.mapUserAccountId', accountUserIdMap, 43200, Cache.Visibility.ALL, false);
      
      if (lstOpptyToAssign.isEmpty()) { return lstOpptyToAssign; }

      return lstOpptyToAssign;
    }

    private static void setOppFields(Opportunity opportunity, Id ownerId, String stageName){
        opportunity.OwnerId = ownerId;
        opportunity.StageName = stageName;
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

        private static List<Opportunity> getAssignedOpps() {
          Set<String> stageNameAssignedSet = new Set<String>{stageNameMap.get('stageNameAwaitingAnalysis'),stageNameMap.get('stageNameUnderAnalysis')};
          return [  SELECT OwnerId
                    FROM Opportunity
                    WHERE RecordTypeId = :opportunityRecordTypeId AND
                    CreatedDate = THIS_WEEK AND StageName IN :stageNameAssignedSet
                    WITH SECURITY_ENFORCED ];
          }

        private static List<Opportunity> getOpportunities() {
          Set<String> stageNameSet = new Set<String>{stageNameMap.get('stageNameTo'), stageNameMap.get('stageNameToPendency')};
          return [ 
            SELECT Id, Name, AccountId, ProductType__c, PriorityPoints__c, RecordTypeId, 
            CreatedDate, ExternalCreationDate__c, StageName, OwnerId
            FROM Opportunity
            WHERE RecordTypeId = :opportunityRecordTypeId AND
            StageName IN :stageNameSet
            WITH SECURITY_ENFORCED
            FOR UPDATE
          ];
            
          }

        public static List<Opportunity> getOpportunitiesSorted(String dateFilter) {
            List<Opportunity> lstOpportunity = getOpportunities();
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
}