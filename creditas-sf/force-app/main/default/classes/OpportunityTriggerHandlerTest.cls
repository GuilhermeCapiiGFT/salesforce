/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe Handler do botão sincronizar do OpportunityTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           23/12/2021      Created     Classe de teste para o OpportunityTriggerHandler
**********************************************************************************************************************************/
@isTest
public class OpportunityTriggerHandlerTest {  
    
    private static final Id RECORDTYPE_HOME = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Home').getRecordTypeId();

    @TestSetup
    static void makeData()
    {        
        Account varAccount = TestSetup.getAccount('Joao', false);
        varAccount.DocumentNumber__c = '276.050.350-04';       
        insert varAccount; 
        
        Opportunity varOpportunity1 = TestSetup.getOpportunity(varAccount.Id, true);
        varOpportunity1.Name = 'Joao'; 
        varOpportunity1.RecordTypeId = RECORDTYPE_HOME;
        update varOpportunity1; 
    }

    @isTest
    static void updateIsExternallySync() 
        
    {   String varSObjectApiName = 'Opportunity';
     
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1]; 
     
        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalTenant__c, Name, IsSynchEnabled__c, RecordTypeId
                                      FROM Opportunity 
                                      WHERE AccountId =: varAccount.id LIMIT 1];
        
        varOpportunity.ExternalId__c = '3213213231';
        varOpportunity.IsSynchEnabled__c = 'ENABLED';
        varOpportunity.RecordTypeId = OpportunityTriggerHandler.getOpportunityRecordTypeId('Home'); 
        varOpportunity.ExternalTenant__c = 'creditasbr';
     
     	Custom_Field_Tracking_Map__mdt newCustomMdt = new Custom_Field_Tracking_Map__mdt();
        newCustomMdt.CampoRastreado__c = 'IsSynchEnabled__c';
        newCustomMdt.ObjetoRastreado__c = 'IsSynchEnabled__c';
     
        Test.startTest();
        try{ 
            varOpportunity.ExternalTenant__c = 'creditasmx';
            update varOpportunity;
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
        
        Test.stopTest();

        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'O campo isExternallySync deveria ter mudado para false');
        System.assertEquals('ENABLED', varOpportunity.IsSynchEnabled__c, 'O campo isSynchEnabled não foi mudado para Enabled');
    }  
}