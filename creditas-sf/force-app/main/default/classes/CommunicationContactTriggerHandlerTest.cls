/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe AddressesTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           23/08/2021      Created     Classe de teste para o CommunicationContactTriggerHandlerTest
**********************************************************************************************************************************/
@isTest
public class CommunicationContactTriggerHandlerTest {
    
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = false;
        
        CommunicationContacts__c varCommunicationContact = new CommunicationContacts__c();
        varCommunicationContact.Account__c = varAccount.Id;
        
        insert varCommunicationContact;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        CommunicationContacts__c varCommunicationContact = [SELECT Id, Name, Account__c, Code__c
                                                            FROM CommunicationContacts__c LIMIT 1]; 

        varCommunicationContact.Code__c = '2342432432';
    
        Test.startTest();
        update varCommunicationContact;
        Test.stopTest();

        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, Birth_City__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account
                              WHERE Id =: varCommunicationContact.Account__c
                              LIMIT 1];

        System.debug('TYUMI');
        System.debug(varCommunicationContact);
        System.debug(varAccount);

        System.assertEquals(true, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultipleAddresses()
    {
        Account varAccount = [SELECT Id, Name, isExternallySynched__c FROM Account LIMIT 1];
        List<CommunicationContacts__c> listAddressesInsert = new List<CommunicationContacts__c>();
        List<CommunicationContacts__c> listAddressesUpdate = new List<CommunicationContacts__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            CommunicationContacts__c varCommunicationContact = new CommunicationContacts__c();
            varCommunicationContact.Account__c = varAccount.Id;

            listAddressesInsert.add(varCommunicationContact);    
        }

        insert listAddressesInsert;

        for(CommunicationContacts__c varCommunicationContact : listAddressesInsert)
        {
            varCommunicationContact.Code__c = '2342432432';
            listAddressesUpdate.add(varCommunicationContact);
        }
        
        Test.startTest();
        update listAddressesUpdate;
        Test.stopTest();

        Account varAccountUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Account Where Name = 'Francisco' LIMIT 1];

        System.debug('tyumi account => ' + varAccountUpdate);

        System.assertEquals(true, varAccountUpdate.IsExternallySynched__c);
    }

    @isTest
    static void updateMultiple()
    {
        List<Account> listAccountInsert = new List<Account>();
        List<CommunicationContacts__c> listAddressesInsert = new List<CommunicationContacts__c>();
        List<CommunicationContacts__c> listAddressesUpdate = new List<CommunicationContacts__c>();
        
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

        CommunicationContacts__c varCommunicationContact1 = new CommunicationContacts__c();
        varCommunicationContact1.Account__c = varAccount1.Id; 
        
        CommunicationContacts__c varCommunicationContact2 = new CommunicationContacts__c();
        varCommunicationContact2.Account__c = varAccount2.Id;

        CommunicationContacts__c varCommunicationContact3 = new CommunicationContacts__c();
        varCommunicationContact3.Account__c = varAccount3.Id;

        listAddressesInsert.add(varCommunicationContact1);
        listAddressesInsert.add(varCommunicationContact2);
        listAddressesInsert.add(varCommunicationContact3);

        insert listAddressesInsert;

        varCommunicationContact1.Code__c = '42423423';
        varCommunicationContact2.Code__c = '42423423';
        varCommunicationContact3.Code__c = '42423423';

        listAddressesUpdate.add(varCommunicationContact1);
        listAddressesUpdate.add(varCommunicationContact2);
        listAddressesUpdate.add(varCommunicationContact3);

        Test.startTest();
        update listAddressesUpdate;
        Test.stopTest();

        Account varAccountUpdated = [SELECT Id, Name, IsExternallySynched__c FROM Account WHERE Name = 'Jose' LIMIT 1];

        System.assertEquals(false, varAccountUpdated.IsExternallySynched__c);
    }
}