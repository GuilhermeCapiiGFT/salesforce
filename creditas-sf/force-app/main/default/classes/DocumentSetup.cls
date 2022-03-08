@isTest
public with sharing class DocumentSetup {
    
    public static Documents__c generateDocment(String accountId, String documentType){
        Documents__c document = new Documents__c(
            Account__c = accountId,
            DocumentType__c = documentType,
            RecordTypeId = Util.getRecordTypeIdbyName('Documents__c', documentType),
            IssueDate__c = Date.today(),
            IssuerState__c = 'SP',
            DocumentNumber__c = DocumentGenerator.generateCPF(),
            Issuer__c = 'SSP');
        
        return document;
    }
}