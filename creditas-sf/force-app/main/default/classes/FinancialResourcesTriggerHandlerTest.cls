/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe FinancialResources
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o FinancialResourcesHandler
**********************************************************************************************************************************/
@isTest
public class FinancialResourcesTriggerHandlerTest {
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = true;
        
        FinancialResources__c varFinancialResource = new FinancialResources__c();
        varFinancialResource.Account__c = varAccount.Id;
        varFinancialResource.Amount__c = 10000;
        varFinancialResource.Type__c = 'MONTHLY_INCOME';
        varFinancialResource.Source__c = 'SALARIES';
        
        insert varFinancialResource;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        FinancialResources__c varFinancialResource = [SELECT Id, Name, Account__c, Amount__c, Type__c, Source__c
                                                      FROM FinancialResources__c LIMIT 1]; 

        varFinancialResource.Amount__c = 20000;
        varFinancialResource.Type__c = 'CONFIRMED_MONTHLY_INCOME';
        varFinancialResource.Source__c = 'LOANS';
        
        Test.startTest();
        update varFinancialResource;
        Test.stopTest();

        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account
                              WHERE Id =: varFinancialResource.Account__c
                              LIMIT 1];

        System.debug('TYUMI');
        System.debug(varFinancialResource);
        System.debug(varAccount);

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultiple()
    {
        Account varAccount = [SELECT Id, Name, isExternallySynched__c FROM Account LIMIT 1];
        List<FinancialResources__c> listFinancialInsert = new List<FinancialResources__c>();
        List<FinancialResources__c> listFinancialUpdate = new List<FinancialResources__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            FinancialResources__c varFinancialResource = new FinancialResources__c();
            varFinancialResource.Account__c = varAccount.Id;

            listFinancialInsert.add(varFinancialResource);    
        }

        insert listFinancialInsert;

        for(FinancialResources__c varFinancialResource : listFinancialInsert)
        {
            varFinancialResource.Amount__c = 30000;
            varFinancialResource.Source__c = 'DONATIONS';
            listFinancialUpdate.add(varFinancialResource);
        }
        
        update listFinancialUpdate;
    }
}