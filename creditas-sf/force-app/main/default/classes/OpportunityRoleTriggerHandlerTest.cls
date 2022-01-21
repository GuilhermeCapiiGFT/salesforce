/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para a classe OpportunityRoleTriggerHandler
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          26/10/2021      Created     Classe de teste para a classe OpportunityRoleTriggerHandler
**********************************************************************************************************************************/
@isTest
public class OpportunityRoleTriggerHandlerTest {
    
    @TestSetup
    static void makeData()
    {
        Account newAcc = TestSetup.getAccount('Helia', true);
        
        Opportunity newOppty = TestSetup.getOpportunity(newAcc.Id, true);
        
        Opportunity newOppty2 = TestSetup.getOpportunity(newAcc.Id, true);
        
        OpportunityRole__c newOpptyRole = TestSetup.getOppRole(newAcc, newOppty, 'PRINCIPAL', false, true);
        newOpptyRole.Titular_da_Conta__c = true;
        
        OpportunityRole__c newOpptyRole2 = TestSetup.getOppRole(newAcc, newOppty2, 'PRINCIPAL', false, true);
		newOpptyRole2.Titular_da_Conta__c = true;        
     }
    
    @isTest
    static void insertOppRoleFailed() 
    {              
        Account accRes = [SELECT Id FROM Account];
        
        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE AccountId =: accRes.Id ];
        
        Opportunity opptyId = [SELECT Id FROM Opportunity LIMIT 1];        
               
       List<OpportunityRole__c> res = [SELECT Id FROM OpportunityRole__c];  
        
       List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c FROM OpportunityRole__c 
                                                            WHERE Opportunity__c IN :opptyRes AND Titular_da_Conta__c = true AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
            

        OpportunityRole__c newoppRole = new OpportunityRole__c();
        newoppRole.ExternalPersonId__c = accRes.Id;
        newoppRole.Opportunity__c = opptyId.Id;
        newoppRole.Role__c = 'PRINCIPAL';
        newoppRole.Titular_da_Conta__c = true;
        listOpportunityRole.add(newoppRole); 
        
        Test.startTest();
        insert listOpportunityRole; 
        Test.stopTest();
        
        
        System.assertEquals(1,listOpportunityRole.size());
    }
    
      @isTest
    static void insertOppRoleSuccess() 
    {        
        Account accRes = [SELECT Id FROM Account];
        Opportunity opptyId = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE AccountId =: accRes.Id ];
        
        List<OpportunityRole__c> oppRoleInsert = [SELECT Name FROM OpportunityRole__c];
              
        List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c FROM OpportunityRole__c 
                                                            WHERE Opportunity__c IN :opptyRes AND Titular_da_Conta__c = true AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
            
        
        OpportunityRole__c newOppRole2 = new OpportunityRole__c();
        newOppRole2.ExternalPersonId__c = accRes.Id;
        newOppRole2.Opportunity__c = opptyId.Id;
        newoppRole2.Role__c = 'PRINCIPAL';
        newoppRole2.Titular_da_Conta__c = true;
        listOpportunityRole.add(newoppRole2);
        
        OpportunityRole__c newOppRole3 = new OpportunityRole__c();
        newOppRole3.ExternalPersonId__c = accRes.Id;
        newOppRole3.Opportunity__c = opptyId.Id;
        newoppRole3.Role__c = 'PRINCIPAL';
        newoppRole3.Titular_da_Conta__c = true;
        listOpportunityRole.add(newoppRole3);
        
        insert listOpportunityRole;
                        
        Test.startTest();
        try{
        	update listOpportunityRole;  
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        System.assertEquals(2,listOpportunityRole.size());
    }
}