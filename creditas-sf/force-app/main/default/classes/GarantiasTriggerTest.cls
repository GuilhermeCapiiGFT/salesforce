/**********************************************************************************************************************************
* Copyright © 2022 Creditas
* ================================================================================================================================
* Purpose: Testing Class for the GarantiasTriggerController
(Covers the classes: GarantiasTriggerController and GarantiasTriggerService)
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          14/02/2022      Created     Testing Class for the GarantiasTriggerController
**********************************************************************************************************************************/
@isTest
public class GarantiasTriggerTest {
    
    @TestSetup
    static void makeData()
    {   //Accounts to create a PRINCIPAL or CollateralGuarantor opportunity role setting       
        Account accountPrincipal = TestSetup.getAccount('Jose', true); 
        accountPrincipal.DocumentNumber__c = '079.485.450-85';
        accountPrincipal.isExternallySynched__C = true;
        update accountPrincipal;
            
        Account accountCollateralGuarantor = TestSetup.getAccount('Joao', true);        
        accountCollateralGuarantor.DocumentNumber__c = '891.582.300-17';
        accountCollateralGuarantor.isExternallySynched__C = true;
        update accountCollateralGuarantor;
        
        Account accountCollateralGuarantorToFailed = TestSetup.getAccount('Josimar', true);                     
       	accountCollateralGuarantorToFailed.DocumentNumber__c = '745.277.860-08';
       	accountCollateralGuarantorToFailed.isExternallySynched__C = true;
        update accountCollateralGuarantorToFailed;
        
       	//Opportunities to create a PRINCIPAL or CollateralGuarantor opportunity role setting
        Opportunity opportunityPrincipal = TestSetup.getOpportunity(accountPrincipal.Id, true);
        opportunityPrincipal.Name = 'Jose Principal';
        update opportunityPrincipal;
        
        Opportunity opportunityCollateralGuarantor = TestSetup.getOpportunity(accountCollateralGuarantor.Id, true);
        opportunityCollateralGuarantor.Name = 'Joao Collateral Guarantor';
        update opportunityCollateralGuarantor;
        
        Opportunity oppCollateralGuarantorToFailed = TestSetup.getOpportunity(accountCollateralGuarantorToFailed.Id, true);
        oppCollateralGuarantorToFailed.Name = 'Josimar';
        
        //Opportunity Roles to create a PRINCIPAL or CollateralGuarantor opportunity role setting
        OpportunityRole__c oppRolePrincipal = TestSetup.getOppRole(accountPrincipal, opportunityPrincipal, 'PRINCIPAL', false, true);
        
        OpportunityRole__c oppRoleCollateralGuarantor = TestSetup.getOppRole(accountCollateralGuarantor, opportunityCollateralGuarantor, 'COLLATERAL_GUARANTOR', false, true);
        
        OpportunityRole__c oppRoleCollateralGuarantorToFailed = TestSetup.getOppRole(accountCollateralGuarantorToFailed, oppCollateralGuarantorToFailed, 'PRINCIPAL', false, true);
        
        //Financial Resources to create a PRINCIPAL or CollateralGuarantor opportunity role setting    
        FinancialResources__c financialResourcesPrincipal = TestSetup.getNewFinRes('Recurso Financeiro', true);          
        upsert financialResourcesPrincipal;
        
        FinancialResources__c finResourcesCollateralGuarantor = TestSetup.getNewFinRes('Recurso Collateral Guarantor', true);
        upsert finResourcesCollateralGuarantor;
        
        FinancialResources__c finResourcesToFailed = TestSetup.getNewFinRes('Recurso Financeiro To Failed', true); 
        upsert finResourcesToFailed;
        
        //Create Garantias to test updateIsExternallySync method
        Garantias__c guaranteesCollateralGuarantor = TestSetup.getGuarantees(accountCollateralGuarantor, opportunityCollateralGuarantor, finResourcesCollateralGuarantor, true);
  
    }
    
    @isTest
    static void insertGuaranteeFailed() 
    {   //Create a setting of Account/Opportunity and Opportunity Role with Role__c = Principal 
        Account accountToFailed = [SELECT Id FROM Account WHERE Name ='Josimar'];        

        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE AccountId =: accountToFailed.Id ];
        
        OpportunityRole__c oppRoleToFailed = [SELECT Id, Role__c, Opportunity__c
                   					  FROM OpportunityRole__c 
                   					  WHERE Opportunity__c IN :opptyRes AND Role__c = 'PRINCIPAL'];
        
        //Create a new Guarantee with Principal Rolle__c 
        Garantias__c newGuarantee= new Garantias__c();      
        newGuarantee.Account__c = accountToFailed.Id;
        newGuarantee.Opportunity__c = oppRoleToFailed.Opportunity__c;
           
