/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe ProfessionalInfoTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Thales Yumiya           11/08/2021      Created     Classe de teste para o ProfessionalInfoTriggerHandlerTest
**********************************************************************************************************************************/
@isTest
public class ProfessionalInfoTriggerTest {
    
    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Francisco', true);
        varAccount.IsExternallySynched__c = true;
        
        ProfessionalInfo__c varProfessionalInfo = new ProfessionalInfo__c();
        varProfessionalInfo.Account__c = varAccount.Id;
        varProfessionalInfo.JobTitle__c = 'Engenheiro';
        varProfessionalInfo.StartDate__c = Date.today();
        varProfessionalInfo.EconomicActivity__c = 'OTHERS';
        
        insert varProfessionalInfo;
    }

    @isTest
    static void updateIsExternallySync() 
    {
        ProfessionalInfo__c varProfessionalInfo = [SELECT Id, Name, Account__c, JobTitle__c, StartDate__c, EconomicActivity__c
                                                   FROM ProfessionalInfo__c LIMIT 1]; 

        varProfessionalInfo.JobTitle__c = 'Padre';
        varProfessionalInfo.StartDate__c = Date.today().addYears(5);
        varProfessionalInfo.EconomicActivity__c = 'RELIGION';
    
        Test.startTest();
        update varProfessionalInfo;
        Test.stopTest();

        Account varAccount = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalCreationDate__c, ExternalUpdatedDate__c,
                              ExternalTenant__c, ExternalModifiedBy__c, DocumentType__c, DocumentNumber__c, Name, Gender__c, BirthDate__c,
                              CivilStatus__c, BirthCity__c, Birth_Country__c, Nationality__c, IsSynchEnabled__c
                              FROM Account
                              WHERE Id =: varProfessionalInfo.Account__c
                              LIMIT 1];

        System.assertEquals(false, varAccount.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
    }

    @isTest
    static void updateMultiple()
    {
        Account varAccount = [SELECT Id, Name, isExternallySynched__c FROM Account LIMIT 1];
        List<ProfessionalInfo__c> listProfessionalInfoInsert = new List<ProfessionalInfo__c>();
        List<ProfessionalInfo__c> listProfessionalInfoUpdate = new List<ProfessionalInfo__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            ProfessionalInfo__c varProfessionalInfo = new ProfessionalInfo__c();
            varProfessionalInfo.Account__c = varAccount.Id;

            listProfessionalInfoInsert.add(varProfessionalInfo);    
        }

        insert listProfessionalInfoInsert;

        for(ProfessionalInfo__c varProfessionalInfo : listProfessionalInfoInsert)
        {
            varProfessionalInfo.JobTitle__c = 'Médico';
            varProfessionalInfo.EconomicActivity__c = 'MEDICINE';
            listProfessionalInfoUpdate.add(varProfessionalInfo);
        }
        
        update listProfessionalInfoUpdate;
    }
}