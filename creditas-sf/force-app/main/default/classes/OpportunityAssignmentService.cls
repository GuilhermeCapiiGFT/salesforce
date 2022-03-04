public with sharing class OpportunityAssignmentService {

    public static string opportunityRecordTypeDevName;
    private static String opportunityRecordTypeId;
    public static String stageNameFrom;
    public static String stageNameTo;
    public static String statusFormalizationFrom;
    public static Set<String> statusFormalizationSet;

    public static Boolean checkOpportunities(List<Opportunity> opportuntitiesInput){
      if(opportunityRecordTypeDevName == null || stageNameFrom == null || stageNameTo == null || statusFormalizationSet == null){
        throw new OpportunityAssignmentException('Please set up the variables for opportunityRecordTypeDevName, stageNameFrom, stageNameTo and statusFormalizationSet');
      }

      opportunityRecordTypeId = Util.getRecordTypeIdbyName('Opportunity', opportunityRecordTypeDevName);
      boolean runAssignment = false;
      for(Opportunity opp : opportuntitiesInput){
          
          if(opp.RecordTypeId == opportunityRecordTypeId && (TriggerHelper.changedFromTo(opp, 'Stagename', stageNameFrom, stageNameTo) || TriggerHelper.changedFrom(opp, 'FormalizationStatus__c', statusFormalizationFrom))){
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
          op.OwnerId = accountUserIdMap.get(op.AccountId);
          op.FormalizationStatus__c = OpportunityFormalizationStatus.AWAITING_ANALYSIS;
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
            op.OwnerId = selectedUserId;
            op.FormalizationStatus__c = OpportunityFormalizationStatus.AWAITING_ANALYSIS;
            lstOpptyToAssign.add(op);
            setUnavailableUsers.add(selectedUserId);
            accountUserIdMap.put(op.AccountId, selectedUserId);
        }
      }

      Cache.Org.put('local.atWorkAssignment.mapUserAccountId', accountUserIdMap, 43200, Cache.Visibility.ALL, false);
      
      if (lstOpptyToAssign.isEmpty()) { return lstOpptyToAssign; }

      return lstOpptyToAssign;
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
          Set<String> excludedStageNames = new Set<String>{'Assinatura','HR'};
          return [ 
            SELECT OwnerId
            FROM Opportunity
            WHERE RecordTypeId = :opportunityRecordTypeId AND
            CreatedDate = TODAY AND StageName NOT IN: excludedStageNames AND
            FormalizationStatus__c NOT IN :statusFormalizationSet
            WITH SECURITY_ENFORCED
          ];
            
          }

        private static List<Opportunity> getOpportunities() {
            
          return [ 
            SELECT Id, Name, AccountId, ProductType__c, PriorityPoints__c, RecordTypeId, PendencyReturn__c, 
            CreatedDate, ExternalCreationDate__c, StageName, FormalizationStatus__c, OwnerId
            FROM Opportunity
            WHERE RecordTypeId = :opportunityRecordTypeId AND
            StageName = :stageNameTo AND
            FormalizationStatus__c IN :statusFormalizationSet
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