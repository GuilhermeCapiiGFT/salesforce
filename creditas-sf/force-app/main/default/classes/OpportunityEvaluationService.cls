public with sharing class OpportunityEvaluationService {
  public static final String STAGENAME_NEW = 'Novo';
  public static final String STAGENAME_SIGNED = 'Contrato Assinado';
  public static final String STAGENAME_HR = 'Aprovado por RH';
  public static final String STAGENAME_PENDENCY_RETURN = 'Retorno de Pendência de Formalização';

  private static final String RECORD_TYPE_NAME_ATWORK = 'AtWork';

  public static String pendencyReturnApiName = CustomSetupController.getPendencyReturnApiName();

  private Map<String, Map<String, Double>> priorityPointsMap;

  private List<String> products;

  private List<Opportunity> opportunities;

  private List<Opportunity> changedOpportunities;

  private String query;

  public static Map<String, Map<String, Double>> createPriorityPointsMap(List<CustomQueue__c> customQueues) {
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

  public static List<Opportunity> filterOpportunitiesToEvaluate(List<Opportunity> opportunities) {
    List<Opportunity> resultOpportunities = new List<Opportunity>();

    for (Opportunity opportunity : opportunities) {
      if (TriggerHelper.changedToExpectedValue(opportunity, 'StageName', STAGENAME_PENDENCY_RETURN)) {
        resultOpportunities.add(opportunity);
      }
    }

    return resultOpportunities;
  }

  public OpportunityEvaluationService() {
    this.changedOpportunities = new List<Opportunity>();
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

  public void selectOpportunities() {
    this.query = getQueryString();
    if (String.isNotBlank(this.query)) {
      this.opportunities = Database.query(this.query);
    }
  }

  private String getQueryString() {
    if (priorityPointsMap.isEmpty()) {
      return '';
    }

    String soqlSelect = 'SELECT RecordTypeId, ProductType__c, StageName, PriorityPoints__c FROM Opportunity';
    String soqlWhere = '';

    for (String recordTypeName : priorityPointsMap.keySet()) {
      if (recordTypeName == RECORD_TYPE_NAME_ATWORK) {
        soqlWhere += getAtWorkQueryString();
      }
    }

    if (String.isNotBlank(soqlWhere)) {
      soqlWhere = soqlWhere.replaceFirst(' OR', ' WHERE');
      return soqlSelect + soqlWhere;
    }

    return '';
  }

  private String getAtWorkQueryString() {
    String recordTypeId = String.valueOf(Util.getRecordTypeIdbyName('Opportunity', RECORD_TYPE_NAME_ATWORK));
    List<String> stageNames = new List<String>{
      STAGENAME_NEW,
      STAGENAME_SIGNED,
      STAGENAME_HR,
      STAGENAME_PENDENCY_RETURN
    };

    String filterRecordTypeId = 'RecordTypeId = ' + StringUtils.singleQuoteThis(recordTypeId);

    String filterProductsCriteria = '';
    if (!this.products.isEmpty()) {
      filterProductsCriteria =
        ' AND (' +
        'ProductType__c IN (' +
        StringUtils.getSingleQuotedSeparatedValues(this.products, ',') +
        ')';

      if (this.products.contains(pendencyReturnApiName)) {
        filterProductsCriteria += ' OR StageName = ' + StringUtils.singleQuoteThis(STAGENAME_PENDENCY_RETURN);
      }

      filterProductsCriteria += ')';
    }

    String filterStageName = 'AND StageName IN (' + StringUtils.getSingleQuotedSeparatedValues(stageNames, ',') + ')';

    return ' OR (' + filterRecordTypeId + filterProductsCriteria + filterStageName + ')';
  }

  public void evaluateOpportunities() {
    if (this.priorityPointsMap == null || this.priorityPointsMap.isEmpty()) {
      return;
    }

    for (Opportunity opportunity : this.opportunities) {
      String opportunityRecordTypeName = Util.getRecordTypeDeveloperNameById('Opportunity', opportunity.RecordTypeId);
      if (this.priorityPointsMap.containsKey(opportunityRecordTypeName)) {
        opportunity.PriorityPoints__c = this.getPriorityPoints(opportunity, opportunityRecordTypeName);
        this.changedOpportunities.add(opportunity);
      }
    }
  }

  private Double getPriorityPoints(Opportunity opportunity, String recordTypeDevName) {
    Map<String, Double> pointsByProduct = this.priorityPointsMap.get(recordTypeDevName);
    String productType = opportunity.ProductType__c;

    Double priorityPoints = pointsByProduct.containsKey(productType) ? pointsByProduct.get(productType) : 0;

    if (opportunity.StageName == STAGENAME_PENDENCY_RETURN) {
      priorityPoints += pointsByProduct.get(pendencyReturnApiName);
    }

    return priorityPoints;
  }

  public void updateChangedOpportunities() {
    if (Trigger.isExecuting && Trigger.isAfter && !this.changedOpportunities.isEmpty()) {
      update this.changedOpportunities;
    }
  }
}