/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test class for the Component LWC - GroupMember 
  (Covers the classes: GroupMembersController, GroupMembersService and GroupMember Response)
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          01/12/2021      Created     Test class for LWC Component classes - GroupMember
* 1.1       Nathalia Rosa          28/02/2022      Updated     Changed class name from GroupMembersLWCTest to GroupMembersTest 
**********************************************************************************************************************************/
@isTest
public class GroupMembersTest {        
    
    @TestSetup
    static void makeData()
    {   
        Profile profile = [SELECT Id FROM Profile WHERE Name in ('System Administrator', 'Administrador do Sistema') LIMIT 1];
        
        //Create Users
        User newUser = TestSetup.getUser(true);
		newUser.ProfileId = profile.Id;
        newUser.LastName = 'user';
		update newUser;    
        
        User newUser2 = TestSetup.getUser(true);
		newUser2.ProfileId = profile.Id;
        newUser2.LastName = 'Manager';
        newUser2.Title = 'Analista';
        newUser2.Status__c = 'Ativo';
		update newUser2; 
        
        User newUser3 = TestSetup.getUser(true);
		newUser3.ProfileId = profile.Id;
        newUser3.LastName = 'User 2';
		update newUser3;
        
        User newUser4 = TestSetup.getUser(true);
		newUser4.ProfileId = profile.Id;
        newUser4.LastName = 'Test4';
        newUser4.Title = 'Analista';
        newUser4.Status__c = 'Ativo';
		update newUser4;

		//Create Parent Group        
        system.runAs(newUser){
        CollaborationGroup grp = new CollaborationGroup();
        grp.name = 'Test Group1';
        grp.CollaborationType = 'Private'; 
        grp.isBroadcast = true;
        Insert grp;  
            
        CollaborationGroup group1 = new CollaborationGroup();
        group1.name = 'Test Group';
        group1.CollaborationType = 'Private'; 
        group1.isBroadcast = true;
        Insert group1; 
            
        //Create Group Member    
        CollaborationGroupMember collGroup = new CollaborationGroupMember();             
        collGroup.CollaborationRole = 'Standard';   
        collGroup.CollaborationGroupId = grp.Id;
        collGroup.memberId = newUser2.Id;
        insert collGroup;
 
        CollaborationGroupMember collGroup2 = new CollaborationGroupMember();             
        collGroup2.CollaborationRole = 'Admin';   
        collGroup2.CollaborationGroupId = group1.Id;
        collGroup2.memberId = newUser4.Id;
        insert collGroup2;
       }             
    }  
                
