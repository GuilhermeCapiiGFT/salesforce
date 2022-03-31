public with sharing class AccountEmployeeIntegrationService {
  public class AccountEmployeeIntegrationException extends Exception {
  }

  public class AccountNotFoundException extends Exception {
  }

  RestRequest request;
  AccountEmployeeIntegrationVO requestBodyObject;
  Integer statusCode;
  String message;

  String companyExternalId {
    get {
      return this.requestBodyObject.companyId;
    }
  }
  String personExternalId {
    get {
      return this.requestBodyObject.personId;
    }
  }
  String employeeExternalId {
    get {
      return this.requestBodyObject.id;
    }
  }

  public AccountEmployeeIntegrationService(RestRequest request) {
    this.request = request;
  }

  public void processRequest() {
    try {
      this.parseBody();
      this.checkRequiredFields();
      this.checkAccounts();
      this.upsertEmployee();
      this.setStatusAndMessage(200, 'Record created/updated successfully.');
    } catch (AccountEmployeeIntegrationException e) {
      this.setStatusAndMessage(400, e.getMessage());
    } catch (AccountNotFoundException e) {
      this.setStatusAndMessage(500, e.getMessage());
    } catch (Exception e) {
      this.setStatusAndMessage(400, 'Error: couldn\'t process request.');
    }
  }

  public Integer getStatusCode() {
    return this.statusCode;
  }

  public String getMessage() {
    return this.message;
  }

  private void setStatusAndMessage(Integer code, String message) {
    this.statusCode = code;
    this.message = message;
  }

  private void parseBody() {
    try {
      this.requestBodyObject = (AccountEmployeeIntegrationVO) System.JSON.deserialize(
        this.request.requestBody.toString(),
        AccountEmployeeIntegrationVO.class
      );
    } catch (Exception e) {
      throw new AccountEmployeeIntegrationException('Error: JSON parse failed.', e);
    }
  }

  private void checkRequiredFields() {
    for (String id : new List<String>{ this.companyExternalId, this.personExternalId, this.employeeExternalId }) {
      if (String.isBlank(id)) {
        throw new AccountEmployeeIntegrationException('Error: required field(s) missing (companyId, personId or id)');
      }
    }
  }

  private void upsertEmployee() {
    String employeeName = getEmployeeNameByExternalId(this.employeeExternalId);
    if (String.isBlank(employeeName)) {
      employeeName = this.employeeExternalId;
    }

    Employee__c employee = new Employee__c(
      Name = employeeName,
      PersonAccount__r = new Account(ExternalId__c = this.personExternalId),
      Company__r = new Account(ExternalId__c = this.companyExternalId),
      Type__c = this.requestBodyObject.employeeType,
      Status__c = this.requestBodyObject.status,
      AdmissionDate__c = this.getParsedDate(this.requestBodyObject.admissionDate),
      Margin__c = this.requestBodyObject.margin.amount,
      Salary__c = this.requestBodyObject.salary.amount,
      ExternalId__c = this.employeeExternalId,
      ExternalVersion__c = Decimal.valueOf(this.requestBodyObject.version),
      ExternalTenant__c = this.requestBodyObject.tenant
    );

    try {
      upsert employee ExternalId__c;
    } catch (Exception e) {
      throw new AccountEmployeeIntegrationException('Error: Employee record creation/update failed.', e);
    }
  }

  private void checkAccounts() {
    Map<String, Boolean> statusByAccountExternalId = new Map<String, Boolean>{
      this.personExternalId => false,
      this.companyExternalId => false
    };

    for (Account account : this.getAccountsByExternalIds(statusByAccountExternalId.keySet())) {
      statusByAccountExternalId.put(account.ExternalId__c, true);
    }

    if (!statusByAccountExternalId.get(this.personExternalId)) {
      throw new AccountNotFoundException('Error: account record not found for the provided personId.');
    }

    if (!statusByAccountExternalId.get(this.companyExternalId)) {
      throw new AccountNotFoundException('Error: account record not found for the provided companyId.');
    }
  }

  private List<Account> getAccountsByExternalIds(Set<String> externalIds) {
    return [SELECT ExternalId__c FROM Account WHERE ExternalId__c IN :externalIds];
  }

  private String getEmployeeNameByExternalId(String externalId) {
    return [SELECT Name FROM Employee__c WHERE ExternalId__c = :externalId]?.Name;
  }

  private Date getParsedDate(String dateString) {
    if (String.isBlank(dateString)) {
      return null;
    }

    try {
      list<String> dateParts = dateString.split('-');

      return date.newinstance(
        Integer.valueOf(dateParts[0]),
        Integer.valueOf(dateParts[1]),
        Integer.valueOf(dateParts[2])
      );
    } catch (Exception e) {
      throw new AccountEmployeeIntegrationException('Error: couldn\'t parse date string: ' + dateString + '.', e);
    }
  }
}