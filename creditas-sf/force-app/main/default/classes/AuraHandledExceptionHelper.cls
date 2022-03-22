public inherited sharing class AuraHandledExceptionHelper {
  public static AuraHandledException auraExceptionBuilder(Exception rootException) {
    AuraHandledException e = new AuraHandledException(rootException.getMessage());
    e.setMessage(rootException.getMessage());
    e.initCause(rootException);
    return e;
  }
}