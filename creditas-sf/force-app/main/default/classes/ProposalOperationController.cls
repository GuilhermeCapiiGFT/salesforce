public with sharing class ProposalOperationController {
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, SObject> getOperationDetails(Id opportunityId){
        try {
            Map<String, SObject> operationInfo  = new Map<String, SObject>();

            OperationSection__c validationInfo = ProposalOperationService.getOperationSectionFromOpp(opportunityId);
            Quote quoteInfo = ProposalOperationService.getQuoteFromOpp(opportunityId);
            FinancialResources__c FinancialInfo = ProposalOperationService.getFinancialFromOpp(opportunityId);
            Account proponentInfo = ProposalOperationService.getProponentFromOpp(opportunityId);
            
            operationInfo.put('OperationSection', validationInfo);
            operationInfo.put('Quote', quoteInfo);
            operationInfo.put('Financial', FinancialInfo);
            operationInfo.put('Proponent', proponentInfo);

            return operationInfo;
        } catch(Exception e) {
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void saveOperationDetails(Map<String, SObject> records){
        SavePoint sp = Database.setSavePoint();
        try {
            Quote quote = (Quote) records.get('Quote');
            OperationSection__c validation = (OperationSection__c) records.get('OperationSection');
            FinancialResources__c Financial = (FinancialResources__c) records.get('Financial');
            Account proponent = (Account) records.get('Proponent');

            SObjectUtils.upsertRecord(quote);
            SObjectUtils.upsertRecord(Financial);
            SObjectUtils.upsertRecord(validation);
            SObjectUtils.upsertRecord(proponent);

        } catch(Exception e) {
            Database.rollback(sp);
            throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
        }
    }
}