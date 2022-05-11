@isTest
public with sharing class ProposalIncomeDataControllerTest 
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
    static void getIncomeDetailsTest() 
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String, SObject> result = new Map<String, SObject>();

        Test.startTest();
        result = ProposalIncomeDataController.getIncomeDetails(acc.Id, opp.Id);
        Test.stopTest();

        IncomeDataSection__c   incomeSection    = (IncomeDataSection__c)    result.get('INCOME_SECTION');
        ProfessionalInfo__c    professionalInfo = (ProfessionalInfo__c)     result.get('PROFESSIONAL_SECTION');
        Opportunity            minimalIncome    = (Opportunity)             result.get('MINIMAL_INCOME'); 
        Account                networth         = (Account)                 result.get('NETWORTH_INCOME');
        FinancialResources__c  monthlyIncome    = (FinancialResources__c)   result.get('MONTHLY_INCOME');
        FinancialResources__c  presumedIncome   = (FinancialResources__c)   result.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c  confirmedIncome  = (FinancialResources__c)   result.get('CONFIRMED_MONTHLY_INCOME');

        System.assertEquals('Aprovar', incomeSection.ProfessionalSituationStatus__c, 'Incorrect IncomeDataSection value');
        System.assertEquals('Engenheiro', professionalInfo.JobTitle__c, 'Incorrect Job title value');
        System.assertEquals(3000, minimalIncome.MinimalRequiredIncome__c, 'Incorrect minimal income value');
        System.assertEquals(20000, networth.NetWorthLowerLimit__c, 'Incorrect networth lower limit value');
        System.assertEquals(30000, networth.NetWorthUpperLimit__c, 'Incorrect networth upper limit value');
        System.assertEquals(5000, monthlyIncome.Amount__c, 'Incorrect monthly income value');
        System.assertEquals(4800, presumedIncome.Amount__c, 'Incorrect presumed income value');
        System.assertEquals(4500, confirmedIncome.Amount__c, 'Incorrect confirmed income value');
    }

    @isTest
    static void getIncomeDetailsEmptyTest() 
    {
        Account acc = TestSetup.getAccount('Lenilson', false);
        acc.DocumentNumber__c = '34763590006';
        insert acc;

        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);

        Map<String, SObject> result = new Map<String, SObject>();

        Test.startTest();
        result = ProposalIncomeDataController.getIncomeDetails(acc.Id, opp.Id);
        Test.stopTest();

        IncomeDataSection__c   incomeSection    = (IncomeDataSection__c)    result.get('INCOME_SECTION');
        ProfessionalInfo__c    professionalInfo = (ProfessionalInfo__c)     result.get('PROFESSIONAL_SECTION');
        Opportunity            minimalIncome    = (Opportunity)             result.get('MINIMAL_INCOME'); 
        Account                networth         = (Account)                 result.get('NETWORTH_INCOME');
        FinancialResources__c  monthlyIncome    = (FinancialResources__c)   result.get('MONTHLY_INCOME');
        FinancialResources__c  presumedIncome   = (FinancialResources__c)   result.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c  confirmedIncome  = (FinancialResources__c)   result.get('CONFIRMED_MONTHLY_INCOME');

        System.assertEquals(new IncomeDataSection__c(), incomeSection, 'Should have returned an empty Income Section');
        System.assertEquals(new ProfessionalInfo__c(), professionalInfo, 'Should have returned an empty professional info');
        System.assertEquals(null, monthlyIncome, 'Should have returned an empty monthly income');
        System.assertEquals(null, presumedIncome, 'Should have returned an empty presumed income');
        System.assertEquals(null, confirmedIncome, 'Should have returned an empty confirmed income');
    }

    @isTest
    static void saveIncomeSectionSuccess() 
    {   
        Exception testException;
        IncomeDataSection__c incomeSection = [SELECT Id, ProfessionStatus__c FROM IncomeDataSection__c LIMIT 1];
        ProfessionalInfo__c professionalInfo = [SELECT Id FROM ProfessionalInfo__c LIMIT 1];
        FinancialResources__c monthlyIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c presumedIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'PRESUMED_MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c confirmedIncome = [SELECT Id, Type__c FROM FinancialResources__c WHERE Type__c = 'CONFIRMED_MONTHLY_INCOME' LIMIT 1];
        Account networth = [SELECT Id, NetWorthLowerLimit__c, NetWorthUpperLimit__c FROM Account LIMIT 1];
        Opportunity minimalIncome = [SELECT Id, MinimalRequiredIncome__c FROM Opportunity WHERE Name = 'Formalizacao Autofin' LIMIT 1];
        
        Map<String, SObject> payload = new Map<String, SObject>();

        payload.put('IncomeSection', incomeSection);
        payload.put('ProfessionalInfo', professionalInfo);
        payload.put('MonthlyIncomeInfo', monthlyIncome);
        payload.put('PresumedMonthlyIncomeInfo', presumedIncome);
        payload.put('ConfirmedMonthlyIncomeInfo', confirmedIncome);
        payload.put('NetworthIncomeInfo', networth);
        payload.put('MinimalRequiredIncome', minimalIncome);

        Test.startTest();
        try {
            ProposalIncomeDataController.saveIncomeDataSection(payload);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        System.assertEquals(null, testException, 'It was not supposed to return an exception.');
    }

    
    @isTest
    static void saveIncomeSectionFail() 
    {
        Exception testException;

        IncomeDataSection__c incomeSection = [SELECT Id, ProfessionStatus__c FROM IncomeDataSection__c LIMIT 1];
        incomeSection.ProfessionStatus__c = 'Rejeitar';

        FinancialResources__c monthlyIncome = new FinancialResources__c();
        Account networth = new Account();
        Opportunity minimalIncome = new Opportunity();

        Map<String, SObject> payload = new Map<String, SObject>();

        payload.put('IncomeSection', incomeSection);
        payload.put('MonthlyIncomeInfo', monthlyIncome);
        payload.put('NetworthIncomeInfo', networth);
        payload.put('MinimalRequiredIncome', minimalIncome);

        Test.startTest();
        try {
            ProposalIncomeDataController.saveIncomeDataSection(payload);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        IncomeDataSection__c incomeUpdated  = [SELECT Id, ProfessionStatus__c FROM IncomeDataSection__c LIMIT 1];

        System.assertEquals('Attempted to upsert a null list', testException.getMessage(), 'The payload should not be null.');
        System.assertEquals('Aprovar', incomeUpdated.ProfessionStatus__c, 'Returned a wrong value for professional status');
    }
}