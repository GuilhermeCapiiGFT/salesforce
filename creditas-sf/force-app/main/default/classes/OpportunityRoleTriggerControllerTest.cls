/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Testing Class for the OpportunityRoleTriggerController
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          26/10/2021      Created     Testing Class for the OpportunityRoleTriggerController
**********************************************************************************************************************************/
@isTest
public class OpportunityRoleTriggerControllerTest {
    
    @TestSetup
    static void makeData()
    {   //Accounts to create a PRINCIPAL or SOLIDARY_DEBTOR or COLLATERAL_GUARANTOR opportunity role setting 
        Account principalAccount = TestSetup.getAccount('Jose', true); 
        principalAccount.DocumentNumber__c = '137.550.180-12';
        upsert principalAccount;
        
        Account solidaryDebtorAccount = TestSetup.getAccount('Joao', true);        
        solidaryDebtorAccount.DocumentNumber__c = '891.582.300-17';
        upsert solidaryDebtorAccount;        
        
        Account collateralGuarantorAccount = TestSetup.getAccount('Josimar', true);                     
        collateralGuarantorAccount.DocumentNumber__c = '745.277.860-08';
        upsert collateralGuarantorAccount;
        
        //Opportunities to create a PRINCIPAL or SOLIDARY_DEBTOR or COLLATERAL_GUARANTOR opportunity role setting 
        Opportunity principalOpportunity = TestSetup.getOpportunity(principalAccount.Id, true);
        principalOpportunity.Name = 'Jose Opportunity';
        upsert principalOpportunity;
        
        Opportunity solidaryDebtorOpportunity = TestSetup.getOpportunity(solidaryDebtorAccount.Id, true);
        solidaryDebtorOpportunity.Name = 'Joao Opportunity';
        upsert solidaryDebtorOpportunity;
        
        Opportunity collateralGuarantorOpportunity = TestSetup.getOpportunity(collateralGuarantorAccount.Id, true);
        collateralGuarantorOpportunity.Name = 'Josimar Opportunity';
        upsert collateralGuarantorOpportunity;
		
        //OpportunityRoles to create a PRINCIPAL or SOLIDARY_DEBTOR or COLLATERAL_GUARANTOR opportunity role setting
        OpportunityRole__c opportunityRolePrincipal = TestSetup.getOppRole(principalAccount, principalOpportunity, 'PRINCIPAL', false, true);
        OpportunityRole__c opportunityRoleSolidaryDebtor = TestSetup.getOppRole(solidaryDebtorAccount, solidaryDebtorOpportunity, 'SOLIDARY_DEBTOR', false, true);
        OpportunityRole__c opportunityRolecollateralGuarantor = TestSetup.getOppRole(collateralGuarantorAccount, collateralGuarantorOpportunity, 'COLLATERAL_GUARANTOR', false, true);
     }
    
