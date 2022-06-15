public with sharing class OpportunityEvaluationService {
  public static final String STAGENAME_NEW = 'Novo';
  public static final String STAGENAME_APPROVED_BY_HR = 'Aprovado por RH';
  public static final String STAGENAME_PENDENCY_RETURN = 'Retorno de Pendência de Formalização';
  public static final String STAGENAME_SENT_COMMITTEE = 'Aguardando Distribuição para Comitê de Formalização';

  private static final String RECORDTYPENAME_ATWORK = 'AtWork';
  private static final String RECORDTYPENAME_AUTOFIN = 'AutoFin';

  private static String pendencyReturnApiName = CustomSetupController.getPendencyReturnApiName();
  private static String committeeApiName = CustomSetupController.getCommitteeApiName();

  private static Map<String, Set<String>> trackedStageNamesByRecordType = new Map<String, Set<String>>{
    RECORDTYPENAME_ATWORK => new Set<String>{ STAGENAME_NEW, STAGENAME_APPROVED_BY_HR, STAGENAME_PENDENCY_RETURN, STAGENAME_SENT_COMMITTEE },
    RECORDTYPENAME_AUTOFIN => new Set<String>{ STAGENAME_NEW, STAGENAME_PENDENCY_RETURN, STAGENAME_SENT_COMMITTEE }
  };

  private static Map<String, Set<String>> priorityStageNamesByRecordType = new Map<String, Set<String>>{
    RECORDTYPENAME_ATWORK => new Set<String>{ STAGENAME_PENDENCY_RETURN, STAGENAME_SENT_COMMITTEE },
    RECORDTYPENAME_AUTOFIN => new Set<String>{ STAGENAME_PENDENCY_RETURN, STAGENAME_SENT_COMMITTEE }
  };

  private Map<String, Set<String>> productsByRecordType;
  private List<Opportunity> opportunities;
  private List<Opportunity> changedOpportunities;
  private String query;

  public static List<Opportunity> getPriorityOpportunities(List<Opportunity> opportunities) {
    List<Opportunity> priorityOpportunities = new List<Opportunity>();

    for (Opportunity opportunity : opportunities) {
      if (isPriority(opportunity)) {
        priorityOpportunities.add(opportunity);
      }
    }

    return priorityOpportunities;
  }

  private static boolean isPriority(Opportunity opportunity) {
    String recordTypeName = Util.getRecordTypeDeveloperNameById('Opportunity', opportunity.RecordTypeId);
    if (priorityStageNamesByRecordType.containsKey(recordTypeName)) {
      for (String stageName : priorityStageNamesByRecordType.get(recordTypeName)) {
        if (TriggerHelper.changedToExpectedValue(opportunity, 'StageName', stageName)) {
          return true;
        }
      }
    }
    return false;
  }

  public OpportunityEvaluationService() {
    this.opportunities = new List<Opportunity>();
    this.changedOpportunities = new List<Opportunity>();
    this.productsByRecordType = new Map<String, Set<String>>();
  }

  public void setProducts(List<CustomQueue__c> customQueues) {
    this.productsByRecordType = new Map<String, Set<String>>();
    for (CustomQueue__c queue : customQueues) {
      String recordTypeName = Util.getRecordTypeDeveloperNameById('CustomQueue__c', queue.RecordTypeId);
      if (!this.productsByRecordType.containsKey(recordTypeName)) {
        this.productsByRecordType.put(recordTypeName, new Set<String>());
      }
      this.productsByRecordType.get(recordTypeName).add(queue.QueueName__c);
    }
  }

  public void setOpportunities(List<Opportunity> opportunities) {
    this.opportunities = opportunities;
  }

  public void evaluateOpportunities() {
    Map<String, Map<String, Double>> productPointsByRecordType = CustomSetupController.getProductPointsByRecordType();

    if (this.opportunities.isEmpty()) {
      this.selectOpportunities();
    }

    for (Opportunity opportunity : this.opportunities) {
      String recordTypeName = Util.getRecordTypeDeveloperNameById('Opportunity', opportunity.RecordTypeId);
      if (productPointsByRecordType.containsKey(recordTypeName)) {
        Map<String, Double> pointsByProduct = productPointsByRecordType.get(recordTypeName);
        opportunity.PriorityPoints__c = this.getPriorityPoints(opportunity, pointsByProduct);
        this.changedOpportunities.add(opportunity);
      }
    }
  }

  public void selectOpportunities() {
    this.query = getQueryString();
    if (String.isNotBlank(this.query)) {
      this.opportunities = Database.query(this.query);
    }
  }

  public String getQuery() {
    String query = getQueryString();
    return query;
  }

  private String getQueryString() {
    if (this.productsByRecordType.isEmpty()) {
      return '';
    }

    String soqlSelect = 'SELECT RecordTypeId, QueueName__c, StageName, PriorityPoints__c FROM Opportunity';
    String soqlWhere = '';

    for (String recordTypeName : this.productsByRecordType.keySet()) {
      soqlWhere += ' OR (' + this.getBuQueryString(recordTypeName) + ')';
    }

    if (String.isNotBlank(soqlWhere)) {
      soqlWhere = soqlWhere.replaceFirst(' OR', ' WHERE');
      return soqlSelect + soqlWhere;
    }

    return '';
  }

  private String getBuQueryString(String recordTypeName) {
    String recordTypeId = String.valueOf(Util.getRecordTypeIdbyName('Opportunity', recordTypeName));
    Set<String> stageNames = trackedStageNamesByRecordType.get(recordTypeName);
    Set<String> products = this.productsByRecordType.get(recordTypeName);

    String filterProducts = '';
    if (!products.isEmpty()) {
      filterProducts =
        ' AND (' +
        'QueueName__c IN (' +
        StringUtils.getSingleQuotedSeparatedValues(products, ',') +
        ')';

      if (products.contains(pendencyReturnApiName)) {
        filterProducts += ' OR StageName = ' + StringUtils.singleQuoteThis(STAGENAME_PENDENCY_RETURN);
      } 
      
      if (products.contains(committeeApiName)) {
        filterProducts += ' OR StageName = ' + StringUtils.singleQuoteThis(STAGENAME_SENT_COMMITTEE);
      }

      filterProducts += ')';
    }

    return 'RecordTypeId = ' +
      StringUtils.singleQuoteThis(recordTypeId) +
      ' AND StageName IN (' +
      StringUtils.getSingleQuotedSeparatedValues(stageNames, ',') +
      ')' +
      filterProducts;
  }

  private Double getPriorityPoints(Opportunity opportunity, Map<String, Double> pointsByProduct) {
    String productType = opportunity.QueueName__c;
    Double priorityPoints = pointsByProduct.containsKey(productType) ? pointsByProduct.get(productType) : 0;

    if (opportunity.StageName == STAGENAME_PENDENCY_RETURN) {
      priorityPoints += pointsByProduct.get(pendencyReturnApiName);
    } else if (opportunity.StageName == STAGENAME_SENT_COMMITTEE) {
      priorityPoints += pointsByProduct.get(committeeApiName);
    }

    return priorityPoints;
  }

  public void updateChangedOpportunities() {
    if (Trigger.isExecuting && Trigger.isAfter && !this.changedOpportunities.isEmpty()) {
      update this.changedOpportunities;
    }
  }
  public void updateChangedOpportunitiesBatch(){
    Database.update(this.changedOpportunities);
  }
}