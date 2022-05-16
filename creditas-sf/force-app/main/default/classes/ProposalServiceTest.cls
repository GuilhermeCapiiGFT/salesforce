@isTest
public with sharing class ProposalServiceTest {

    @TestSetup
    static void makeData()
    {
        Account accCustomer               = TestSetup.getAccount('Nivaele', false);
        accCustomer.Birth_City__c         = 'Monte Caramelo';
        accCustomer.Mother__c             = 'Juzimara da Silva';
        accCustomer.Father__c             = 'Josialdo Ferreira';
        accCustomer.NetWorthLowerLimit__c = 20000;
        accCustomer.NetWorthUpperLimit__c = 30000;
        accCustomer.DocumentNumber__c     = '51479566039';
        accCustomer.BankName__c           = 'Itausa';
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

        Documents__c rg = new Documents__c();
        rg.Account__c = accCustomer.Id;
        rg.DocumentNumber__c = '4242344';
        rg.IssuerState__c = 'SP';
        rg.Issuer__c = 'SSP';
        insert rg;

        CommunicationContacts__c email = new CommunicationContacts__c();
        email.Account__c = accCustomer.Id;
        email.Channel__c = 'EMAIL';
        email.Code__c = 'nivaele@ig.com.br';
        insert email;

        Addresses__c address = new Addresses__c();
        address.Account__c = accCustomer.Id;
        address.Street__c = 'Rua Itapetininga';
        address.StreetNumber__c  = '45';
        address.Country__c = 'Brasil';
        address.AreaLevel2__c = 'Sao Jao Del Rei';
        insert address;

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

        Garantias__c guarantee = new Garantias__c(Account__c = accRole.Id, Opportunity__c = opportunity.Id, Recurso_Financeiro__c = finResource.Id);
        insert guarantee;

        Quote quote         = new Quote();
        quote.Name          = 'Teste';
        quote.OpportunityId = opportunity.Id;
        quote.UnitPrice__c  = 100;
        quote.Quantity__c   = 20;
        insert quote;

        List<SObject> sectionsObjects = new List<SObject>();

        PersonalDataSection__c personalDataSection  = new PersonalDataSection__c(Opportunity__c = opportunity.Id);
        ContactDetailsSection__c contactDataSection = new ContactDetailsSection__c(Opportunity__c = opportunity.Id);
        AddressDataSection__c addressDataSection    = new AddressDataSection__c(Opportunity__c = opportunity.Id);
        WarrantyDataSection__c warrantyDataSection  = new WarrantyDataSection__c(Opportunity__c = opportunity.Id);
        IncomeDataSection__c incomeDataSection      = new IncomeDataSection__c(Opportunity__c = opportunity.Id);
        OperationSection__c operationDataSection    = new OperationSection__c(Opportunity__c = opportunity.Id);

        sectionsObjects.add(personalDataSection);
        sectionsObjects.add(contactDataSection);
        sectionsObjects.add(addressDataSection);
        sectionsObjects.add(warrantyDataSection);
        sectionsObjects.add(incomeDataSection);
        sectionsObjects.add(operationDataSection);

        insert sectionsObjects;
    }

    @isTest
    public static void copyInfoSuccess()
    {
        Account acc                           = [SELECT Id, Name, BirthCity__c, Mother__c, Father__c FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp                       = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        Quote quote                           = [SELECT Id, Quantity__c FROM Quote LIMIT 1];
        Documents__c rg                       = [SELECT Id, DocumentNumber__c, IssuerState__c, Issuer__c FROM Documents__c];
        CommunicationContacts__c email        = [SELECT Id, Code__c FROM CommunicationContacts__c LIMIT 1];
        Addresses__c address                  = [SELECT Id, Street__c, StreetNumber__c, Country__c, AreaLevel2__c FROM Addresses__c LIMIT 1];
        FinancialResources__c monthlyIncome   = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c presumedIncome  = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'PRESUMED_MONTHLY_INCOME' LIMIT 1];
        FinancialResources__c confirmedIncome = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Type__c = 'CONFIRMED_MONTHLY_INCOME' LIMIT 1];
        ProfessionalInfo__c professionalInfo  = [SELECT Id, Status__c, JobTitle__c FROM ProfessionalInfo__c LIMIT 1];
        
        Test.startTest();
        ProposalService.start(acc.Id, opp.Id);
        Test.stopTest();
        
        PersonalDataSection__c personalDataSection  = [SELECT Id, Name__c, BirthCity__c,Mother__c, Father__c, RG__c, Issuer__c, IssuerState__c FROM  PersonalDataSection__c LIMIT 1];
        ContactDetailsSection__c contactDataSection = [SELECT Id, Email__c FROM ContactDetailsSection__c];
        AddressDataSection__c addressDataSection    = [SELECT Id, StreetNumber__c, Country__c, AreaLevel2__c, Street__c  FROM AddressDataSection__c];
        WarrantyDataSection__c warrantyDataSection  = [SELECT Id FROM WarrantyDataSection__c];
        IncomeDataSection__c incomeDataSection      = [SELECT Id, JobTitle__c, Status__c, MonthlyIncome__c, PresumedMonthlyIncome__c, ConfirmedMonthlyIncome__c  FROM IncomeDataSection__c LIMIT 1];
        OperationSection__c operationDataSection    = [SELECT Id, Quantity__c  FROM OperationSection__c];

        System.assertEquals(acc.Name, personalDataSection.Name__c,'Field value should have been the same');
        System.assertEquals(acc.Father__c, personalDataSection.Father__c,'Field value should have been the same');
        System.assertEquals(acc.Mother__c, personalDataSection.Mother__c,'Field value should have been the same');
        System.assertEquals(acc.BirthCity__c, personalDataSection.BirthCity__c,'Field value should have been the same');
        
        System.assertEquals(email.Code__c, contactDataSection.Email__c, 'Field value should have been the same');
        
        System.assertEquals(address.StreetNumber__c, addressDataSection.StreetNumber__c, 'Field value should have been the same');
        System.assertEquals(address.Country__c, addressDataSection.Country__c, 'Field value should have been the same');
        System.assertEquals(address.AreaLevel2__c, addressDataSection.AreaLevel2__c, 'Field value should have been the same');
        System.assertEquals(address.Street__c, addressDataSection.Street__c, 'Field value should have been the same');
        
        System.assertEquals(professionalInfo.JobTitle__c, incomeDataSection.JobTitle__c, 'Field value should have been the same');
        System.assertEquals(professionalInfo.Status__c, incomeDataSection.Status__c, 'Field value should have been the same');
        System.assertEquals(monthlyIncome.Amount__c, incomeDataSection.MonthlyIncome__c, 'Field value should have been the same');
        System.assertEquals(presumedIncome.Amount__c, incomeDataSection.PresumedMonthlyIncome__c, 'Field value should have been the same');
        System.assertEquals(confirmedIncome.Amount__c, incomeDataSection.ConfirmedMonthlyIncome__c, 'Field value should have been the same');
        
        System.assertEquals(quote.Quantity__c, operationDataSection.Quantity__c, 'Field value should have been the same');
    }

    @isTest
    public static void createSectionsSuccess() 
    {
        Account acc       = [SELECT Id, Name, BirthCity__c, Mother__c, Father__c FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp   = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];

        List<SObject> sections = new List<SObject>();

        PersonalDataSection__c personalDataSection  = new PersonalDataSection__c(Opportunity__c = opp.Id);
        ContactDetailsSection__c contactDataSection = new ContactDetailsSection__c(Opportunity__c = opp.Id);
        AddressDataSection__c addressDataSection    = new AddressDataSection__c(Opportunity__c = opp.Id);
        WarrantyDataSection__c warrantyDataSection  = new WarrantyDataSection__c(Opportunity__c = opp.Id);
        IncomeDataSection__c incomeDataSection      = new IncomeDataSection__c(Opportunity__c = opp.Id);
        OperationSection__c operationDataSection    = new OperationSection__c(Opportunity__c = opp.Id);

        sections.add(personalDataSection);
        sections.add(contactDataSection);
        sections.add(addressDataSection);
        sections.add(warrantyDataSection);
        sections.add(incomeDataSection);
        sections.add(operationDataSection);
        
        insert sections;

        Test.startTest();
        ProposalService.start(acc.Id, opp.Id);
        Test.stopTest();
        
        List<PersonalDataSection__c> updatedPersonalDataSection  = [SELECT Id, Name__c, BirthCity__c,Mother__c, Father__c, RG__c, Issuer__c, IssuerState__c FROM  PersonalDataSection__c];
        List<ContactDetailsSection__c> updatedContactDataSection = [SELECT Id, Email__c FROM ContactDetailsSection__c];
        List<AddressDataSection__c> updatedAddressDataSection    = [SELECT Id, StreetNumber__c, Country__c, AreaLevel2__c, Street__c  FROM AddressDataSection__c];
        List<WarrantyDataSection__c> updatedWarrantyDataSection  = [SELECT Id FROM WarrantyDataSection__c];
        List<IncomeDataSection__c> updatedIncomeDataSection      = [SELECT Id, JobTitle__c, Status__c, MonthlyIncome__c, PresumedMonthlyIncome__c, ConfirmedMonthlyIncome__c  FROM IncomeDataSection__c];
        List<OperationSection__c> updatedOperationDataSection    = [SELECT Id, Quantity__c  FROM OperationSection__c];

        System.assertEquals(2, updatedPersonalDataSection.size(), 'Expected twice the records of sections.');
        System.assertEquals(2, updatedContactDataSection.size(), 'Expected twice the records of sections.');
        System.assertEquals(2, updatedAddressDataSection.size(), 'Expected twice the records of sections.');
        System.assertEquals(2, updatedWarrantyDataSection.size(), 'Expected twice the records of sections.');
        System.assertEquals(2, updatedIncomeDataSection.size(), 'Expected twice the records of sections.');
        System.assertEquals(2, updatedOperationDataSection.size(), 'Expected twice the records of sections.');
    }

    @isTest
    public static void cloneFail()
    {
        Exception testException;
        Account acc       = [SELECT Id, Name, BirthCity__c, Mother__c, Father__c FROM Account WHERE Name = 'Account_Role' LIMIT 1];
        Opportunity opp   = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        try {
            ProposalService.start(opp.Id, acc.Id);
        } catch(Exception e) {
            testException = e;
        }
        Test.stopTest();

        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage(), 'Should not return results in the list.');
    }

    @isTest
    public static void cloneStageSuccess()
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        ProposalService.changeStageName(opp.Id);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];

        System.assertEquals('Em Análise de Formalização', updatedOpp.StageName, 'Incorrect value for Stage Name.');
    }

    @isTest
    public static void cloneStageFail()
    {
        Exception testException;
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        try {
            ProposalService.changeStageName(acc.Id);
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];

        System.assertEquals('Em Análise de Formalização', updatedOpp.StageName, 'Incorrect value for Stage Name.');
    }
}