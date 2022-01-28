/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Classe de testes da classe OpportunityAtWorkComparable
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       24/01/2021      Created     Criação da classe
 **********************************************************************************************************************/
@isTest
private class OpportunityAtWorkComparableTest {
  static DateTime firstDttm = Datetime.newInstance(2021, 1, 1, 1, 0, 0);
  static DateTime secondDttm = firstDttm.addSeconds(1);
  static Id accountId;

  @TestSetup
  static void makeData() {
    Account acc = AccountSetup.createAccount('Comparable Test Account', 'Pessoa_Fisica');

    insert acc;

    accountId = acc.Id;
  }

  @isTest
  static void runExternalDateSort() {
    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(new Opportunity(Name = 'A', PriorityPoints__c = 10, ExternalCreationDate__c = firstDttm));
    lstOppty.add(new Opportunity(Name = 'B', PriorityPoints__c = 11, ExternalCreationDate__c = firstDttm));
    lstOppty.add(new Opportunity(Name = 'C', PriorityPoints__c = 12, ExternalCreationDate__c = firstDttm));
    lstOppty.add(new Opportunity(Name = 'D', PriorityPoints__c = 10, ExternalCreationDate__c = secondDttm));
    lstOppty.add(new Opportunity(Name = 'E', PriorityPoints__c = 11, ExternalCreationDate__c = secondDttm));
    lstOppty.add(new Opportunity(Name = 'F', PriorityPoints__c = 12, ExternalCreationDate__c = secondDttm));

    List<OpportunityAtWorkComparable> lstOpptyComp = new List<OpportunityAtWorkComparable>();

    for (Opportunity op : lstOppty) {
      lstOpptyComp.add(new OpportunityAtWorkComparable(op, 'Data de Solicitação'));
    }

    lstOpptyComp.sort();

    System.assertEquals('C', lstOpptyComp[0].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('F', lstOpptyComp[1].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('B', lstOpptyComp[2].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('E', lstOpptyComp[3].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('A', lstOpptyComp[4].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('D', lstOpptyComp[5].oppty.Name, 'Opportunity sort failed');
  }

  @isTest
  static void runInternalDateSort() {
    Date closeDate = Date.today() + 10;

    List<Opportunity> lstOppty = new List<Opportunity>();
    lstOppty.add(new Opportunity(Name = 'A', PriorityPoints__c = 10, StageName = 'Novo', CloseDate = closeDate));
    lstOppty.add(new Opportunity(Name = 'B', PriorityPoints__c = 11, StageName = 'Novo', CloseDate = closeDate));
    lstOppty.add(new Opportunity(Name = 'C', PriorityPoints__c = 12, StageName = 'Novo', CloseDate = closeDate));

    insert lstOppty;

    lstOppty = [
      SELECT Name, PriorityPoints__c, CreatedDate, ExternalCreationDate__c
      FROM Opportunity
      WHERE Name IN ('A', 'B', 'C')
    ];

    List<OpportunityAtWorkComparable> lstOpptyComp = new List<OpportunityAtWorkComparable>();

    for (Opportunity op : lstOppty) {
      lstOpptyComp.add(new OpportunityAtWorkComparable(op, 'Data de Criação'));
    }

    lstOpptyComp.sort();

    System.assertEquals('C', lstOpptyComp[0].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('B', lstOpptyComp[1].oppty.Name, 'Opportunity sort failed');
    System.assertEquals('A', lstOpptyComp[2].oppty.Name, 'Opportunity sort failed');
  }
}