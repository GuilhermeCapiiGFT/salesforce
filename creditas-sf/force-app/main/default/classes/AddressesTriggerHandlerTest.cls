/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe AddressesTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o AddressesTriggerHandlerTest
**********************************************************************************************************************************/
@isTest
public class AddressesTriggerHandlerTest {
    
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = true;
        
        Addresses__c varAddress = new Addresses__c();
        varAddress.Account__c = varAccount.Id;
        
        insert varAddress;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        Addresses__c varAddress = [SELECT Id, Name, Account__c, Country__c, Neighborhood__c
                                    FROM Addresses__c LIMIT 1]; 

        varAddress.Neighborhood__c = 'Jd Santana';
        varAddress.Country__c = 'Brasil';
    
        Test.startTest();
        update varAddress;
        Test.stopTest();

        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account
                              WHERE Id =: varAddress.Account__c
                              LIMIT 1];

        System.debug('TYUMI');
        System.debug(varAddress);
        System.debug(varAccount);

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultiple()
    {
        Account varAccount = [SELECT Id, Name, isExternallySynched__c FROM Account LIMIT 1];
        List<Addresses__c> listAddressesInsert = new List<Addresses__c>();
        List<Addresses__c> listAddressesUpdate = new List<Addresses__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            Addresses__c varAddress = new Addresses__c();
            varAddress.Account__c = varAccount.Id;

            listAddressesInsert.add(varAddress);    
        }

        insert listAddressesInsert;

        for(Addresses__c varAddress : listAddressesInsert)
        {
            varAddress.Complement__c = 'Teste rua';
            listAddressesUpdate.add(varAddress);
        }
        
        update listAddressesUpdate;
    }
}