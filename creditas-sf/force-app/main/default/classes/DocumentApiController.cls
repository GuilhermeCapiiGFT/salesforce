public with sharing class DocumentApiController {
  
  @AuraEnabled(cacheable=true)
  public static DocumentApiResponseVO getDocuments(String opportunityExternalId, String recordTypeName) {
    try {
      DocumentApiService documentApi = new DocumentApiService();
      documentApi.setLoanApplicationId(opportunityExternalId);
      documentApi.setRecordTypeName(recordTypeName);
      documentApi.getAuth();
      documentApi.sendRequest();
      DocumentApiResponseVO responseObject = documentApi.getResponseObject();
      return responseObject;
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }
}