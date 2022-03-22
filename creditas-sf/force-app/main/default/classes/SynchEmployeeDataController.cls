public with sharing class SynchEmployeeDataController {
  @AuraEnabled
  public static void updateSynchingFields(Id employeeId) {
    try {
      SynchEmployeeDataService.updateSynchingFields(employeeId);
    } catch (Exception e) {
      throw AuraHandledExceptionHelper.auraExceptionBuilder(e);
    }
  }
}