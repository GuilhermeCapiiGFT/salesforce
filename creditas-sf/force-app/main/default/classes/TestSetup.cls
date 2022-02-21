/*******************************************************************************************************************************
 * Copyright © 2021 Creditas
 * =============================================================================================================================
 * Purpose: Class for creating objects used in test classes
 * =============================================================================================================================
 * History
 * -------
 * VERSION  AUTHOR                          DATE        DETAIL      Description
 * 1.0      Thales Yumiya                   10/08/2021  Created     Class for creating objects used in test classes
********************************************************************************************************************************/
@isTest
public class TestSetup {

    public static Account getAccount(String name, Boolean doInsert) {
        Integer aux = integer.valueof(crypto.getRandomLong());          
        Account varAccount = new Account(Name = name);
        varAccount.DocumentNumber__c = '87056391079';
        varAccount.IsExternallySynched__c = true;
        varAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME = 'Pessoa Física']?.Id;
        
        if(doInsert) {
            insert varAccount;
        }

        return varAccount;
    }

    public static List<Account> getAccounts(Integer numOfAccounts, Boolean doInsert) {
        List<Account> testAccounts = new List<Account>();
        String initialName = 'testaccountname';

        for(Integer i = 0; i < numOfAccounts; ++i) {
            testAccounts.add(getAccount(initialName + String.valueOf(i+1), false));
        }

        if(doInsert) {
            insert testAccounts;
        }
        return testAccounts;
    }

    public static Contact getContact(Id accountId, String fname, String lname, Boolean doInsert) {
        Contact newContact = new Contact(firstName = fname, lastName = lname, accountId = accountId);

        if(doInsert){
            insert newContact;
        }
        return newContact;
    }

    public static User getUser(Boolean doInsert) {
        Profile profileId = [Select Id from Profile where name in ('Standard User', 'Usuário Padrão') limit 1];
        List<User> currentUsers = [SELECT Id FROM User];
        Integer userNumber = currentUsers.size() + 1;

        User userTest = new User();
        userTest.LastName = 'Test' + userNumber;
        userTest.Alias = 'Test' + userNumber;
        userTest.Email = 'usertest' + userNumber + '@creditas.com';
        userTest.Username = 'usertest' + userNumber + '@creditas.com';
        usertest.EmployeeNumber = 'TER01984' + userNumber;
        userTest.CommunityNickname = 'UserTest' + userNumber;
        userTest.ProfileId = profileId.Id;
        userTest.LocaleSidKey = 'pt_BR';
        userTest.LanguageLocaleKey = 'pt_BR';
        userTest.EmailEncodingKey = 'UTF-8';
        userTest.TimeZoneSidKey = 'America/Sao_Paulo';
        userTest.IsActive = true;
        userTest.ManagerId = UserInfo.getUserId();
        userTest.Title = 'Analista';
        userTest.Status__c =  'Ativo';

        if(doInsert) {
            insert userTest;
        }
        return userTest;
    }

    public static List<User> getUsers(Integer numberOfUsers, Boolean doInsert) {
        List<User> newUsers = new List<User>();
        Profile profileId = [Select Id from Profile where name in ('Standard User', 'Usuário Padrão', 'System Administrator') limit 1];

        for(Integer i = 0; i < numberOfUsers; ++i) {
            User userTest = new User();
            userTest.LastName = 'Test' + i ;
            userTest.Alias = 'Test' + i;
            userTest.Email = 'usertest' + i + '@creditas.com';
            userTest.Username = 'usertest' + i + '@creditas.com';
            usertest.EmployeeNumber = 'TER01984' + i ;
            userTest.CommunityNickname = 'UserTest' + i;
            userTest.ProfileId = profileId.Id;
            userTest.LocaleSidKey = 'pt_BR';
            userTest.LanguageLocaleKey = 'pt_BR';
            userTest.EmailEncodingKey = 'UTF-8';
            userTest.TimeZoneSidKey = 'America/Sao_Paulo';
            newUsers.add(userTest);
        }
        if(doInsert) {
            insert newUsers;
        }
        return newUsers;
    }
    
    public static List<User> getUsers(Integer numberOfUsers, String profileName, Boolean doInsert) {
        List<User> newUsers = new List<User>();
        Profile profileId = [Select Id from Profile where name in ('Standard User', 'Usuário Padrão', :profileName) limit 1];

        for(Integer i = 0; i < numberOfUsers; ++i) {
            User userTest = new User();
            userTest.LastName = 'Test' + i ;
            userTest.Alias = 'Test' + i;
            userTest.Email = 'usertest' + i + '@creditas.com';
            userTest.Username = 'usertest' + i + '@creditas.com';
            usertest.EmployeeNumber = 'TER01984' + i ;
            userTest.CommunityNickname = 'UserTest' + i;
            userTest.ProfileId = profileId.Id;
            userTest.LocaleSidKey = 'pt_BR';
            userTest.LanguageLocaleKey = 'pt_BR';
            userTest.EmailEncodingKey = 'UTF-8';
            userTest.TimeZoneSidKey = 'America/Sao_Paulo';
            userTest.IsActive = true;
            userTest.Status__c = 'Ativo';
            userTest.Title = 'Analista';
            newUsers.add(userTest);
        }
        if(doInsert) {
            insert newUsers;
        }
        return newUsers;
    }
    
    public static Opportunity getOpportunity(Id accountId, Boolean doinsert){
        Account varAccount = new Account(Id = accountId);
        
        if(String.isBlank(accountId))
        {
            varAccount = getAccount('Teste', true);
        }
        
        Opportunity varOpportunity = new Opportunity();
        varOpportunity.AccountId = varAccount.Id;
        varOpportunity.Name = 'Teste';
        varOpportunity.StageName = 'Novo';
        varOpportunity.CloseDate = Date.today().addDays(10);
        varOpportunity.ExternalTenant__c = 'creditasbr';
        varOpportunity.ExternalVersion__c = 1;        
        
        if(doInsert)
        {
            insert varOpportunity;
        }        
        return varOpportunity;
    }

    public static Case getCase(Id varAccountId, Id varContactId, Boolean doInsert) {
        Case varCase = new Case();
        varCase.Status = 'Novo';
        varCase.AccountId = varAccountId;
        varCase.ContactId = varContactId;
        
        if(doInsert)
        {
            insert varCase;
        }        
        return varCase;
    }
     
    public static Account getPersonAccount(String firstName, String lastName, Boolean doinsert){
        final Id ACCOUNT_RT_PERSON_ACCOUNT = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
        Account varAccount = new Account(RecordTypeId = ACCOUNT_RT_PERSON_ACCOUNT);
        varAccount.Name = firstName;
        varAccount.DocumentNumber__c = '12345678901234';
        varAccount.IsExternallySynched__c = true;
        
        if(doInsert)
        {
            insert varAccount;
        }        
        return varAccount;
    }

    public static OpportunityRole__c getOppRole (Account acc, Opportunity oppty, String role, Boolean owner, Boolean doinsert){
     	OpportunityRole__c newOppRole = new OpportunityRole__c();
        newOppRole.ExternalPersonId__c = acc.Id;
        newOppRole.Opportunity__c = oppty.Id;
        newOppRole.Role__c = role;
        newOppRole.AccountOwner__c = owner;
        newOppRole.ExternalOpportunityId__c = oppty.Id;
       
        if(doInsert)
        {
            insert newOppRole;
        }        
        return newOppRole;
    }
    
    public static Garantias__c getGuarantees (Account acc, Opportunity oppty, FinancialResources__c financialResource, Boolean doinsert){
     	Garantias__c newGuarantees = new Garantias__c();        
        newGuarantees.Opportunity__c = oppty.Id;             
        newGuarantees.Account__c = acc.Id;
        newGuarantees.Recurso_Financeiro__c = financialResource.Id;
        newGuarantees.ExternalOpportunityId__c = oppty.ExternalId__c;
        newGuarantees.ExternalOpportunityTenant__c = oppty.ExternalTenant__c;
        newGuarantees.ExternalOpportunityVersion__c = oppty.ExternalVersion__c;
       
        if(doInsert)
        {
            insert newGuarantees;
        }        
        return newGuarantees;
    }   
    
    public static FinancialResources__c getNewFinRes (String name, Boolean doinsert){
     	FinancialResources__c newFinRes = new FinancialResources__c();
        newFinRes.Name = name;
                 
        if(doInsert)
        {
            insert newFinRes;
        }        
        return newFinRes;
    }      
}