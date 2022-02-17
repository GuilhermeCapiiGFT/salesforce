/*******************************************************************************************************************************************************
* Copyright © 2021 Creditas
* ======================================================================================================================================================
* Purpose: Prover dados de teste para os métodos reutilizáveis para operações básicas
* ======================================================================================================================================================
* History
* -------
* VERSION 	AUTHOR 							DATE    		DETAIL 		Description
* 1.0 		Thales Yumiya 	                10/07/2021 		Created 	Prover dados de teste para os métodos reutilizáveis para operações básicas
*******************************************************************************************************************************************************/
@isTest
private class UtilTest {
      
    @isTest
    private static void getElapsedTimeTest() {
        //Create timecontrol
        Time timeControl = Time.newInstance(00, 00, 00, 00);
        //Create time variables
        Time timeHours = Time.newInstance(01, 00, 00, 00);
        Time timeMinutes = Time.newInstance(00, 35, 00, 00);
        Time timeSeconds = Time.newInstance(00, 00, 31, 00);
        Time timeMiliSeconds = Time.newInstance(00, 00, 00, 21);
        Time timeFull = Time.newInstance(07, 07, 07, 07);
        //compares both times and returns the difference between then
        Test.startTest();
        Time elapsedTimeHours = Util.getElapsedTime(timeControl, timeHours);
        Time elapsedTimeMinutes = Util.getElapsedTime(timeControl, timeMinutes);
        Time elapsedTimeSeconds = Util.getElapsedTime(timeControl, timeSeconds);
        Time elapsedTimeMilliseconds = Util.getElapsedTime(timeControl, timeMiliSeconds);
        Time elapsedTimeNullTime = Util.getElapsedTime(timeControl, null);
        Time elapsedTimeFullTime = Util.getElapsedTime(timeControl, timeFull);
        Test.stopTest();
        //Asserts Hour only
        System.assertEquals(elapsedTimeHours.hour(), 1, 'Calculou o tempo errado');
        //Assert Minutes only
        System.assertEquals(elapsedTimeMinutes.minute(), 35, 'Calculou o tempo errado');
        //Assert Seconds only
        System.assertEquals(elapsedTimeSeconds.second(), 31, 'Calculou o tempo errado');
        //Assert Miliseconds only
        System.assertEquals(elapsedTimeMilliseconds.millisecond(), 21, 'Calculou o tempo errado');
        //Assert null
        System.assertEquals(elapsedTimeNullTime.hour(), 0, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeNullTime.minute(), 0, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeNullTime.second(), 0, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeNullTime.millisecond(), 0, 'Calculou o tempo errado');
        //Assert Fulltime
        System.assertEquals(elapsedTimeFullTime.hour(), 7, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeFullTime.minute(), 7, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeFullTime.second(), 7, 'Calculou o tempo errado');
        System.assertEquals(elapsedTimeFullTime.millisecond(), 7, 'Calculou o tempo errado'); 
    }
          
