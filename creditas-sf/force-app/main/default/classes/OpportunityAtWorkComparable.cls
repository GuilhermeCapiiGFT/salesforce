/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe com método de ordenação para priorização de oportunidades de @Work. 
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       24/01/2021      Created     Criação da classe
 **********************************************************************************************************************/
public class OpportunityAtWorkComparable implements Comparable {
  public Opportunity oppty;

  String sortDateField;

  public OpportunityAtWorkComparable(Opportunity opp, String dtFilter) {
    this.oppty = opp;
    this.sortDateField = dtFilter == 'RequestDate' ? 'ExternalCreationDate__c' : 'CreatedDate';
  }

  public Integer compareTo(Object compareToObj) {
    OpportunityAtWorkComparable opptyToCompare = (OpportunityAtWorkComparable) compareToObj;

    Integer returnValue = 0;

    if (this.oppty.PriorityPoints__c > opptyToCompare.oppty.PriorityPoints__c) {
      returnValue = -1;
    } else if (this.oppty.PriorityPoints__c < opptyToCompare.oppty.PriorityPoints__c) {
      returnValue = 1;
    } else if (
      (Datetime) this.oppty.get(this.sortDateField) > (Datetime) opptyToCompare.oppty.get(this.sortDateField)
    ) {
      returnValue = 1;
    } else if (
      (Datetime) this.oppty.get(this.sortDateField) < (Datetime) opptyToCompare.oppty.get(this.sortDateField)
    ) {
      returnValue = -1;
    }

    return returnValue;
  }
}