/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description  Classe que contém os métodos para o componente LWC de GroupMembers
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           24/11/2021      Created     Classe que contém os métodos para o componente LWC de GroupMembers 
**********************************************************************************************************************************/
public class GroupMembersService {
     public static List<GroupMembersResponse> buscarGrupoMembro ( String idGroup){
        List<CollaborationGroupMember> listGroupMember = [SELECT CollaborationGroupId, CollaborationRole, member.Name, memberId, member.Title, member.Status__c 
                                                          FROM CollaborationGroupMember
                                                          WHERE CollaborationGroupId =: idGroup];
                                    
         List<GroupMembersResponse> listInformacoes = new List<GroupMembersResponse>();
         
         for(CollaborationGroupMember userMember : listGroupMember){
             GroupMembersResponse informacao = new GroupMembersResponse();
             informacao.title = userMember.member.title;
             informacao.status = userMember.member.status__c;
             informacao.userId = userMember.memberId;
             informacao.role = userMember.CollaborationRole;
             informacao.nameUrl = 'https://creditas--devhub.lightning.force.com/'+usermember.memberId;
             informacao.name = usermember.member.Name;
             informacao.memberGroupId = userMember.Id;
             
         	 listInformacoes.add(informacao);             
         }                          
           system.debug('membro ' + JSON.serializePretty(listInformacoes));
         
         return listInformacoes;         
     }
    
    public static string getNameGroup (id idGroup){
        
        CollaborationGroup collaborationGroup = [SELECT Name FROM CollaborationGroup WHERE id =: idGroup];
        return CollaborationGroup.Name;
    }
    
    public static string createMemberGroup(string idGroup, string idUser, string role){
        
       	CollaborationGroupMember collGroup = new CollaborationGroupMember();
        
        if(role == 'Manager'){
            collGroup.CollaborationRole = 'Admin';
        } else if(role == 'Member'){
            collGroup.CollaborationRole = 'Standard';
        }
        
        collGroup.CollaborationGroupId = idGroup;
        collGroup.memberId = idUser;
        
       try{
            insert collGroup;
            return 'success';            
        }catch (Exception e){
             system.debug('error: ' + e.getMessage());
            return 'error';
        }       
   }
    
    public static string updateMemberGroup(string idMemberGroup, string title, string status, string role){
        
         List<CollaborationGroupMember> listGroupMember = [SELECT Id, CollaborationRole, member.Name, memberId, member.Title, member.Status__c 
                                                          FROM CollaborationGroupMember
                                                          WHERE Id =: idMemberGroup];
        if(listGroupMember.size() == 1){
            listGroupMember[0].CollaborationRole = role;
            
            User usuario = [SELECT id, Status__c, Title FROM User WHERE id =: listGroupMember[0].memberId];
            
            usuario.Title = title;
            usuario.Status__c = status;      
            
            try{
                update listGroupMember[0]; 
                update usuario;
                return 'success';            
            }catch (Exception e){
          		return 'error';
            }          		
        }
        
        return '';        
    }
    
        public static string deleteMembers(String memberId){
        
        List<CollaborationGroupMember> listGroupMember = [SELECT id FROM CollaborationGroupMember WHERE id =: memberId];
        
        if(listGroupMember.size() == 1){
            try {
            	delete listGroupMember[0];
                return 'success';
            
            }
            catch(Exception ex) {
                return 'error';
            }
        }     
        return '';
        
    }     
 }