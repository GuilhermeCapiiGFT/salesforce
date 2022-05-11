@isTest
public class ProposalOperationServiceTest {
    @TestSetup
    static void makeData(){
        String accPessoaFisica = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Pessoa_Fisica' AND SobjectType = 'Account']?.Id;
		List<Account> accounts = new List<Account>();
        Account accCustomer = TestSetup.getAccount('Nivaele', false);
        accCustomer.DocumentNumber__c = '51479566039';
        accCustomer.BankName__c = 'test bank principal';
        accCustomer.Agency__c = '00001'; 
        accCustomer.BankAccountNumber__c = '01020304';
        accCustomer.RecordTypeId = accPessoaFisica;
        accounts.add(accCustomer);
        
        Account accRole = TestSetup.getAccount('Account_Role', false);
        accRole.DocumentNumber__c = '12047477000101';
        accRole.BankName__c = 'test bank collateral guarantor';
        accRole.Agency__c = '12345'; 
        accRole.BankAccountNumber__c = '0123456'; 
        accRole.RecordTypeId = accPessoaFisica;
        accounts.add(accRole);
        
        insert accounts;
        
        Opportunity opp = TestSetup.getOpportunity(accCustomer.Id, false);
        opp.Description = 'Test Description Opportunity';
        insert opp;

        OpportunityRole__c oppRoleGuarantor = TestSetup.getOppRole(accRole, opp, 'COLLATERAL_GUARANTOR', false, true); 
        OpportunityRole__c oppRolePrincipal = TestSetup.getOppRole(accCustomer, opp, 'PRINCIPAL', true, true);   

        FinancialResources__c finResource = FinancialResourceSetup.createFinancialResource('Auto');
        finResource.ManufacturingYear__c = '2022';
        finResource.Amount__c = 10000;
        finResource.Type__c = 'CAR';
        insert finResource;
        
        Garantias__c guarantee = new Garantias__c(
            Account__c = accRole.Id,
            Opportunity__c = opp.Id,
            Recurso_Financeiro__c = finResource.Id
        );
        insert guarantee;

        OperationSection__c operation = new OperationSection__c();
        operation.Opportunity__c = opp.Id;
        operation.BranchStatus__c = 'Aprovar';
        insert operation;
        
        Quote quote = new Quote();
        quote.Name = 'Teste';
        quote.OpportunityId = opp.Id;
        quote.UnitPrice__c = 100;
        quote.Quantity__c = 20;
        insert quote;
    }
    
    @isTest
    static void getOperationSectionSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OperationSection__c result = new OperationSection__c();

        Test.startTest();
        result = ProposalOperationService.getOperationSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals('Aprovar', result.BranchStatus__c ,'Incorrect OperationSection value');
    }
    
    @isTest
    static void getOperationSectionEmptyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        OperationSection__c result = new OperationSection__c();

        Test.startTest();
        result = ProposalOperationService.getOperationSectionFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new OperationSection__c(), result ,'Should return empty OperationSection');
    }

    @isTest
    static void getQuoteFromOppSuccessTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote result = new Quote();

        Test.startTest();
        result = ProposalOperationService.getQuoteFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(100, result.UnitPrice__c ,'Incorrect Quote value');
    }

    @isTest
    static void getQuoteFromOppEmptyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        Quote result = new Quote();

        Test.startTest();
        result = ProposalOperationService.getQuoteFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new Quote(), result ,'Should return empty Quote');
    }

    @isTest
    static void getPrincipalProponentFromOppTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account result = new Account();

        Test.startTest();
        result = ProposalOperationService.getProponentFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals('00001', result.Agency__c ,'Incorrect Proponente value');
    }
    
    @isTest
    static void getProponentFromOppEmptyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        Account result = new Account();

        Test.startTest();
        result = ProposalOperationService.getProponentFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new Account(), result ,'Should return empty Proponente');
    }

    @isTest
    static void getFinancialFromOppTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        FinancialResources__c result = new FinancialResources__c();

        Test.startTest();
        result = ProposalOperationService.getFinancialFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(10000, result.Amount__c ,'Incorrect Financial Resources value');
    }

    @isTest
    static void getFinancialFromOppEmptyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        FinancialResources__c result = new FinancialResources__c();

        Test.startTest();
        result = ProposalOperationService.getFinancialFromOpp(opp.Id);
        Test.stopTest();
        
        System.assertEquals(new FinancialResources__c(), result ,'Should return empty FinancialResources');
    }

    @isTest
    static void getOpportunityInfoTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Opportunity result = new Opportunity();
        
        Test.startTest();
        result = ProposalOperationService.getOpportunityInfo(opp.Id);
        Test.stopTest();
        
        System.assertEquals('Test Description Opportunity', result.Description ,'Incorrect Opportunity value');
    }

    @isTest
    static void getOpportunityInfoTestFail(){
        Exception testException;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        Opportunity result = new Opportunity();
        Test.startTest();
        try{
        	result = ProposalOperationService.getOpportunityInfo(acc.Id);
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        
        System.assertEquals('List has no rows for assignment to SObject', testException.getMessage() ,'Incorrect Exception message');
    }
}