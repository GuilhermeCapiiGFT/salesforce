/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe GarantiasTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          22/10/2021      Created     Classe de teste para o GarantiasTriggerHandler
**********************************************************************************************************************************/
@isTest
public class GarantiasTriggerHandlerTest {
    
    @TestSetup
    static void makeData()
    {
        Account newAcc = TestSetup.getAccount('Conta', true);
        
        Opportunity newOppty = TestSetup.getOpportunity(newAcc.Id, true);
        
        Opportunity newOppty2 = TestSetup.getOpportunity(newAcc.Id, true);
        
        OpportunityRole__c newOpptyRole = TestSetup.getOppRole(newAcc, newOppty, 'PRINCIPAL', false, true);
        
        OpportunityRole__c newOpptyRole2 = TestSetup.getOppRole(newAcc, newOppty2, 'COLLATERAL_GUARANTOR', false, true);
        
        FinancialResources__c newRecFin = TestSetup.getNewFinRes('Novo Recurso Financeiro', true);	        
    }
    
    @isTest
    static void insertGuaranteeFailed() 
    {
        FinancialResources__c recFinRes = [SELECT Id FROM FinancialResources__c];
        
        Account accRes = [SELECT Id FROM Account];
        
        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE AccountId =: accRes.Id ];
        
        OpportunityRole__c roleRes = [SELECT Id, Role__c, Opportunity__c
                   					  FROM OpportunityRole__c 
                   					  WHERE Opportunity__c IN :opptyRes AND Role__c = 'PRINCIPAL'];
        

        Garantias__c newGuarantee= new Garantias__c();
        //newGuarantee.Name = 'Nova Garantia';
        newGuarantee.Account__c = accRes.Id;
        newGuarantee.Opportunity__c = roleRes.Opportunity__c;
        newGuarantee.Recurso_Financeiro__c = recFinRes.Id;
        
                    
        Test.startTest();
        try{
			insert newGuarantee; 
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }       
        Test.stopTest();
        
		List<Garantias__c> res = [SELECT Id FROM Garantias__c];  
        
        System.assertEquals(0, res.Size());
    }
    
    @isTest
    static void insertUpdateGuaranteeSucess() 
    {
        FinancialResources__c recFinRes = [SELECT Id FROM FinancialResources__c];
        
        Account accRes = [SELECT Id FROM Account];
        
        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE AccountId =: accRes.Id ];
              
        OpportunityRole__c roleRes = [SELECT Id, Role__c, Opportunity__c
                   					  FROM OpportunityRole__c 
                   					  WHERE Opportunity__c IN :opptyRes AND Role__c = 'COLLATERAL_GUARANTOR'];
        
        Garantias__c newGuarantee= new Garantias__c();
        //newGuarantee.Name = 'Nova Garantia';
        newGuarantee.Account__c = accRes.Id;
        newGuarantee.Opportunity__c = roleRes.Opportunity__c;
        newGuarantee.Recurso_Financeiro__c = recFinRes.Id;
        insert newGuarantee;
        
		Garantias__c resInserted = [SELECT Name FROM Garantias__c];  
        
        //newGuarantee.Name = 'Nova Garantia2';
      
        Test.startTest();
        update newGuarantee;   
        Test.stopTest();
        
        Garantias__c resUpdated = [SELECT Name FROM Garantias__c];
            
        //System.assertNotEquals(resInserted, resUpdated);
    }
    
}