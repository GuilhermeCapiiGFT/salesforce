@isTest
public class ProposalOperationControllerTest {
    
    @TestSetup
    static void makeData(){
        String accPessoaFisica = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Pessoa_Fisica' AND SobjectType = 'Account']?.Id;
        List<Account> accounts = new List<Account>();
        Account accCustomer = TestSetup.getAccount('Nivaele', false);
        accCustomer.DocumentNumber__c = '51479566039';
        accCustomer.BankName__c = 'test bank customer';
        accCustomer.Agency__c = '00001'; 
        accCustomer.BankAccountNumber__c = '01020304'; 
        accCustomer.RecordTypeId = accPessoaFisica;
        accounts.add(accCustomer);
        
        Account accRole = TestSetup.getAccount('Account_Role', false);
        accRole.DocumentNumber__c = '12047477000101';
        accRole.BankName__c = 'test bank ';
        accRole.Agency__c = '12345'; 
        accRole.BankAccountNumber__c = '0123456'; 
        accRole.RecordTypeId = accPessoaFisica;
        accounts.add(accRole);
        
        insert accounts;
        
        Opportunity opp = OpportunitySetup.createOpportunity(accCustomer.Id, 'AutoFin');
        opp.Description = 'teste';
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
    static void getOperationDetailsTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Map<String, SObject> result = new Map<String, SObject>();

        Test.startTest();
        result = ProposalOperationController.getOperationDetails(opp.Id);
        Test.stopTest();

        OperationSection__c operationSection = (OperationSection__c) result.get('OperationSection');
        Account proponent = (Account) result.get('Proponent');
        FinancialResources__c finResource = (FinancialResources__c) result.get('Financial');
        Quote quote = (Quote) result.get('Quote');
        Opportunity oppResult = (Opportunity) result.get('Opportunity');
        
        System.assertEquals('Aprovar', operationSection.BranchStatus__c ,'Incorrect OperationSection value');
        System.assertEquals('00001', proponent.Agency__c ,'Incorrect Account value');
        System.assertEquals('2022', finResource.ManufacturingYear__c ,'Incorrect Financial Resource value');
        System.assertEquals(20, quote.Quantity__c ,'Incorrect Quote value');  
        System.assertEquals('teste', oppResult.Description ,'Incorrect Opportunity value');  
    }
    
    @isTest
    static void getOperationDetailsEmptyTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        Opportunity opp = TestSetup.getOpportunity(acc.Id, true);
        
        Map<String, SObject> result = new Map<String, SObject>();

        Test.startTest();
        result = ProposalOperationController.getOperationDetails(opp.Id);
        Test.stopTest();

        OperationSection__c operationSection = (OperationSection__c) result.get('OperationSection');
        Account proponent = (Account) result.get('Proponent');
        FinancialResources__c finResource = (FinancialResources__c) result.get('Financial');
        Quote quote = (Quote) result.get('Quote');
        
        System.assertEquals(new OperationSection__c(), operationSection,'Should return empty OperationSection');
        System.assertEquals(new Account(), proponent ,'Should return empty Account');
        System.assertEquals(new FinancialResources__c(), finResource ,'Should return empty FinancialResources__c');
        System.assertEquals(new Quote(), quote ,'Should return empty Quote');  
    }
    
    @isTest
    static void getOperationDetailsFailTest(){
        String exceptionMessage = '';
        Account acc = [SELECT Id FROM Account Limit 1];
        
        Test.startTest();
        try{
        	ProposalOperationController.getOperationDetails(acc.Id);
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', exceptionMessage, 'An opportunity id should be passed.');
    }

    @isTest
    static void saveOperationDetailsSuccessTest(){        
        Opportunity opp = [SELECT Id, Description FROM Opportunity LIMIT 1];
        opp.Description = 'Teste Opportunity';
        
        Quote quote = [SELECT Id, ParameterTac__c FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];
        quote.ParameterTac__c = 1.2;
        
        Account proponent = [SELECT Id, Name FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        proponent.Name = 'Nivaele2';
        
        OperationSection__c operationSection = [SELECT Id, BranchStatus__c FROM OperationSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        operationSection.BranchStatus__c = 'Rejeitar';
        
        FinancialResources__c finResource = [SELECT Id, Amount__c FROM FinancialResources__c LIMIT 1];
        finResource.Amount__c = 30000;
            
        Map<String, SObject> payload = new Map<String, SObject>();
		
        payload.put('OperationSection', operationSection);
        payload.put('Quote', quote);
        payload.put('Financial', finResource);
        payload.put('Proponent', proponent);
        payload.put('Opportunity', opp);
        
        Test.startTest();
        ProposalOperationController.saveOperationDetails(payload);
        Test.stopTest();
        
        OperationSection__c operationUpdated = [SELECT Id, BranchStatus__c FROM OperationSection__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        Garantias__c finResourceFromGuarantee = [SELECT Id, Recurso_Financeiro__r.Amount__c FROM Garantias__c WHERE Opportunity__c = :opp.Id];
        Opportunity oppUpdated = [SELECT Id, Description FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        Quote quoteUpdated = [SELECT Id, ParameterTac__c FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];
		OpportunityRole__c accUpdated = [SELECT Id, ExternalPersonId__r.Name FROM OpportunityRole__c WHERE Opportunity__c =: opp.Id AND Role__c = 'PRINCIPAL' LIMIT 1];
        
        System.assertEquals('Rejeitar', operationUpdated.BranchStatus__c,'Incorrect OperationSection value');
        System.assertEquals(30000, finResourceFromGuarantee.Recurso_Financeiro__r.Amount__c,'Incorrect Financial Resource value');
        System.assertEquals('Teste Opportunity', oppUpdated.Description,'Incorrect Opportunity value');
        System.assertEquals(1.2, quoteUpdated.ParameterTac__c,'Incorrect Quote value');
        System.assertEquals('Nivaele2', accUpdated.ExternalPersonId__r.Name,'Incorrect Proponent value');
    }
    
    @isTest
    static void saveOperationDetailsFailTest(){
        Exception testException;
        
        Account proponent = [SELECT Id, Name FROM Account WHERE Name = 'Nivaele' LIMIT 1];
        proponent.Name = 'Nivaele2';
        
        Map<String, SObject> payload = new Map<String, SObject>();
		
        payload.put('Quote', proponent);
        payload.put('OperationSection', proponent);
        payload.put('Financial', proponent);
        payload.put('Proponent', proponent);
        
        Test.startTest();
        try{
        	ProposalOperationController.saveOperationDetails(payload);
        }catch(Exception e){
            testException = e;
        }
        Test.stopTest();
        Account resultProponent = [SELECT Id, Name FROM Account WHERE Id = :proponent.Id LIMIT 1];
        System.assertEquals('System.AuraHandledException', testException.getTypeName(), 'Wrong exception was thrown');
        System.assertEquals('Invalid conversion from runtime type Account to Quote', testException.getMessage(),'Incorrect Exception message');
        System.assertEquals('Nivaele', resultProponent.Name,'Incorrect Account Name value');

    }
}