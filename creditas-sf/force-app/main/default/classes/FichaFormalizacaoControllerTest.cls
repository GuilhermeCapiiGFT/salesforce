@isTest
public class FichaFormalizacaoControllerTest {
    
    @TestSetup
    static void makeData() 
    {
        Account varAccount = TestSetup.getAccount('Francisco', true);

        Documents__c varDocuments = new Documents__c();
        varDocuments.Account__c = varAccount.Id;
        insert varDocuments;

        ProfessionalInfo__c varProfessionalInfo = new ProfessionalInfo__c();
        varProfessionalInfo.Account__c = varAccount.Id;
        insert varProfessionalInfo;

        CommunicationContacts__c varCommunicationContact = new CommunicationContacts__c();
        varCommunicationContact.Account__c = varAccount.Id;
        insert varCommunicationContact;

        Addresses__c varAddress = new Addresses__c();
        varAddress.Account__c = varAccount.Id;
        insert varAddress;

        FinancialResources__c varFinancialResources = new FinancialResources__c();
        insert varFinancialResources;

        AccountFinancialRelationship__c varAccountFinancial = new AccountFinancialRelationship__c();
        varAccountFinancial.Account__c = varAccount.Id;
        varAccountFinancial.Recurso_Financeiro__c = varFinancialResources.Id;
        insert varAccountFinancial;

    }

    @isTest
    static void getData() {

        Id varAccountId = [SELECT Id, Name FROM Account LIMIT 1]?.Id;

        System.debug('TYUMI => varaccountId: ' + varAccountId);

        Test.startTest();
        FichaFormalizacaoController.getRecords(varAccountId);
        Test.stopTest();

    }
}