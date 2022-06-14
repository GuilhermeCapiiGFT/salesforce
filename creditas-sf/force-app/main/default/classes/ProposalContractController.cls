public with sharing class ProposalContractController {
  
  @AuraEnabled
  public static Integer sendContract(String loanApplicationId) {
    try {
      ProposalContractService request = new ProposalContractService();
      request.sendContract(loanApplicationId);
      return request.getStatusCode();
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }

  @AuraEnabled
  public static Integer generateContract(String loanApplicationId) {
    try {
      ProposalContractService request = new ProposalContractService();
      request.generateContract(loanApplicationId);
      return request.getStatusCode();
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }

  @AuraEnabled
  public static String viewContract(String loanApplicationId) {
    try {
      ProposalContractService request = new ProposalContractService();
      String base64 = request.viewContract(loanApplicationId);
      return base64;
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }
}