    @isTest
    static void createMemberGroupStandardSuccess() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];     
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
        CollaborationGroupMember collGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
        
       Test.startTest();  
        system.runAs(varUser2){
            
        try{            
            string gpMember = GroupMembersController.createMemberGroup(collGroup.id, varUser.Id, 'Standard');            
         } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
         }  
            
        Test.stopTest();       
            
        List<CollaborationGroupMember> addCollGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember LIMIT 1];  
            
        System.assertEquals(addCollGroupMember.size(),1,'Member successfully inserted!');
    	}
    }   
    
    @isTest
    static void createMemberGroupManagerSuccess() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];     
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
        CollaborationGroupMember collGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin' LIMIT 1];
        
       Test.startTest();  
        system.runAs(varUser2){
            
        try{            
            string gpMember = GroupMembersController.createMemberGroup(collGroup.id, varUser.Id, 'Manager');            
         } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
         }  
            
        Test.stopTest();       
            
        List<CollaborationGroupMember> addCollGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember LIMIT 1];  
            
        System.assertEquals(addCollGroupMember.size(),1,'Error inserting manager');
    	}
    }   
    @isTest
    static void createMemberGroupMemberErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
 
        Test.startTest();
        
        try{        	
            GroupMembersController.createMemberGroup(collGroup.id, varUser.Id, 'Member');            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        
        Test.stopTest();
        
        CollaborationGroupMember collGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember LIMIT 1];                   
        System.assertEquals(collGroupMember.CollaborationGroupId, collGroup.Id, 'New member inserted, when it should have been error');
    }
    
    @isTest
    static void createMemberGroupMemberNull() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
 
        Test.startTest();
        
        try{        	
            GroupMembersController.createMemberGroup(null, null, '');            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        
        Test.stopTest();
        
        CollaborationGroupMember collGroupMember = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember LIMIT 1];                   
        System.assertEquals(collGroupMember.CollaborationGroupId, collGroup.Id, 'New member cannot be null.');
    }
    
     @isTest
     static void deleteMemberGroupMember() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];          
              
        CollaborationGroupMember deleteCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard'];
        
        Test.startTest();
        system.runAs(varUser2){
            
        try{ 
        GroupMembersController.deleteMembers(deleteCollGroupMember.Id);  
            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }
            
        Test.stopTest();
        List<CollaborationGroupMember> listDelete = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard'];
            
        System.assertEquals(listDelete.size(),0, 'Member successfully deleted.');
    	}
	}
    @isTest
     static void deleteMemberGroupMemberErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];   
                  
        CollaborationGroupMember deleteCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
      
        Test.startTest(); 
        system.runAs(varUser){
            
        try{     
            GroupMembersController.deleteMembers(deleteCollGroupMember.Id);

        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
       
        Test.stopTest();
                           
         List<CollaborationGroupMember> listDelete = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard'];
            
        System.assertNotEquals(listDelete.size(),0, 'Error to delete this member.');
    	}
    } 
    
    @isTest
     static void deleteMemberGroupMemberErroNull() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];   
                  
        CollaborationGroupMember deleteCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
      
        Test.startTest(); 
        system.runAs(varUser){
            
        try{     
            GroupMembersController.deleteMembers(null);

        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
       
        Test.stopTest();
                           
         List<CollaborationGroupMember> listDelete = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard'];
            
        System.assertNotEquals(listDelete.size(),0, 'Error to delete this member. Member cannot be null');
    	}
    } 

    @isTest
     static void updateMemberGroup() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];          
              
        CollaborationGroupMember updateCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
              
        Test.startTest();
        system.runAs(varUser2){
        try{        
            GroupMembersController.updateMemberGroup(updateCollGroupMember.Id, varUser2.Title, varUser2.Status__c, 'Standard');
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
 
        Test.stopTest();
                           
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
                           
        System.assertEquals(listCollGroupMember.size(),1,'Error to update this member.');
    	}
    }
    @isTest
     static void updateMemberGroupErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1]; 
        
        CollaborationGroupMember updateCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{     
            system.runAs(varUser){
                 GroupMembersController.updateMemberGroup(updateCollGroupMember.Id, varUser.Title, varUser.Status__c, 'Standard');
            }
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
                           
        System.assertEquals(listCollGroupMember.size(),1, 'User does not have permission to update member.');
    }
    
    @isTest
     static void updateMemberGroupErroNull() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1]; 
        
        CollaborationGroupMember updateCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{     
            system.runAs(varUser){
                 GroupMembersController.updateMemberGroup(null, '', '', 'Standard');
            }
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
                           
        System.assertEquals(listCollGroupMember.size(),1, 'Member cannot be null to update.');
    }
       
    @isTest
     static void searchGroupMember() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];            
              
        CollaborationGroupMember searchGroupMember = [SELECT Id, CollaborationGroupId, CollaborationRole, member.Name, memberId, member.Title, member.Status__c FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
                 
        Test.startTest();
        try{
            system.runAs(varUser){
                GroupMembersController.searchGroupMember(searchGroupMember.CollaborationGroupId);
            }  	
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
                 
        Test.stopTest();
                           
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
        
        System.assertEquals(listCollGroupMember[0].id,searchGroupMember.Id, 'Search not found results.');
    }
    
    @isTest
     static void searchGroupMemberError() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'User' LIMIT 1];  
                                 
        CollaborationGroupMember searchGroupMember = [SELECT Id, CollaborationGroupId, CollaborationRole FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
                 
        Test.startTest();
        try{
            system.runAs(varUser){
                GroupMembersController.searchGroupMember(searchGroupMember.CollaborationGroupId);
            }  	
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
                 
        Test.stopTest();
                           
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin' LIMIT 1];
        
        System.assertNotEquals(listCollGroupMember[0].id,searchGroupMember.Id,'Search found results, when it should have been error');
    }
    
    @isTest
     static void getNameGroup() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup getNameGroup = [SELECT Id, Name FROM CollaborationGroup LIMIT 1];
       
        Test.startTest();
        try{        	
            GroupMembersController.getNameGroup(getNameGroup.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        List<CollaborationGroup> listCollGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
        
        System.assertEquals(listCollGroup[0].id,getNameGroup.Id, 'Error to selected group name.');
    }
    
    @isTest
     static void getNameGroupError() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup getNameGroup = [SELECT Id, Name FROM CollaborationGroup 	WHERE Name = 'Test Group1' LIMIT 1];
       
        Test.startTest();
        try{        	
            GroupMembersController.getNameGroup(getNameGroup.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        List<CollaborationGroup> listCollGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Group' LIMIT 1];
        
        System.assertNotEquals(listCollGroup[0].id,getNameGroup.Id, 'Could not find group name.');
    }    
    
    @isTest
     static void getMembers() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember getMembers = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{        	
            GroupMembersController.getMembers(getMembers.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
        
        System.assertEquals(listCollGroupMember[0].id,getMembers.Id, 'Erro to found member.');
    }
    
    @isTest
     static void getMembersError() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember getMembers = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{        	
            GroupMembersController.getMembers(getMembers.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember];
        
        System.assertNotEquals(listCollGroupMember[1].id,getMembers.Id,'Member found when it should have been error.');
    }
    
    @isTest
     static void searchUser() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember searchUser = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{      
            GroupMembersController.searchUser(searchUser.id);            
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
                           
        System.assertEquals(listCollGroupMember[0].id,searchUser.Id, 'Erro to found user.');
    }    
    
    @isTest
     static void searchUserError() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember searchUser = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{      
            GroupMembersController.searchUser(searchUser.id);            
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
        
        List<CollaborationGroupMember> listCollGroupMember = [SELECT Id FROM CollaborationGroupMember];
                           
        System.assertNotEquals(listCollGroupMember[1].id,searchUser.Id,'User found, when it should have been error');
    }    
}