    @isTest
    static void insertOppRoleFailed() 
    {   //Create a setting of Account/Opportunity and Opportunity Role with Principal Role__c
        Account accountFailed = [SELECT Id FROM Account WHERE Name = 'Jose'];
        Opportunity opportunityFailed = [SELECT Id FROM Opportunity WHERE Name = 'Jose Opportunity'];
        OpportunityRole__c opportunityRolePrincipalFailed = [SELECT Id, AccountOwner__c  FROM OpportunityRole__c WHERE Role__c = 'PRINCIPAL'];
        opportunityRolePrincipalFailed.AccountOwner__c = true;
        update opportunityRolePrincipalFailed;
                
        List<Opportunity> opportunitiesFailed = [SELECT Id FROM Opportunity WHERE AccountId =: accountFailed.Id ];        
        List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c, AccountOwner__c FROM OpportunityRole__c 
                                                         WHERE Opportunity__c IN :opportunitiesFailed AND AccountOwner__c = true 
                                                         AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
        
        //Create a new Role with Principal, in this setting the expected is Failed, because existing a Principal and AccountOwner true
        OpportunityRole__c newOpportunityRole = new OpportunityRole__c();
        newOpportunityRole.ExternalPersonId__c = accountFailed.Id;
        newOpportunityRole.Opportunity__c = opportunityFailed.Id;
        newOpportunityRole.Role__c = 'PRINCIPAL';
        newOpportunityRole.AccountOwner__c = true;
        
        Test.startTest();
        //Try update list with a new OpportunityRole__c = PRINCIPAL
        try{        	
        	insert newOpportunityRole;
            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        //Assert need to be =1, because a insertion of a new OpportunityRole__c = PRINCIPAL and AccountOwner true not be permited by Trigger
        List<OpportunityRole__c> checkOpportunityRole = [SELECT id FROM OpportunityRole__c WHERE Role__c = 'PRINCIPAL'];                  
        System.assertEquals(1,listOpportunityRole.size(),'OppRole was created when it should not have been created, as there was already a AccountOwner and a Principal');
    }
    
    @isTest
    static void insertOppRoleSuccess() 
    {   //Create a setting of Account/Opportunity with Role__c = PRINCIPAL    
        Account principalAccount = [SELECT Id FROM Account WHERE Name = 'Jose'];        
        Opportunity principalOportunity = [SELECT Id FROM Opportunity WHERE Name = 'Jose Opportunity'];
        
        //Create a setting of Account/Opportunity with Role__c = SOLIDARY_DEBTOR
        Account solidaryDebtorAccount = [SELECT Id FROM Account WHERE Name = 'Joao'];        
        Opportunity solidaryDebtorOportunity = [SELECT Id FROM Opportunity WHERE Name = 'Joao Opportunity'];
        
        //Create a setting of Account/Opportunity with Role__c = COLLATERAL_GUARANTOR
        Account collateralGuarantorAccount = [SELECT Id FROM Account WHERE Name = 'Josimar'];        
        Opportunity collateralGuarantorOportunity = [SELECT Id FROM Opportunity WHERE Name = 'Josimar Opportunity'];

        //Create a Lists to search for required conditions
        List<Opportunity> opptyRes = [SELECT Id FROM Opportunity WHERE Name = 'Jose' AND Name = 'Joao'];        
        List<OpportunityRole__c> oppRoleInsert = [SELECT Name FROM OpportunityRole__c];              
        List<OpportunityRole__c> listOpportunityRole = [ SELECT Id, ExternalPersonId__r.RecordType.DeveloperName, Opportunity__c FROM OpportunityRole__c 
                                                            WHERE Opportunity__c IN :opptyRes AND AccountOwner__c = true AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'];
            
        //Create a new Role with Principal, in this setting the expected is Success, because not existing a Principal and Account Owner true before
        OpportunityRole__c newPrincipalOppRole = new OpportunityRole__c();
        newPrincipalOppRole.ExternalPersonId__c = principalAccount.Id;
        newPrincipalOppRole.Opportunity__c = principalOportunity.Id;
        newPrincipalOppRole.Role__c = 'PRINCIPAL';
        newPrincipalOppRole.AccountOwner__c = true;
        listOpportunityRole.add(newPrincipalOppRole);
        
        //Create a new Role with Role__c = SOLIDARY_DEBTOR, in this setting the expected is Success, because is not a Principal or Account Owner true
        OpportunityRole__c newSolidaryDebtorOppRole = new OpportunityRole__c();
        newSolidaryDebtorOppRole.ExternalPersonId__c = solidaryDebtorAccount.Id;
        newSolidaryDebtorOppRole.Opportunity__c = solidaryDebtorOportunity.Id;
        newSolidaryDebtorOppRole.Role__c = 'SOLIDARY_DEBTOR';
        newSolidaryDebtorOppRole.AccountOwner__c = true;
        listOpportunityRole.add(newSolidaryDebtorOppRole);
        
        //Create a new Role with Role__c = COLLATERAL_GUARANTOR, in this setting the expected is Success, because is not a Principal or Account Owner true
        OpportunityRole__c newcollateralGuarantorOppRole = new OpportunityRole__c();
        newcollateralGuarantorOppRole.ExternalPersonId__c = collateralGuarantorAccount.Id;
        newcollateralGuarantorOppRole.Opportunity__c = collateralGuarantorOportunity.Id;
        newcollateralGuarantorOppRole.Role__c = 'COLLATERAL_GUARANTOR';
        newcollateralGuarantorOppRole.AccountOwner__c = true;
        listOpportunityRole.add(newcollateralGuarantorOppRole);
        
        insert listOpportunityRole;
                        
        Test.startTest();
        //Try update list with a news Opportunities Roles
        try{
        	update listOpportunityRole;  
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        // The size list need to be 3 = PRINCIPAL, SOLIDARY_DEBTOR and COLLATERAL_GUARANTOR
        List<OpportunityRole__c> checkOpportunityRole = [SELECT id FROM OpportunityRole__c];  
        System.assertEquals(3,listOpportunityRole.size(),'Insertion of a new Opportunity Role failed because there is already an AccountOwner');
    }

    @isTest
    static void updateIsExternallySync() 
    {   // Simulating a field update in the OpportunityRole object
        OpportunityRole__c varOpportunityRole = [SELECT Id, Name, Opportunity__c FROM OpportunityRole__c LIMIT 1]; 

        Test.startTest();
        update varOpportunityRole;
        Test.stopTest();

        Opportunity varOpportunity = [SELECT Id, ExternalId__c, isExternallySynched__C, ExternalVersion__c,
                              ExternalTenant__c, IsSynchEnabled__c
                              FROM Opportunity
                              WHERE Id =: varOpportunityRole.Opportunity__c 
                              LIMIT 1];
		//The field IsExternallySynched__c must be equal to false
        System.assertEquals(false, varOpportunity.IsExternallySynched__c, 'The isExternallySync field must be set to false');
    }

    @isTest
    static void updateMultipleOpportunityRole()
    {	//Create a setting of Account/Opportunity 
        Account varAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        Opportunity varOpportunity = [SELECT Id, Name, isExternallySynched__c, ExternalId__c, ExternalTenant__c, ExternalVersion__c   
                                      FROM Opportunity 
                                      WHERE AccountId =: varAccount.Id 
                                      LIMIT 1];
        
       	//Create a Lists to search for required conditions
        List<OpportunityRole__c> listOpportunityRoleInsert = new List<OpportunityRole__c>();
        List<OpportunityRole__c> listOpportunityRoleUpdate = new List<OpportunityRole__c>();

        for (Integer i = 0; i < 10; i++) 
        {
            OpportunityRole__c varOpportunityRole = new OpportunityRole__c();
            varOpportunityRole.Opportunity__c = varOpportunity.Id;
            varOpportunityRole.ExternalOpportunityId__c = varOpportunity.ExternalId__c;
            varOpportunityRole.ExternalOpportunityTenant__c = varOpportunity.ExternalTenant__c;
            varOpportunityRole.ExternalOppVersion__c = varOpportunity.ExternalVersion__c;
            varOpportunityRole.ExternalPersonId__c = varAccount.Id;

            listOpportunityRoleInsert.add(varOpportunityRole);    
        }

        insert listOpportunityRoleInsert;

        for(OpportunityRole__c varOpportunityRole : listOpportunityRoleInsert)
        {
            listOpportunityRoleUpdate.add(varOpportunityRole);
        }
        
        Test.startTest();
        //Try update list with a new Opportunities Roles
        update listOpportunityRoleUpdate;
        Test.stopTest();
		
        // The field IsExternallySynched__c should have been changed to false
        Opportunity varOpportunityUpdate = [SELECT Id, Name, IsExternallySynched__c FROM Opportunity WHERE AccountId =: varAccount.Id LIMIT 1];
        System.assertEquals(false, varOpportunityUpdate.IsExternallySynched__c, 'Unable to update the field IsExternallySynched__c');
    }
}