    @isTest
    private static void testGetRecordTypeByNameAndById()
    {
        //Selects all record types from object account
        List<RecordType> lRecordTypeAccList = [SELECT Id,DeveloperName,Name FROM RecordType WHERE SobjectType  = 'Account'];
        Test.startTest();
        //for each call the method byName or byId and checks if the name/id are correct
        for(RecordType iRecordType : lRecordTypeAccList){
            Id recordTypeId = Util.getRecordTypeIdbyName('Account', iRecordType.DeveloperName);
            System.assertEquals(iRecordType.Id, recordTypeId, 'Id do RT incorreto');
        	String recordTypeName = Util.getRecordTypeNameById('Account', recordTypeId);
            System.assertEquals(iRecordType.Name, recordTypeName, 'DeveloperName do RT incorreto');
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void testGetSObjectFieldValueByFieldName()
    {
        Account varAccount = new Account(Name='Test');
        Contact varContact = new Contact(Account=varAccount);
        Object varAccountName = Util.getSObjectFieldValueByFieldName(varAccount, 'Name');
        Object varContactAccountName = Util.getSObjectFieldValueByFieldName(varContact, 'Account.Name');
        Object varNullField = Util.getSObjectFieldValueByFieldName(varAccount, '');
        
        // Assertions
        System.assertEquals(varAccount.Name, String.valueOf(varAccountName),'Não retornou o campo correto');
        System.assertEquals(varcontact.Account.Name, String.valueOf(varContactAccountName), 'Não retornou o campo correto');
        System.assertEquals(null, varNullField, 'Retorno esperado era null');
    }
    
    @isTest
    private static void testSelectAllFields()
    {
        Task varTask = new Task();
        varTask.Subject = 'Test';
        varTask.OwnerId = UserInfo.getUserId();
        insert varTask;
        
        List<String> lstAllFieldsByName = Util.selectAllFields('Task');
        List<String> lstAllFieldsByObject = Util.selectAllFields(varTask.Id);
        
        // Assertions
        System.assert(!lstAllFieldsByName.isEmpty(), 'List should not be empty');
        System.assert(!lstAllFieldsByObject.isEmpty(), 'List should not be empty');
    }
    
    @isTest
    private static void testUpdateSObjectField()
    {
        QuoteLineItem varQuoteLineItem = new QuoteLineItem();

        Util.updateSObjectField(varQuoteLineItem, 'Description', 'Test');
        
        // Assertions
        System.assertEquals('Test', varQuoteLineItem.Description, 'Deveria ter preenchido o campo');
    }
    
    @isTest
    private static void testGetPicklistValues()
    {
        List<Schema.PicklistEntry> lstPicklistEntry = Util.getPicklistValues('Opportunity', 'StageName');
        System.assertEquals(false, lstPicklistEntry.isEmpty(), 'Deveria ter retornado a lista com os valores da picklist');
    }
    
    @isTest
    private static void testGenerateRandomString()
    {
        String randomStr = Util.generateRandomString(10);
        System.assert(randomStr.length() == 10, 'String should be 10 characters long');
    }
     
    @isTest
    private static void testGetRecordTypesBySObject()
    {
        System.assertEquals(false, Util.getRecordTypesBySObject('Account').isEmpty(), 'Nenhum record type retornado');
    }
    
    @isTest
    private static void testDateTimeToString()
    {
        String dttime = Util.dateTimeToString(Datetime.now());
        System.assertEquals(false, String.isBlank(dttime), 'Não retornou data');
    }

    @isTest
    private static void testValidateDocuments(){
        List<Account> lAccList = new List<Account>();
        Account lAccCNPJ = AccountSetup.createAccount('TestCNPJValid', 'Pessoa_Juridica');
        Account lAccCPF = AccountSetup.createAccount('TestCPFValid', 'Pessoa_Fisica');
        lAccList.add(lAccCNPJ);
        lAccList.add(lAccCPF);
        insert lAccList;
        String lNewCNPJ = DocumentGenerator.generateCNPJ();
        String lNewCPF = DocumentGenerator.generateCPF();

        Test.startTest();
            lAccCNPJ.DocumentNumber__c = lNewCNPJ;
            lAccCPF.DocumentNumber__c = lNewCPF;
            update lAccList;
        Test.stopTest();

        Account lUpdatedAccountCNPJ = [SELECT DocumentNumber__c, IsExternallySynched__c FROM Account WHERE Id = :lAccCNPJ.Id LIMIT 1];
        System.assertEquals(lNewCNPJ, Util.getNumbersOnly(lUpdatedAccountCNPJ.DocumentNumber__c), 'CNPJ Number not updated');
        System.assert(!lUpdatedAccountCNPJ.IsExternallySynched__c, 'ExternallySynched not updated');

        Account lUpdatedAccountCPF = [SELECT DocumentNumber__c, IsExternallySynched__c FROM Account WHERE Id = :lAccCPF.Id LIMIT 1];
        System.assertEquals(lNewCPF, Util.getNumbersOnly(lUpdatedAccountCPF.DocumentNumber__c), 'CPF Number not updated');
        System.assert(!lUpdatedAccountCPF.IsExternallySynched__c, 'ExternallySynched not updated');
    }

    @isTest
    private static void testgetSObjectNameById(){
        Account lAcc = AccountSetup.createAccount('testObjName', 'Pessoa_Juridica');
        insert lAcc;
        Test.startTest();
        String lObjName = Util.getSObjectNameById(lAcc.Id);
        Test.stopTest();
        System.assertEquals('Account', lObjName, 'Wrong object name');
    }

    @isTest
    private static void testInvalidDocumentNumbers(){
        String lCPF = '12345678901';
        string lCNPJ = '12346578901234';
        String lNotADocument = 'NotADocument';
        String lSameChars11 = '11111111111';
        String lSameChars14 = '77777777777777';

        Test.startTest();
        Boolean isValidCNPJ = Util.isValidCNPJ(lCNPJ);
        Boolean isValidCPF = Util.isValidCPF(lCPF);
        Boolean isADocument = Util.isValidDocumentNumber(lNotADocument);
        Boolean isAllTheSameCaracter11 = Util.isAllTheSameCaracter(lSameChars11);
        Boolean isAllTheSameCaracter14 = Util.isAllTheSameCaracter(lSameChars14);
        Test.stopTest();

        System.assert(!isValidCNPJ, 'false was expected');
        System.assert(!isValidCPF, 'false was expected');
        System.assert(!isADocument, 'false was expected');
        System.assert(isAllTheSameCaracter11, 'true was expected');
        System.assert(isAllTheSameCaracter14, 'true was expected');
    }

    @isTest
    private static void removeDiacriticsTest()
    {
        String stringAccent = 'São Paulo';
        String stringExpected = 'Sao Paulo';
        
        Test.startTest();
        	String testAcritics = Util.removeDiacritics(stringAccent);
        Test.stopTest();
        
       System.assertEquals(stringExpected, testAcritics, 'expected without diacritics');
    }

    @isTest
    private static void testUpdateExternallySyncedAcc(){
        Account lAcc = AccountSetup.createAccount('testupdateExternallySynced', 'Pessoa_Fisica');
        lAcc.IsExternallySynched__c = true;
        insert lAcc;
        
        Documents__c lDocument = new Documents__c();
        lDocument.Account__c = lAcc.Id;
        lDocument.IssueDate__c = Date.today();
        lDocument.IssuerState__c = 'SP';
        lDocument.DocumentNumber__c = '4324235234';
        lDocument.Issuer__c = 'SSP';
        insert lDocument;
        
        lDocument.IssueDate__c = Date.today().addDays(6);
        lDocument.IssuerState__c = 'MG';
        lDocument.DocumentNumber__c = '42423423432';
        lDocument.Issuer__c = 'SSP';
        Test.startTest();
            update lDocument;
        Test.stopTest();

        Account lUpdatedAccount = [SELECT IsExternallySynched__c FROM Account LIMIT 1];
        System.debug('lUpdatedAccount --> ' + lUpdatedAccount);
        System.assert(!lUpdatedAccount.IsExternallySynched__c, 'ExternallySynched not updated');
    }

    @isTest
    private static void testUpdateExternallySyncedOpp(){
        Account lAcc = AccountSetup.createAccount('testupdateExternallySynced', 'Pessoa_Fisica');
        lAcc.IsExternallySynched__c = true;
        insert lAcc;

        Opportunity lOpp = OpportunitySetup.createOpportunity(lAcc.Id, 'Home');
        lOpp.IsExternallySynched__c = true;
        insert lOpp;
        
        Quote lQuote = new Quote();
        lQuote.Name = 'Quote Em Andamento';
        lQuote.Status = 'Em andamento';
        lQuote.OpportunityId = lOpp.Id;
        insert lQuote;
        lQuote.MonthlyIntRateCompValue__c = 400;
        Test.startTest();
            update lQuote;
        Test.stopTest();

        Opportunity lUpdatedOpportunity = [SELECT isExternallySynched__c FROM Opportunity LIMIT 1];
        System.assert(!lUpdatedOpportunity.IsExternallySynched__c, 'ExternallySynched not updated');
    }

    @isTest
    private static void testGetRecordTypeDeveloperNameById(){

        Account account = AccountSetup.createAccount('Account1', 'Pessoa_Fisica');

        insert account;
        
        Opportunity opportunity = OpportunitySetup.createOpportunity(account.Id, 'AtWork');

        insert opportunity;

        Test.startTest();

        Account newAccount = [SELECT RecordTypeId FROM Account LIMIT 1];
        Opportunity newOpportunity = [SELECT RecordTypeId FROM Opportunity LIMIT 1];

        String recordTypeDevName1;
        String recordTypeDevName2;
        String recordTypeDevName3;
        String recordTypeDevName4;

        // Positive test
        recordTypeDevName1 = Util.getRecordTypeDeveloperNameById('Account', newAccount.RecordTypeId);
        recordTypeDevName2 = Util.getRecordTypeDeveloperNameById('Opportunity', newOpportunity.RecordTypeId);

        System.assertEquals('Pessoa_Fisica', recordTypeDevName1, 'Incorrect RecordType DeveloperName');
        System.assertEquals('AtWork', recordTypeDevName2, 'Incorrect RecordType DeveloperName');

        // Negative test
        recordTypeDevName1 = Util.getRecordTypeDeveloperNameById('Case', newAccount.RecordTypeId);
        recordTypeDevName2 = Util.getRecordTypeDeveloperNameById('Account', newOpportunity.RecordTypeId);
        recordTypeDevName3 = Util.getRecordTypeDeveloperNameById('', newOpportunity.RecordTypeId);

        System.assertEquals(null, recordTypeDevName1, 'RecordType DeveloperName should by null');
        System.assertEquals(null, recordTypeDevName2, 'RecordType DeveloperName should by null');
        System.assertEquals(null, recordTypeDevName3, 'RecordType DeveloperName should by null');

        Test.stopTest();
    }
}