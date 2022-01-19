/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Classe para chamada dos métodos criados em GroupMembersService para o componente LWC de GroupMembers
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           24/11/2021      Created     Classe para chamada dos métodos criados em GroupMembersService
                                                                para o componente LWC de GroupMembers 
**********************************************************************************************************************************/
public class GroupMembersLWC {
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