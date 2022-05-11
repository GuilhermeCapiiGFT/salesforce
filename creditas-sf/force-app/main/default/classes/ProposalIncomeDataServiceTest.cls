@isTest
public class ProposalIncomeDataServiceTest 
{
    @TestSetup
    static void makeData() { 
        Account varAccount = TestSetup.getAccount('Nivaele', false);
        varAccount.NetWorthLowerLimit__c = 20000;
        varAccount.NetWorthUpperLimit__c = 30000;
        insert varAccount;

        Opportunity opportunity              = new Opportunity();
        opportunity.AccountId                = varAccount.Id;
        opportunity.MinimalRequiredIncome__c = 3000;
        opportunity.Name                     = 'Formalizacao Autofin';
        opportunity.StageName                = 'Novo';
        opportunity.CloseDate                = Date.today().addDays(10);
        opportunity.ExternalTenant__c        = 'creditasbr';
        opportunity.ExternalVersion__c       = 1;      
        opportunity.RecordTypeId             = Util.getRecordTypeIdbyName('Opportunity', 'AutoFin');
        insert opportunity;
        
        ProfessionalInfo__c professionalInfo = new ProfessionalInfo__c();
        professionalInfo.Account__c          = varAccount.Id;
        professionalInfo.Status__c           = 'CLT';
        professionalInfo.JobTitle__c         = 'Engenheiro';
        insert professionalInfo;

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
        accFinRel1.Account__c                      = varAccount.Id;
        accFinRel1.Recurso_Financeiro__c           = monthlyIncome.Id;
        insert accFinRel1;

        AccountFinancialRelationship__c accFinRel2 = new AccountFinancialRelationship__c();
        accFinRel2.Account__c                      = varAccount.Id;
        accFinRel2.Recurso_Financeiro__c           = presumedMonthlyIncome.Id;
        insert accFinRel2;

        AccountFinancialRelationship__c accFinRel3 = new AccountFinancialRelationship__c();
        accFinRel3.Account__c                      = varAccount.Id;
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
    }

    @isTest
    static void getIncomeSectionSuccessTest() {
        Opportunity opp = [SELECT Id, MinimalRequiredIncome__c FROM Opportunity LIMIT 1];
        IncomeDataSection__c result = new IncomeDataSection__c();

        Test.startTest();
        result = ProposalIncomeDataService.getIncomeDataSection(opp.Id);
        Test.stopTest();

        System.assertEquals('Aprovar', result.ProfessionStatus__c, 'Incorrect profession status');
    }

    @isTest
    static void getIncomeSectionEmptyTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        IncomeDataSection__c result = new IncomeDataSection__c();

        Test.startTest();
        result = ProposalIncomeDataService.getIncomeDataSection(opp.Id);
        Test.stopTest();

