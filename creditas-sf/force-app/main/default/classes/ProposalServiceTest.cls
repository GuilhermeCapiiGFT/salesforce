@isTest
public with sharing class ProposalServiceTest {

    @TestSetup
    static void makeData()
    {
        Account accCustomer               = TestSetup.getAccount('Nivaele', false);
        accCustomer.NetWorthLowerLimit__c = 20000;
        accCustomer.NetWorthUpperLimit__c = 30000;
        accCustomer.DocumentNumber__c     = '51479566039';
        accCustomer.BankName__c           = 'test bank principal';
        accCustomer.Agency__c             = '00001'; 
        accCustomer.BankAccountNumber__c  = '01020304';
        accCustomer.RecordTypeId          = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        insert accCustomer;

        Account accRole              = TestSetup.getAccount('Account_Role', false);
        accRole.DocumentNumber__c    = '12047477000101';
        accRole.BankName__c          = 'test bank collateral guarantor';
        accRole.Agency__c            = '12345'; 
        accRole.BankAccountNumber__c = '0123456'; 
        accRole.RecordTypeId         = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        insert accRole;

        Opportunity opportunity              = new Opportunity();
        opportunity.AccountId                = accCustomer.Id;
        opportunity.MinimalRequiredIncome__c = 3000;
        opportunity.Name                     = 'Formalizacao Autofin';
        opportunity.StageName                = 'Em Análise de Formalização';
        opportunity.CloseDate                = Date.today().addDays(10);
        opportunity.ExternalTenant__c        = 'creditasbr';
        opportunity.ExternalVersion__c       = 1;      
        opportunity.RecordTypeId             = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        insert opportunity;

        ProfessionalInfo__c professionalInfo = new ProfessionalInfo__c();
        professionalInfo.Account__c          = accCustomer.Id;
        professionalInfo.Status__c           = 'CLT';
        professionalInfo.JobTitle__c         = 'Engenheiro';
        insert professionalInfo;

        OpportunityRole__c oppRoleGuarantor = TestSetup.getOppRole(accRole, opportunity, 'COLLATERAL_GUARANTOR', false, true); 
        OpportunityRole__c oppRolePrincipal = TestSetup.getOppRole(accCustomer, opportunity, 'PRINCIPAL', true, true);   

        FinancialResources__c finResource = FinancialResourceSetup.createFinancialResource('Auto');
        finResource.ManufacturingYear__c = '2022';
        finResource.Amount__c = 10000;
        finResource.Type__c = 'CAR';
        insert finResource;

        FinancialResources__c monthlyIncome = new FinancialResources__c();
        monthlyIncome.RecordTypeId          = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');
        monthlyIncome.Type__c               = 'MONTHLY_INCOME';
        monthlyIncome.Amount__c             = 5000;
        insert monthlyIncome;

        FinancialResources__c confirmedMonthlyIncome = new FinancialResources__c();
        confirmedMonthlyIncome.RecordTypeId          = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');
        confirmedMonthlyIncome.Type__c               = 'CONFIRMED_MONTHLY_INCOME';
        confirmedMonthlyIncome.Amount__c             = 4500;
        insert confirmedMonthlyIncome;

        FinancialResources__c presumedMonthlyIncome = new FinancialResources__c();
        presumedMonthlyIncome.RecordTypeId          = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');
        presumedMonthlyIncome.Type__c               = 'PRESUMED_MONTHLY_INCOME';
        presumedMonthlyIncome.Amount__c             = 4800;
        insert presumedMonthlyIncome;

        AccountFinancialRelationship__c accFinRel1 = new AccountFinancialRelationship__c();
        accFinRel1.Account__c                      = accCustomer.Id;
        accFinRel1.Recurso_Financeiro__c           = monthlyIncome.Id;
        insert accFinRel1;

        AccountFinancialRelationship__c accFinRel2 = new AccountFinancialRelationship__c();
        accFinRel2.Account__c                      = accCustomer.Id;
        accFinRel2.Recurso_Financeiro__c           = presumedMonthlyIncome.Id;
        insert accFinRel2;

        AccountFinancialRelationship__c accFinRel3 = new AccountFinancialRelationship__c();
        accFinRel3.Account__c                      = accCustomer.Id;
        accFinRel3.Recurso_Financeiro__c           = confirmedMonthlyIncome.Id;
        insert accFinRel3;

        IncomeDataSection__c incomeDataSection              = new IncomeDataSection__c();
        incomeDataSection.Opportunity__c                    = opportunity.Id;
        incomeDataSection.ProfessionalSituationStatus__c    = 'Aprovar';
        incomeDataSection.ProfessionStatus__c               = 'Aprovar';
        incomeDataSection.NetWorthStatus__c                 = 'Aprovar';
        incomeDataSection.MonthlyIncomeStatus__c            = 'Aprovar';
        incomeDataSection.MinimalRequiredIncomeStatus__c    = 'Aprovar';
        incomeDataSection.PresumedMonthlyIncomeStatus__c    = 'Aprovar';
        incomeDataSection.ConfirmedMonthlyIncomeStatus__c   = 'Aprovar';
        insert incomeDataSection;

        Garantias__c guarantee = new Garantias__c(Account__c = accRole.Id, Opportunity__c = opportunity.Id, Recurso_Financeiro__c = finResource.Id);
        insert guarantee;

        OperationSection__c operation = new OperationSection__c();
        operation.Opportunity__c      = opportunity.Id;
        operation.BranchStatus__c     = 'Aprovar';
        insert operation;
        
        Quote quote         = new Quote();
        quote.Name          = 'Teste';
        quote.OpportunityId = opportunity.Id;
        quote.UnitPrice__c  = 100;
        quote.Quantity__c   = 20;
        insert quote;

        PersonalDataSection__c personalDataRecord            = new PersonalDataSection__c();
        personalDataRecord.Opportunity__c                    = opportunity.Id;
        personalDataRecord.NameStatus__c                     = 'Aprovar';
        personalDataRecord.CPFStatus__c                      = 'Rejeitar';
        personalDataRecord.BirthCityStatus__c                = 'Aprovar';
        personalDataRecord.BirthCountryStatus__c             = 'Aprovar';
        personalDataRecord.BirthDateStatus__c                = 'Pendenciar';
        personalDataRecord.NationalityStatus__c              = 'Pendenciar';
        personalDataRecord.PoliticallyExposedPersonStatus__c = 'Pendenciar';

        insert personalDataRecord;
    }

    @isTest
    static void copyInfoSuccess()
    {
        Account acc     = [SELECT Id, Name FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];

        

        Test.startTest();
        ProposalService.start(acc.Id, opp.Id);
        Test.stopTest();

    }

}