public with sharing class formalizationAnalysisService {

    public static String  getAccountIdFromOpp(String aOppId){
        return [SELECT AccountId FROM Opportunity WHERE Id = :aOppId]?.AccountId;
    }

    public static Account getAccount(String aAccountId){
        Set<String> lDocumentsRTSet = new Set<String>();
        String lDocumentRGRecordType = Util.getRecordTypeIdbyName('Documents__c', 'RG');
        String lDocumentPISRecordType = Util.getRecordTypeIdbyName('Documents__c', 'PIS');
        String lDocumentCPFRecordType = Util.getRecordTypeIdbyName('Documents__c', 'CPF');
        lDocumentsRTSet.add(lDocumentRGRecordType);
        lDocumentsRTSet.add(lDocumentPISRecordType);
        lDocumentsRTSet.add(lDocumentCPFRecordType);
        Account lAcc = [SELECT FirstName__c, Mother__c, BirthDate__c, Gender__c, DocumentNumber__c, CivilStatus__c, ExternalCreationDate__c, AdmissionDate__c,
                            ExternalUpdatedDate__c, BankName__c, Agency__c, BankAccountNumber__c, CompanyName__c, CompanyCNPJ__c, CompanyStatus__c, Margin__c,
                            (SELECT DocumentNumber__c, Issuer__c, IssuerState__c, IssueDate__c,DocumentType__c FROM Documentos__r WHERE RecordTypeId IN :lDocumentsRTSet),
                            (SELECT PostalCode__c, Street__c, StreetNumber__c,Complement__c,Neighborhood__c, AreaLevel2__c, AreaLevel1__c FROM Enderecos__r WHERE Type__c = 'HOME'),
                            (SELECT Code__c, Channel__c FROM CommunicationContacts__r WHERE Channel__c = 'EMAIL' OR Channel__c = 'SMS')
                            FROM Account 
                            WHERE Id = :aAccountId LIMIT 1];
        return lAcc;
    }

}