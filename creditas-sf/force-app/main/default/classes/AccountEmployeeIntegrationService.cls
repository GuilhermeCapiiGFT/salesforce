public with sharing class AccountEmployeeIntegrationService {
  public class AccountEmployeeIntegrationException extends Exception {
  }

  RestRequest request;
  AccountEmployeeIntegrationVO requestBodyObject;

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
    this.parseBody();
    this.checkRequiredFields();
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

  public void upsertEmployee() {
    this.createAccounts();

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

  private void createAccounts() {
    Id recordTypeIdPessoaFisica = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
    Id recordTypeIdPessoaJuridica = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');

    Set<String> accountsExternalIds = new Set<String>{ this.personExternalId, this.companyExternalId };
    for (Account account : this.getAccountsByExternalIds(accountsExternalIds)) {
      accountsExternalIds.remove(account.ExternalId__c);
    }

    if (!accountsExternalIds.isEmpty()) {
      List<Account> newAccounts = new List<Account>();

      for (String externalId : accountsExternalIds) {
        newAccounts.add(
          new Account(
            Name = externalId,
            RecordTypeId = externalId == this.personExternalId ? recordTypeIdPessoaFisica : recordTypeIdPessoaJuridica,
            ExternalId__c = externalId,
            ExternalTenant__c = this.requestBodyObject.tenant,
            ExternalVersion__c = Decimal.valueOf(this.requestBodyObject.version),
            ExternalCreationDate__c = this.getParsedDateTime(this.requestBodyObject.createdAt),
            ExternalUpdatedDate__c = this.getParsedDateTime(this.requestBodyObject.updatedAt)
          )
        );
      }

      try {
        insert newAccounts;
      } catch (Exception e) {
        throw new AccountEmployeeIntegrationException('Error: Account records creation failed.', e);
      }
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

  private DateTime getParsedDateTime(String dateTimeString) {

    if (String.isBlank(dateTimeString)) {
      return null;
    }

    try {
      List<String> dateTimeParts = dateTimeString.split('T');
      String dateString = dateTimeParts[0];
      String timeString = dateTimeParts[1].split('\\.')[0];
      String parsedDateTime = dateString + ' ' + timeString;

      return DateTime.valueOf(parsedDateTime);
    } catch (Exception e) {
      throw new AccountEmployeeIntegrationException(
        'Error: couldn\'t parse dateTime string ' +
        dateTimeString +
        '.',
        e
      );
    }
  }
}