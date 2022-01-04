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
    static void updateMultipleAddresses()
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
        
        Test.startTest();
        update listAddressesUpdate;
        Test.stopTest();

        Account varAccountUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Account Where Name = 'Francisco' LIMIT 1];

        System.debug('tyumi account => ' + varAccountUpdate);

        System.assertEquals(false, varAccountUpdate.IsExternallySynched__c);
    }

    @isTest
    static void updateMultiple()
    {
        List<Account> listAccountInsert = new List<Account>();
        List<Addresses__c> listAddressesInsert = new List<Addresses__c>();
        List<Addresses__c> listAddressesUpdate = new List<Addresses__c>();
        
        Account varAccount1 = new Account();
        varAccount1.Name = 'Jose';
        varAccount1.IsExternallySynched__c = false;
        varAccount1.DocumentNumber__c = '01234567890';
        varAccount1.DocumentType__c = 'CPF';
        varAccount1.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME = 'Pessoa Física']?.Id;
        
        Account varAccount2 = new Account();
        varAccount2.Name = 'Joao';
        varAccount2.IsExternallySynched__c = false;
        varAccount2.DocumentNumber__c = '28241540043';
        varAccount2.DocumentType__c = 'CPF';
        varAccount2.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME = 'Pessoa Física']?.Id;
        
        Account varAccount3 = new Account();
        varAccount3.IsExternallySynched__c = false;
        varAccount3.Name = 'Josimar';
        varAccount3.DocumentNumber__c = '39615016020';
        varAccount3.DocumentType__c = 'CPF';
        varAccount3.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME = 'Pessoa Física']?.Id;

        listAccountInsert.add(varAccount1);
        listAccountInsert.add(varAccount2);
        listAccountInsert.add(varAccount3);

        insert listAccountInsert;

        Addresses__c varAddress1 = new Addresses__c();
        varAddress1.Account__c = varAccount1.Id; 
        
        Addresses__c varAddress2 = new Addresses__c();
        varAddress2.Account__c = varAccount2.Id;

        Addresses__c varAddress3 = new Addresses__c();
        varAddress3.Account__c = varAccount3.Id;

        listAddressesInsert.add(varAddress1);
        listAddressesInsert.add(varAddress2);
        listAddressesInsert.add(varAddress3);

        insert listAddressesInsert;

        varAddress1.Complement__c = 'Rua da gloria';
        varAddress2.Complement__c = 'Rua Sarsi Figueira';
        varAddress3.Complement__c = 'Rua Jose sampaio';

        listAddressesUpdate.add(varAddress1);
        listAddressesUpdate.add(varAddress2);
        listAddressesUpdate.add(varAddress3);

        Test.startTest();
        update listAddressesUpdate;
        Test.stopTest();

        Account varAccountUpdated = [SELECT Id, Name, IsExternallySynched__c FROM Account WHERE Name = 'Jose' LIMIT 1];

        System.assertEquals(false, varAccountUpdated.IsExternallySynched__c);
    }
}