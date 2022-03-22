/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Class for calling the methods created in GroupMembersService for the LWC component of GroupMembers
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           24/11/2021      Created     Class for calling the methods created in GroupMembersService 
                                                                for the LWC component of GroupMembers 
  1.1       Nathalia Rosa           28/02/2022      Updated     Name changed from GroupMembersLWC to GroupMembersController                                                            
**********************************************************************************************************************************/
public class GroupMembersController {
    @AuraEnabled(cacheable=true)
    public static List<GroupMembersResponse> searchGroupMember ( String idGroup){
       List<GroupMembersResponse> response = GroupMembersService.searchGroupMember(idGroup);
       return response;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<CollaborationGroupMember> getMembers( String idMember){
        return [SELECT CollaborationGroupId, CollaborationRole, member.Name, memberId, member.Title, member.Status__c 
                                                          FROM CollaborationGroupMember
                                                          WHERE CollaborationGroupId =: idMember]; 
    }
    
    @AuraEnabled
    public static string deleteMembers(String memberId){
        return GroupMembersService.deleteMembers(memberId);        
    }    

   @AuraEnabled(cacheable=true) 
   public static string getNameGroup(id idGroup){
     return GroupMembersService.getNameGroup(idGroup);
    }
    
   @AuraEnabled
   public static string createMemberGroup(string idGroup, string idUser, string role){
      return GroupMembersService.createMemberGroup(idGroup, idUser, role);
       
   }
   @AuraEnabled
    public static string updateMemberGroup(string idMemberGroup, string title, string status, string role){
        return GroupMembersService.updateMemberGroup(idMemberGroup, title, status, role);
        
    }    
    
    @AuraEnabled (cacheable = true)
    public static List<User> searchUser(String searchKey) {
         return [SELECT Id, Name FROM User WHERE Name LIKE: '%' + searchKey + '%' ];
    }    
}