/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Opportunity evaluation - set opportunity priority based on setup record at CustomSetup__c
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       15/02/2021      Created     Class creation
 **********************************************************************************************************************/
public with sharing class OpportunityEvaluationService {
  private static final String RECORD_TYPE_NAME_ATWORK = 'AtWork';

  public static String pendencyReturnApiName = CustomSetupController.getPendencyReturnApiName();

  private Map<String, Map<String, Double>> priorityPointsMap;

  private List<String> products;

  private List<Opportunity> opportunities;

  private List<Opportunity> changedOpportunitites;

  private String lastQuery;

  public static Map<String, Map<String, Double>> getProducts(List<CustomQueue__c> customQueues) {
    Map<String, Map<String, Double>> productsByRecordTypeName = new Map<String, Map<String, Double>>();

    for (CustomQueue__c cQueue : customQueues) {
      String recordTypeName = cQueue.CustomSetup__r.RecordType.DeveloperName;
      String product = cQueue.ProductType__c;
      Double points = cQueue.Points__c;

      if (productsByRecordTypeName.containsKey(recordTypeName)) {
        productsByRecordTypeName.get(recordTypeName).put(product, points);
      } else {
        productsByRecordTypeName.put(recordTypeName, new Map<String, Double>{ product => points });
      }
    }

    return productsByRecordTypeName;
  }

  public OpportunityEvaluationService() {
    this.changedOpportunitites = new List<Opportunity>();
    this.products = new List<String>();
  }

  public void setPriorityPointsMap(Map<String, Map<String, Double>> priorityPointsMap) {
    this.priorityPointsMap = priorityPointsMap;
  }

  public void setProducts(List<CustomQueue__c> processingCustomQueues) {
    this.products = new List<String>();
    for (CustomQueue__c cQueue : processingCustomQueues) {
      products.add(cQueue.ProductType__c);
    }
  }

  public void setOpportunities(List<Opportunity> opportunities) {
    this.opportunities = opportunities;
  }

  public List<Opportunity> getChangedOpportunities() {
    return this.changedOpportunitites;
  }

  public void selectOpportunities() {
    this.lastQuery = getQueryString();
    if (String.isNotBlank(this.lastQuery)) {
      this.opportunities = Database.query(this.lastQuery);
    }
  }

  private String getQueryString() {
    if (priorityPointsMap.isEmpty()) {
      return '';
    }

    String soqlSelect = 'SELECT RecordTypeId, ProductType__c, PendencyReturn__c, PriorityPoints__c FROM Opportunity';
    String soqlWhere = '';

    for (String recordTypeName : priorityPointsMap.keySet()) {

      if (recordTypeName == RECORD_TYPE_NAME_ATWORK) {
        soqlWhere += getAtWorkQueryCriteria();
      }
    }

    if (String.isNotBlank(soqlWhere)) {
      soqlWhere = soqlWhere.replaceFirst(' OR', ' WHERE');
      return soqlSelect + soqlWhere;
    }

    return '';
  }

  private String getAtWorkQueryCriteria() {
    String recordTypeId = String.valueOf(Util.getRecordTypeIdbyName('Opportunity', RECORD_TYPE_NAME_ATWORK));
    String newProposal = OpportunityFormalizationStatus.NEW_PROPOSAL;
    String awaitingAnalysis = OpportunityFormalizationStatus.AWAITING_ANALYSIS;

    String filterProductsCriteria = '';
    if (!this.products.isEmpty()) {
      filterProductsCriteria =
        'ProductType__c IN (' +
        StringUtils.getSingleQuotedSeparatedValues(this.products, ',') +
        ')';

      if (this.products.contains(pendencyReturnApiName)) {
        filterProductsCriteria += ' OR PendencyReturn__c = TRUE';
      }
    }

    return ' OR (RecordTypeId = ' +
      StringUtils.singleQuoteThis(recordTypeId) +
      ' AND (' +
      filterProductsCriteria +
      ')' +
      ' AND (FormalizationStatus__c = ' +
      StringUtils.singleQuoteThis(newProposal) +
      ' OR (PendencyReturn__c = TRUE' +
      ' AND FormalizationStatus__c IN (' +
      StringUtils.getSingleQuotedSeparatedValues(new List<String>{ newProposal, awaitingAnalysis }, ',') +
      +'))))';
  }

  public void evaluateOpportunities() {
    if (this.priorityPointsMap == null || this.priorityPointsMap.isEmpty()) {
      return;
    }

    for (Opportunity opp : this.opportunities) {
      String opportunityRecordTypeName = Util.getRecordTypeDeveloperNameById('Opportunity', opp.RecordTypeId);
      if (this.priorityPointsMap.containsKey(opportunityRecordTypeName)) {
        opp.PriorityPoints__c = this.getPriorityPoints(opp, opportunityRecordTypeName);
        this.changedOpportunitites.add(opp);
      }
    }
  }

  private Double getPriorityPoints(Opportunity opportunity, String recordTypeDevName) {
    Map<String, Double> pointsByProduct = this.priorityPointsMap.get(recordTypeDevName);
    String productType = opportunity.ProductType__c;

    Double priorityPoints = pointsByProduct.containsKey(productType) ? pointsByProduct.get(productType) : 0;

    if (opportunity.PendencyReturn__c) {
      priorityPoints += pointsByProduct.get(pendencyReturnApiName);
    }

    return priorityPoints;
  }
}
