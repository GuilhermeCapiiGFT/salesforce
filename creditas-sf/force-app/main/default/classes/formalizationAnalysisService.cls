public with sharing class formalizationAnalysisService {

    public static String  getAccountIdFromOpp(String aOppId){
        return [SELECT AccountId FROM Opportunity WHERE Id = :aOppId]?.AccountId;
    }

    public static Account getAccount(String accountId){
        Set<String> documentsRTSet = new Set<String>{
            Util.getRecordTypeIdbyName('Documents__c', 'RG'),
            Util.getRecordTypeIdbyName('Documents__c', 'PIS'),
            Util.getRecordTypeIdbyName('Documents__c', 'CPF')
        };
        Account AccountWithDocumentsAddressesAndCommContacts = [SELECT FirstName__c, Mother__c, BirthDate__c, Gender__c, DocumentNumber__c, CivilStatus__c, RecordTypeId, ExternalCreationDate__c, //AdmissionDate__c,
                            ExternalUpdatedDate__c, BankName__c, Agency__c, BankAccountNumber__c, CompanyName__c, CompanyCNPJ__c, CompanyStatus__c, //Margin__c,
                            (SELECT DocumentNumber__c, Issuer__c, IssuerState__c, IssueDate__c,DocumentType__c FROM Documentos__r WHERE RecordTypeId IN :documentsRTSet),
                            (SELECT PostalCode__c, Street__c, StreetNumber__c,Complement__c,Neighborhood__c, AreaLevel2__c, AreaLevel1__c FROM Enderecos__r WHERE Type__c = 'HOME'),
                            (SELECT Code__c, Channel__c FROM CommunicationContacts__r WHERE Channel__c = 'EMAIL' OR Channel__c = 'SMS')
                            FROM Account 
                            WHERE Id = :accountId LIMIT 1];
        return AccountWithDocumentsAddressesAndCommContacts;
    }

    public static List<PicklistWrapper> getPickListValues(String objApiName, String fieldApiName){
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<pickListWrapper> picklist = new List<pickListWrapper>();
        for(Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()){

            picklist.add(new pickListWrapper((String) picklistEntry.getLabel(), (String) picklistEntry.getValue()));
        }
        return picklist;
    }

    public class PicklistWrapper{
        public String label;
        public String value;
        public PicklistWrapper(String aLabel, String aValue){
            this.label = aLabel;
            this.value = aValue;
        }
    }

}