        System.assertEquals(new IncomeDataSection__c(), result, 'Should return an empty income section');
    }

    @isTest
    static void getProfessionalInfoSuccessTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ProfessionalInfo__c result = new ProfessionalInfo__c();

        Test.startTest();
        result = ProposalIncomeDataService.getProfession(acc.Id);
        Test.stopTest();

        System.assertEquals('CLT', result.Status__c, 'Incorrect value for Status');
    }

    @isTest
    static void getProfessionalInfoEmptyTest() {
        Account acc = TestSetup.getAccount('Francisco', false);
        acc.DocumentNumber__c = '311.599.030-85';
        insert acc;

        ProfessionalInfo__c result = new ProfessionalInfo__c();

        Test.startTest();
        result = ProposalIncomeDataService.getProfession(acc.Id);
        Test.stopTest();

        System.assertEquals(new ProfessionalInfo__c(), result, 'Should have returned an empty professional info');
    }

    @isTest
    static void getAccountTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Account result = new Account();

        Test.startTest();
        result = ProposalIncomeDataService.getAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(20000, result.NetWorthLowerLimit__c, 'Incorrect value for Networth lower limit');
    }

    @isTest
    static void getAccountFailTest() {
        Exception testException;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        try {
            ProposalIncomeDataService.getAccount(opp.Id);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        System.debug(testException.getMessage());

        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'An account id was expected to be passed.');
    }

    @isTest
    static void getOpportunityTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Opportunity result = new Opportunity();

        Test.startTest();
        result = ProposalIncomeDataService.getOpportunity(opp.Id);
        Test.stopTest();

        System.assertEquals(3000, result.MinimalRequiredIncome__c, 'Incorrect value for minimal required income');
    }

    @isTest
    static void getOpportunityFailTest() {
        Exception testException;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        try {
            ProposalIncomeDataService.getOpportunity(acc.Id);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'An opportunity id was expected to be passed.');
    }

    @isTest
    static void getFinancialResourcesSuccessTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String, FinancialResources__c> result = new Map<String, FinancialResources__c>();

        Test.startTest();
        result = ProposalIncomeDataService.getFinancialResource(acc.Id);
        Test.stopTest();

        FinancialResources__c monthlyIncome = result.get('MONTHLY_INCOME');
        FinancialResources__c presumedIncome = result.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c confirmedIncome = result.get('CONFIRMED_MONTHLY_INCOME');

        System.assertEquals(3, result.size(), 'Result should have 3 financial resources');
        System.assertEquals(5000, monthlyIncome.Amount__c, 'Incorrect monthly income amount');
        System.assertEquals(4800, presumedIncome.Amount__c, 'Incorrect presumed income amount');
        System.assertEquals(4500, confirmedIncome.Amount__c, 'Incorrect confirmed income amount');
    }

    @isTest
    static void getFinancialResourcesEmptyTest() {
        Account acc = TestSetup.getAccount('Francisco', false);
        acc.DocumentNumber__c = '311.599.030-85';
        insert acc;

        Map<String, FinancialResources__c> result = new Map<String, FinancialResources__c>();

        Test.startTest();
        result = ProposalIncomeDataService.getFinancialResource(acc.Id);
        Test.stopTest();

        FinancialResources__c monthlyIncome = result.get('MONTHLY_INCOME');
        FinancialResources__c presumedIncome = result.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c confirmedIncome = result.get('CONFIRMED_MONTHLY_INCOME');

        System.assertEquals(null, monthlyIncome, 'Should return null for monthly income');
        System.assertEquals(null, presumedIncome, 'Should return null for presumed income');
        System.assertEquals(null, confirmedIncome, 'Should return null for confirmed income');
    }

    @isTest
    static void saveOperationDetailsSuccessTest() 
    {
        IncomeDataSection__c incomeSection = [SELECT Id, ProfessionStatus__c FROM IncomeDataSection__c LIMIT 1];
        incomeSection.ProfessionStatus__c = 'Rejeitar';

        ProfessionalInfo__c professionalInfo = [SELECT Id FROM ProfessionalInfo__c LIMIT 1];
        professionalInfo.JobTitle__c = 'Arquiteto';

        FinancialResources__c monthlyIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'MONTHLY_INCOME' LIMIT 1];
        monthlyIncome.Amount__c = 6000;

        FinancialResources__c presumedIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'PRESUMED_MONTHLY_INCOME' LIMIT 1];
        presumedIncome.Amount__c = 4700;

        FinancialResources__c confirmedIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'CONFIRMED_MONTHLY_INCOME' LIMIT 1];
        confirmedIncome.Amount__c = 5500;

        Account networth = [SELECT Id, NetWorthLowerLimit__c, NetWorthUpperLimit__c FROM Account LIMIT 1];
        networth.NetWorthLowerLimit__c = 70000;
        networth.NetWorthUpperLimit__c = 100000;

        Opportunity minimalIncome = [SELECT Id, MinimalRequiredIncome__c FROM Opportunity WHERE Name = 'Formalizacao Autofin' LIMIT 1];
        minimalIncome.MinimalRequiredIncome__c = 2800;

        Map<String, SObject> payload = new Map<String, SObject>();

        payload.put('IncomeSection', incomeSection);
        payload.put('ProfessionalInfo', professionalInfo);
        payload.put('MonthlyIncomeInfo', monthlyIncome);
        payload.put('PresumedMonthlyIncomeInfo', presumedIncome);
        payload.put('ConfirmedMonthlyIncomeInfo', confirmedIncome);
        payload.put('NetworthIncomeInfo', networth);
        payload.put('MinimalRequiredIncome', minimalIncome);

        Test.startTest();
        ProposalIncomeDataService.saveIncomeSection(payload);
        Test.stopTest();

        IncomeDataSection__c incomeUpdated           = [SELECT Id, ProfessionStatus__c FROM IncomeDataSection__c LIMIT 1];
        ProfessionalInfo__c professionalInfoUpdated  = [SELECT Id, JobTitle__c FROM ProfessionalInfo__c LIMIT 1];
        Opportunity minimalIncomeUpdated             = [SELECT Id, MinimalRequiredIncome__c FROM Opportunity WHERE Name = 'Formalizacao Autofin' LIMIT 1];
        Account networthUpdated                      = [SELECT Id, NetWorthLowerLimit__c, NetWorthUpperLimit__c FROM Account LIMIT 1];
        FinancialResources__c monthlyIncomeUpdated   = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c presumedIncomeUpdated  = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'PRESUMED_MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c confirmedIncomeUpdated = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'CONFIRMED_MONTHLY_INCOME' LIMIT 1];

        System.assertEquals('Rejeitar', incomeUpdated.ProfessionStatus__c, 'Returned a wrong value for professional status');
        System.assertEquals('Arquiteto', professionalInfoUpdated.JobTitle__c, 'Returned a wrong value for job title');
        System.assertEquals(2800, minimalIncomeUpdated.MinimalRequiredIncome__c, 'Returned a wrong value for the minimal required income');
        System.assertEquals(70000, networthUpdated.NetWorthLowerLimit__c, 'Returned a wrong value for the networth lower limit');
        System.assertEquals(6000, monthlyIncomeUpdated.Amount__c, 'Returned a wrong value for the monthly income');
        System.assertEquals(4700, presumedIncomeUpdated.Amount__c, 'Returned a wrong value for the presumed monthly income');
        System.assertEquals(5500, confirmedIncomeUpdated.Amount__c, 'Returned a wrong value for the confirmed monthly income');
    }

    @isTest
    static void saveIncomeDetailsFailTest() {
        Exception testException;

        Account networth = [SELECT Id, Name, NetWorthLowerLimit__c, NetWorthUpperLimit__c FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        networth.NetWorthLowerLimit__c = 10000;
        
        Map<String, SObject> payload = new Map<String, SObject>();

        payload.put('IncomeSection', networth);
        payload.put('ProfessionalInfo', networth);
        payload.put('MonthlyIncomeInfo', networth);
        payload.put('PresumedMonthlyIncomeInfo', networth);
        payload.put('ConfirmedMonthlyIncomeInfo', networth);
        payload.put('NetworthIncomeInfo', networth);
        payload.put('MinimalRequiredIncome', networth);

        Test.startTest();
        try {
            ProposalIncomeDataService.saveIncomeSection(payload);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        Account networthUpdated = [SELECT Id, NetWorthLowerLimit__c FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        
        System.assertEquals('Invalid conversion from runtime type Account to ProfessionalInfo__c', testException.getMessage(), 'Expected a ProfessionalInfo record');
        System.assertEquals(10000, networth.NetWorthLowerLimit__c, 'Incorrect value for networth lower limit.');
    }
}