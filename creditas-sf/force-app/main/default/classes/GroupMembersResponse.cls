public class GroupMembersResponse {
        
        @AuraEnabled public string title {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public id userId {get;set;}
        @AuraEnabled public string role {get;set;}
    	@AuraEnabled public string name {get;set;}
   	@AuraEnabled public string nameUrl {get;set;}
        @AuraEnabled public string memberGroupId {get;set;}     
}