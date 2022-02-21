public with sharing class ProposalContractController {
    @AuraEnabled(cacheable=true)
    public static string getRelatedFilesByRecordId(String recordId) {

        List<ContentDocumentLink> files = new List<ContentDocumentLink>();
        files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        if(files.isEmpty()) return '';

        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
    
        ContentVersion doc = [SELECT ContentDocumentId, FileExtension, Title 
                                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs ORDER BY CreatedDate DESC LIMIT 1
                            ];

        return doc != null ? doc.ContentDocumentId : '';
    }
}