        Test.startTest();
        //Try insert a new Guarantee, the expected is Failed, because only FinancialResources owned by a Guarantee Guarantor can be added to guarantees
        try{
			insert newGuarantee; 
         } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }       
        Test.stopTest();
        
        //Assert need to be 0, because a insertion of a new Guarantee with Rolle__c = PRINCIPAL not be permited by Trigger
		List<Garantias__c> listGuarantee = [SELECT Id FROM Garantias__c WHERE Account__c =: accountToFailed.Id LIMIT 1];  
        System.assertEquals(0, listGuarantee.Size(),'The guarantee was created, when it shouldnt, because only FinancialResources owned by a Collateral Guarantor can be added');
    }
    
    @isTest
    static void insertUpdateGuaranteeSucess() 
    {	//Create a setting of Account/Opportunity and Opportunity Role with Role__c = COLLATERAL_GUARANTOR 
        Account accountSuccess = [SELECT Id FROM Account WHERE Name ='Joao'];
        FinancialResources__c financialResourcesSuccess = [SELECT Id FROM FinancialResources__c LIMIT 1];       

        List<Opportunity> opportunitySuccess = [SELECT Id FROM Opportunity WHERE AccountId =: accountSuccess.Id];
        OpportunityRole__c oppRoleCollateralGuarantor = [SELECT Id, Role__c, Opportunity__c
                                                          FROM OpportunityRole__c 
                                                          WHERE Opportunity__c IN :opportunitySuccess AND Role__c = 'COLLATERAL_GUARANTOR'];
        //Create a new Guarantee with Role__c = COLLATERAL_GUARANTOR
        Garantias__c newGuarantee = new Garantias__c();
        newGuarantee.Account__c = accountSuccess.Id;
        newGuarantee.Opportunity__c = oppRoleCollateralGuarantor.Opportunity__c;
        newGuarantee.Recurso_Financeiro__c = financialResourcesSuccess.Id; 
               
        Test.startTest();
        //Try insert a new Guarantee, the expected is Success
        try{
            insert newGuarantee; 
            system.debug('newGuarantee: ' + newGuarantee);
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        
        Test.stopTest();
        
        //Assert need to be 1, because a insertion of a new Guarantee with Rolle__c = PRINCIPAL not be permited by Trigger
        List<Garantias__c> listGuarantee = [SELECT Id FROM Garantias__c WHERE Account__c =: accountSuccess.Id];         
        System.assertNotEquals(1,listGuarantee.size(),'Only financial resources owned by a Guarantee Guarantor can be added to guarantees');
    }
    
    @isTest
    static void updateIsExternallySync() 
    {  //Test when to update a Guarantees if the field IsExternallySynched__c will change to false
        Garantias__c guaranteesSuccess = [SELECT Id, Name, Opportunity__c, ExternalOpportunityTenant__c FROM Garantias__c LIMIT 1]; 
        guaranteesSuccess.ExternalOpportunityTenant__c = 'creditasbr';
        
        Test.startTest();
        guaranteesSuccess.ExternalOpportunityTenant__c = 'creditasmx';
        update guaranteesSuccess;
        Test.stopTest();
        
        //Assert for the field IsExternallySynched__c need to be false
        Opportunity opportunitySuccess = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c, ExternalTenant__c, IsSynchEnabled__c
                              			  FROM Opportunity WHERE Id =: guaranteesSuccess.Opportunity__c LIMIT 1];
        System.assertEquals(false, opportunitySuccess.IsExternallySynched__c, 'The isExternallySync field should have changed to false');
    }

    @isTest
    static void updateMultipleOpportunityRole()
    {   //Test when to update a multiple Guarantees if the field IsExternallySynched__c will change to false
        Account accountSuccess = [SELECT Id, Name FROM Account WHERE Name ='Joao'];
       
        Opportunity opportunitySuccess = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                          FROM Opportunity 
                                          WHERE AccountId =: accountSuccess.Id 
                                          LIMIT 1];
        
        FinancialResources__c financialResourcesSuccess = [SELECT Id, Name FROM FinancialResources__c LIMIT 1];
        
        //Create a Lists to test update and Insert        
        List<Garantias__c> listGuaranteesInsert = new List<Garantias__c>();
        List<Garantias__c> listGuaranteesUpdate = new List<Garantias__c>();

        //Insert Guarantees and populate the list
        for (Integer i = 0; i < 10; i++) 
        {
            Garantias__c varGuarantees = new Garantias__c();
            varGuarantees.Account__c = accountSuccess.Id;
            varGuarantees.Opportunity__c = opportunitySuccess.Id;
            varGuarantees.Recurso_Financeiro__c = financialResourcesSuccess.Id;
            varGuarantees.ExternalOpportunityId__c = opportunitySuccess.ExternalId__c;
            varGuarantees.ExternalOpportunityTenant__c = opportunitySuccess.ExternalTenant__c;
            varGuarantees.ExternalOpportunityVersion__c = opportunitySuccess.ExternalVersion__c;  

            listGuaranteesInsert.add(varGuarantees);    
        }

        insert listGuaranteesInsert;		
         
        for(Garantias__c varGuarantees : listGuaranteesInsert)
        {
            listGuaranteesUpdate.add(varGuarantees);
        }
        
        Test.startTest();
        //Testing Update Multiple Guarantees
        update listGuaranteesUpdate;
        Test.stopTest();
		
        //Assert for the field IsExternallySynched__c need to be false
        Opportunity opportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: accountSuccess.Id LIMIT 1];
        System.assertEquals(false, opportunityUpdate.IsExternallySynched__c,'The isExternallySync field should have changed to false');
    }    
}