/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Classe de teste para o Componente LWC - GroupMember 
  (Abrange as classes: GroupMembersLWC, GroupMembersService e GroupMember Response)
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa          01/12/2021      Created     Classe de teste para as classes do Componente LWC - GroupMember
**********************************************************************************************************************************/
@isTest
public class GroupMembersLWCTest {        
    
    @TestSetup
    static void makeData()
    {   
        Profile profile = [SELECT Id FROM Profile WHERE Name in ('System Administrator', 'Administrador do Sistema') LIMIT 1];
        
        //Create User
        User newUser = TestSetup.getUser(true);
		newUser.ProfileId = profile.Id;
        newUser.LastName = 'Usuario';
		update newUser;    
        
        User newUser2 = TestSetup.getUser(true);
		newUser2.ProfileId = profile.Id;
        newUser2.LastName = 'Manager';
        newUser2.Title = 'Analista';
        newUser2.Status__c = 'Ativo';
		update newUser2; 
        
        User newUser3 = TestSetup.getUser(true);
		newUser3.ProfileId = profile.Id;
        newUser3.LastName = 'Usuario 2';
		update newUser3; 
                
        system.runAs(newUser){
        //Create Parent Group
        CollaborationGroup grp = new CollaborationGroup();
        grp.name = 'Test Group1';
        grp.CollaborationType = 'Private'; 
        grp.isBroadcast = true;
        Insert grp;  
            
        CollaborationGroupMember collGroup = new CollaborationGroupMember();             
        collGroup.CollaborationRole = 'Standard';   
        collGroup.CollaborationGroupId = grp.Id;
        collGroup.memberId = newUser2.Id;
        insert collGroup;
       }             
    }  
                
    @isTest
    static void createMemberGroupManager() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario 2' LIMIT 1];     
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
      
        Test.startTest();
        //try{
        system.runAs(varUser){
            string gpMember = GroupMembersLWC.createMemberGroup(collGroup.id, varUser2.Id, 'Manager');
        }        	
                        
        //} catch (DMLException e) {
    	//	System.debug('The following exception has occurred: ' + e.getMessage());
       // }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
    static void createMemberGroupMemberErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup collGroup = [SELECT Id FROM CollaborationGroup LIMIT 1];
      
        Test.startTest();
        try{        	
            GroupMembersLWC.createMemberGroup(collGroup.id, varUser.Id, 'Member');            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
     @isTest
     static void deleteMemberGroupMember() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario 2' LIMIT 1];          
              
        CollaborationGroupMember deleteCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
      
        Test.startTest();
        system.runAs(varUser){
             GroupMembersLWC.deleteMembers(deleteCollGroupMember.Id);     
        }    	
  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void deleteMemberGroupMemberErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1];   
                
              
        CollaborationGroupMember deleteCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
      
        Test.startTest();     
        try{     
            system.runAs(varUser){
                GroupMembersLWC.deleteMembers(deleteCollGroupMember.Id);
            }
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void deleteMemberGroupMemberNull() 
    {   
        
        Test.startTest();     
        
        GroupMembersLWC.deleteMembers('');            
  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }

    @isTest
     static void updateMemberGroupMember() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];          
              
        CollaborationGroupMember updateCollGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
              
        Test.startTest();
        //try{     
            system.runAs(varUser){
                 GroupMembersLWC.updateMemberGroup(updateCollGroupMember.Id, varUser2.Title, varUser2.Status__c, 'Standard');
            }
           
        //} catch (DMLException e) {
    	//	System.debug('The following exception has occurred: ' + e.getMessage());
        //}  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void updateMemberGroupMemberErro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1]; 
        
              
        CollaborationGroupMember updateCollGroupMember = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{     
            system.runAs(varUser){
                 GroupMembersLWC.updateMemberGroup(updateCollGroupMember.Id, varUser.Title, varUser.Status__c, 'Standard');
            }
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void updateMemberGroupMemberNull() 
    {       
            
        Test.startTest();
        
        GroupMembersLWC.updateMemberGroup(null, '', '', '');
              
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void buscarGrupoMembro() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Usuario' LIMIT 1];    
        User varUser2 = [SELECT Id, Title, Status__c FROM User WHERE LastName = 'Manager' LIMIT 1];            
              
        CollaborationGroupMember searchGroupMember = [SELECT Id, CollaborationGroupId, CollaborationRole, member.Name, memberId, member.Title, member.Status__c FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' LIMIT 1];
                 
        Test.startTest();
        system.runAs(varUser){
            GroupMembersLWC.buscarGrupoMembro(searchGroupMember.CollaborationGroupId);
        }  	
                 
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void getNameGroup() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroup getNameGroup = [SELECT Id, Name FROM CollaborationGroup LIMIT 1];
       
        Test.startTest();
        try{        	
            GroupMembersLWC.getNameGroup(getNameGroup.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void getMembers() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember getMembers = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{        	
            GroupMembersLWC.getMembers(getMembers.id);            
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }
    
    @isTest
     static void searchUser() 
    {   
        User varUser = [SELECT Id, Title, Status__c FROM User LIMIT 1];        
              
        CollaborationGroupMember searchUser = [SELECT Id FROM CollaborationGroupMember LIMIT 1];
              
        Test.startTest();
        try{      
            GroupMembersLWC.searchUser(searchUser.id);            
           
        } catch (DMLException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        Test.stopTest();
                           
        //System.assertEquals(2,listGroupMember.size());
    }    
}