public with sharing class DocumentApiController {
  class DocumentApiControllerException extends Exception {
  }

  @AuraEnabled(cacheable=true)
  public static DocumentApiResponseVO getDocuments(
    String opportunityExternalId,
    String recordTypeName
  ) {
    try {
      DocumentApiService documentApi = new DocumentApiService();
      documentApi.setLoanApplicationId(opportunityExternalId);
      documentApi.setRecordTypeName(recordTypeName);
      documentApi.sendRequest();
      DocumentApiResponseVO responseObject = documentApi.getResponseObject();
      return responseObject;
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }
}