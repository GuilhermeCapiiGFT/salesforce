public with sharing class AccountIntegrationService {
  class AccountIntegrationServiceException extends Exception {
    String detailedMessage;

    public String getDetailedMessage() {
      return this.detailedMessage;
    }

    public void setDetailedMessage(String message) {
      this.detailedMessage = message;
    }
  }

  class TestException extends Exception {
  }

  @TestVisible
  static Boolean isExceptionTest = false;

  static AccountIntegrationServiceException createAISException(
    String message,
    String detailedMessage
  ) {
    AccountIntegrationServiceException aisException = new AccountIntegrationServiceException(
      message
    );
    aisException.setDetailedMessage(detailedMessage);
    return aisException;
  }

  static AccountIntegrationServiceException createAISException(String message) {
    return createAISException(message, message);
  }

  String requestBodyString;
  String upsertedAccountId;
  AccountIntegrationRequestVO requestBodyObject;
  AccountIntegrationResponseVO responseBodyObject;

  public Blob getResponseBodyAsBlob() {
    return Blob.valueOf(JSON.serialize(this.responseBodyObject));
  }

  public void setRequestBody(String json) {
    this.requestBodyString = json;
  }

  public void upsertData() {
    this.upsertedAccountId = null;
    try {
      if (isExceptionTest) {
        throw new TestException('This is a test exception.');
      }
      this.parseRequestBody();
      this.validateData();
      this.upsertRecords();
      this.setResponse(200, 'Account upserted.');
    } catch (AccountIntegrationServiceException aisException) {
      this.handleAISException(aisException);
    } catch (Exception e) {
      this.handleException(e);
    }
  }

  void parseRequestBody() {
    this.requestBodyObject = AccountIntegrationRequestVO.parse(this.requestBodyString);
    if (this.requestBodyObject.hasError) {
      throw createAISException('Invalid JSON format.', this.requestBodyObject.errorMessage);
    }
  }

  void validateData() {
    if (this.requestBodyObject.professionalInfo != null) {
      for (
        AccountIntegrationRequestVO.ProfessionalInfo professionalInfo : this.requestBodyObject.professionalInfo
      ) {
        if (
          professionalInfo.professionalIncome != null &&
          professionalInfo.professionalIncome.size() > 1
        ) {
          throw createAISException(
            'Each Professional Info must have only one professional income.'
          );
        }
      }
    }

    if (
      this.requestBodyObject.mainDocument == null ||
      String.isBlank(this.requestBodyObject.mainDocument.code)
    ) {
      throw createAISException('Main Document can\'t be null.');
    }
  }

  void upsertRecords() {
    this.upsertedAccountId = this.upsertAccount();
  }

  Id upsertAccount() {
    Account account = this.getAccount();
    try {
      // upsert account ExternalId__c;
      upsert account;
      return account.Id;
    } catch (Exception e) {
      throw createAISException('An error has occurred upserting Account object.', e.getMessage());
    }
  }

  Account getAccount() {
    Account account = new Account();
    account.ExternalId__c = this.requestBodyObject.id;
    account.Name = this.requestBodyObject.fullName;
    account.Gender__c = this.requestBodyObject.gender;
    account.ExternalTenant__c = this.requestBodyObject.tenant;
    account.ExternalModifiedBy__c = this.requestBodyObject.modifiedBy;
    account.CivilStatus__c = this.requestBodyObject.civilStatus;
    account.Birth_City__c = this.requestBodyObject.cityOfBirth;
    account.Birth_Country__c = this.requestBodyObject.countryOfBirth;
    account.Nationality__c = this.requestBodyObject.nationality;

    if (String.isNotBlank(this.requestBodyObject.birthDate)) {
      account.BirthDate__c = Date.valueOf(this.requestBodyObject.birthDate);
    }

    if (String.isNotBlank(this.requestBodyObject.createdAt)) {
      account.ExternalCreationDate__c = Date.valueOf(this.requestBodyObject.createdAt);
    }

    if (String.isNotBlank(this.requestBodyObject.updatedAt)) {
      account.ExternalUpdatedDate__c = Date.valueOf(this.requestBodyObject.updatedAt);
    }

    account.ExternalVersion__c = this.requestBodyObject.version;
    account.DocumentType__c = this.requestBodyObject.mainDocument.type;
    account.DocumentNumber__c = this.requestBodyObject.mainDocument.code;

    if (this.requestBodyObject.additionalProperties != null) {
      account.FirstName__c = this.requestBodyObject.additionalProperties.firstName;
      account.SecondName__c = this.requestBodyObject.additionalProperties.secondName;
      account.LastName__c = this.requestBodyObject.additionalProperties.lastName;
      account.SecondLastName__c = this.requestBodyObject.additionalProperties.secondLastName;
      account.Curp__c = this.requestBodyObject.additionalProperties.curp;
      account.IneNumber__c = this.requestBodyObject.additionalProperties.ineNumber;
      account.BankName__c = this.requestBodyObject.additionalProperties.bankName;
      account.BankAccountNumber__c = this.requestBodyObject.additionalProperties.accountNumber;
      account.Clabe__c = this.requestBodyObject.additionalProperties.clabe;

      account.PoliticallyExposed__c = this.requestBodyObject.additionalProperties.politicallyExposed ==
        null
        ? false
        : this.requestBodyObject.additionalProperties.politicallyExposed;
    }

    if (this.requestBodyObject.education != null) {
      account.Education__c = this.requestBodyObject.education.degree;
    }

    if (this.requestBodyObject.wealth != null) {
      if (String.isNotBlank(this.requestBodyObject.wealth.networthLowerLimit)) {
        account.NetWorthLowerLimit__c = decimal.valueof(
          this.requestBodyObject.wealth.networthLowerLimit
        );
      }

      if (String.isNotBlank(this.requestBodyObject.wealth.networthUpperLimit)) {
        account.NetWorthUpperLimit__c = decimal.valueof(
          this.requestBodyObject.wealth.networthUpperLimit
        );
      }

      if (String.isNotBlank(this.requestBodyObject.wealth.currencyCode)) {
        account.CurrencyIsoCode = this.requestBodyObject.wealth.currencyCode;
      }
    }

    account.Id = this.getAccountId();
    account.IsExternallySynched__c = true;
    account.IsSynchEnabled__c = 'ENABLED';
    return account;
  }

  Id getAccountId() {
    String externalId = this.requestBodyObject.id;
    Id accountId = [
      SELECT Id
      FROM Account
      WHERE ExternalId__c = :externalId AND ExternalId__c != NULL
      LIMIT 1
    ]
    ?.Id;

    if (accountId == null) {
      String docNumber = this.requestBodyObject.mainDocument.type == 'CPF'
        ? Util.getMaskedCPF(this.requestBodyObject.mainDocument.code)
        : this.requestBodyObject.mainDocument.code;

      accountId = [SELECT Id FROM Account WHERE DocumentNumber__c = :docNumber LIMIT 1]?.Id;
    }

    return accountId;
  }

  // void upsertContacts() {
  // }

  // void upsertAddresses() {
  // }

  // void upsertRelationships() {
  // }

  // void upsertDocuments() {
  // }

  // void upsertIncome() {
  // }

  // void upsertProfessionalInfo() {
  // }

  // void upsertFiliation() {
  // }

  void handleAISException(AccountIntegrationServiceException aisException) {
    this.setResponse(500, aisException.getMessage());
    this.insertErrorLog(500, aisException.getDetailedMessage());
  }

  void handleException(Exception e) {
    this.setResponse(
      500,
      'An unexpected error has occurred. Please, contact a Salesforce administrator.'
    );
    this.insertErrorLog(500, e.getMessage());
  }

  void insertErrorLog(Integer statusCode, String message) {
    API_Transaction_Errors__b ate = new API_Transaction_Errors__b();
    ate.Endpoint__c = '/services/apexrest/IntegrationAccountIN';
    ate.RequestBody__c = this.requestBodyString;
    ate.ReturnCode__c = statusCode;
    ate.ErrorMessage__c = message;
    ate.CreatedDate__c = System.now();
    ate.CreatedBy__c = UserInfo.getUserId();
    if (!Test.isRunningTest()) {
      database.insertImmediate(ate);
    }
  }

  void setResponse(Integer statusCode, String message) {
    this.responseBodyObject = new AccountIntegrationResponseVO();
    this.responseBodyObject.accountId = this.upsertedAccountId;
    this.responseBodyObject.message = message;
    this.responseBodyObject.status = statusCode;
  }
}