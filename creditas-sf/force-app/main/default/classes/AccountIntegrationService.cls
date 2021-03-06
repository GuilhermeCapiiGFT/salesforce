public with sharing class AccountIntegrationService {
  private class AccountIntegrationServiceException extends Exception {
    String detailedMessage;

    public String getDetailedMessage() {
      return this.detailedMessage;
    }

    public void setDetailedMessage(String message) {
      this.detailedMessage = message;
    }
  }
  
  private static AccountRepository accRepo = new AccountRepository();

  private static AccountIntegrationServiceException createAISException(String message, String detailedMessage) {
    AccountIntegrationServiceException aisException = new AccountIntegrationServiceException(message);
    aisException.setDetailedMessage(detailedMessage);
    return aisException;
  }

  private static AccountIntegrationServiceException createAISException(String message) {
    return createAISException(message, message);
  }

  private String requestBodyString;
  private String upsertedAccountId;
  private AccountIntegrationRequestVO requestBodyObject;
  private AccountIntegrationResponseVO responseBodyObject;
  private Set<String> newContactsExternalId;
  private Set<String> newAdressesExternalId;
  private Set<String> newRelatioshipsExternalId;
  private Set<String> newDocumentsExternalId;
  private Set<String> newProfessionalInfosExternalId;
  private Set<String> newIncomesExternalId;
  private Set<String> newProfessionalIncomesExternalId;
  private Set<String> newFiliationsNames;

  private Boolean isValidRequest {
    get {
      if (this.requestBodyObject == null || this.requestBodyObject.hasError) {
        return false;
      } else {
        return true;
      }
    }
  }

  public AccountIntegrationResponseVO getResponse() {
    return this.responseBodyObject;
  }

  public Blob getResponseAsBlob() {
    return Blob.valueOf(JSON.serialize(this.responseBodyObject));
  }

  public Integer getStatusCode() {
    return this.responseBodyObject.status;
  }

  public void setRequestBody(String json) {
    this.upsertedAccountId = null;
    this.requestBodyObject = null;
    this.responseBodyObject = null;
    this.requestBodyString = json;
    try {
      this.parseRequestBody();
    } catch (AccountIntegrationServiceException aisException) {
      this.handleAISException(aisException);
    } catch (Exception e) {
      this.handleException(e);
    }
  }

  public void upsertData() {
    this.upsertedAccountId = null;
    if (this.isValidRequest) {
      try {
        this.validateRequestData();
        this.doDMLTransactions();
        this.setResponse(200, 'Account upserted.');
      } catch (AccountIntegrationServiceException aisException) {
        this.handleAISException(aisException);
      } catch (Exception e) {
        this.handleException(e);
      }
    }
  }

  private void parseRequestBody() {
    this.requestBodyObject = AccountIntegrationRequestVO.parse(this.requestBodyString);
    if (this.requestBodyObject.hasError) {
      throw createAISException('Invalid JSON format.', this.requestBodyObject.errorMessage);
    }
  }

  private void validateRequestData() {
    if (this.requestBodyObject.professionalInfo != null) {
      for (AccountIntegrationRequestVO.ProfessionalInfo professionalInfo : this.requestBodyObject.professionalInfo) {
        if (professionalInfo.professionalIncome != null && professionalInfo.professionalIncome.size() > 1) {
          throw createAISException('Each Professional Info must have only one professional income.');
        }
      }
    }

    if (this.requestBodyObject.mainDocument == null || String.isBlank(this.requestBodyObject.mainDocument.code)) {
      throw createAISException('Main Document can\'t be null.');
    }
  }

  private void doDMLTransactions() {
    Account currentAccount = this.selectAccount(this.requestBodyObject.id);
    List<SObject> objectsToUpsert = this.getObjectsToUpsert(currentAccount);
    List<SObject> objectsToDelete = this.getObjectsToDelete(currentAccount);

    Savepoint savePoint = Database.setSavePoint();

    try {
      this.doUpsert(objectsToUpsert);
      this.doDelete(objectsToDelete);
    } catch (AccountIntegrationServiceException e) {
      Database.rollback(savePoint);
      throw e;
    }
  }

  private Account selectAccount(String externalId) {
    List<Account> accounts = accRepo.getPersonAccountData(externalId);
    return accounts.isEmpty() ? null : accounts[0];
  }

  private void doDelete(List<SObject> objects) {
    Database.DeleteResult[] results = Database.delete(objects, false);
    for (Database.DeleteResult result : results) {
      if (!result.isSuccess()) {
        String detailedErrorMessage = result.getErrors()[0].getMessage();
        String errorMessage = 'An error has occurred during delete.';
        throw createAISException(errorMessage, detailedErrorMessage);
      }
    }
  }

  private void doUpsert(List<SObject> objects) {
    Database.UpsertResult[] results = Database.upsert(objects, false);
    for (Database.UpsertResult result : results) {
      if (result.isSuccess()) {
        String objectName = result.getId().getSobjectType().getDescribe().getName();
        if (objectName == 'Account') {
          this.upsertedAccountId = result.getId();
        }
      } else {
        String detailedErrorMessage = result.getErrors()[0].getMessage();
        String errorMessage = 'An error has occurred during upsert.';
        throw createAISException(errorMessage, detailedErrorMessage);
      }
    }
  }

  private List<SObject> getObjectsToDelete(Account currentAccount) {
    List<CommunicationContacts__c> contacts = this.getContactsToDelete(currentAccount?.CommunicationContacts__r);
    List<Addresses__c> addresses = this.getAddressesToDelete(currentAccount?.Addresses__r);
    List<AccountRelationships__c> relationships = this.getRelationshipsToDelete(currentAccount?.Contas_Relacionadas__r);
    List<Documents__c> documents = this.getDocumentsToDelete(currentAccount?.Documents__r);
    List<ProfessionalInfo__c> professionalInfos = this.getProfessionalInfosToDelete(currentAccount?.ProfessionalInfo__r);
    List<FinancialResources__c> incomes = this.getIncomesToDelete(currentAccount?.AccountFinancialRelationships__r);
    List<AccountFinancialRelationship__c> financialRelationships = this.getFinancialRelationshipsToDelete(incomes, currentAccount?.AccountFinancialRelationships__r);
    List<Filiation__c> filiations = this.getFiliationsToDelete(currentAccount?.Filiation__r);

    List<SObject> objects = new List<SObject>{};
    objects.addAll(contacts);
    objects.addAll(addresses);
    objects.addAll(relationships);
    objects.addAll(documents);
    objects.addAll(professionalInfos);
    objects.addAll(incomes);
    objects.addAll(financialRelationships);
    objects.addAll(filiations);

    return objects;
  }

  private List<SObject> getObjectsToUpsert(Account currentAccount) {
    this.newContactsExternalId = new Set<String>();
    this.newAdressesExternalId = new Set<String>();
    this.newRelatioshipsExternalId = new Set<String>();
    this.newDocumentsExternalId = new Set<String>();
    this.newProfessionalInfosExternalId = new Set<String>();
    this.newIncomesExternalId = new Set<String>();
    this.newProfessionalIncomesExternalId = new Set<String>();
    this.newFiliationsNames = new Set<String>();

    Account parentAccount = new Account(ExternalId__c = this.requestBodyObject.id);
    Account account = this.getAccountToUpsert(currentAccount?.Id);
    List<CommunicationContacts__c> contacts = this.getContactsToUpsert(parentAccount, currentAccount?.CommunicationContacts__r);
    List<Addresses__c> addresses = this.getAddressesToUpsert(parentAccount, currentAccount?.Addresses__r);
    List<AccountRelationships__c> relationships = this.getRelationshipsToUpsert(parentAccount, currentAccount?.Contas_Relacionadas__r);
    List<Documents__c> documents = this.getDocumentsToUpsert(parentAccount, currentAccount?.Documents__r);
    List<ProfessionalInfo__c> infos = this.getProfessionalInfosToUpsert(parentAccount, currentAccount?.ProfessionalInfo__r);
    List<FinancialResources__c> incomes = this.getIncomesToUpsert(currentAccount?.AccountFinancialRelationships__r);
    List<FinancialResources__c> professionalIncomes = this.getProfessionalIncomesToUpsert(currentAccount?.AccountFinancialRelationships__r);
    List<FinancialResources__c> newIncomes = new List<FinancialResources__c>();
    newIncomes.addAll(incomes);
    newIncomes.addAll(professionalIncomes);
    List<AccountFinancialRelationship__c> financialRelationships = this.getFinancialRelationshipsToUpsert(parentAccount, newIncomes, currentAccount?.AccountFinancialRelationships__r);
    List<Filiation__c> filiations = this.getFiliationsToUpsert(parentAccount, currentAccount?.Filiation__r);

    for (Filiation__c filiation : filiations) {
      if (filiation.Type__c == 'MOTHER') {
        account.Mother__c = filiation.Name__c;
      } else if (filiation.Type__c == 'FATHER') {
        account.Father__c = filiation.Name__c;
      }
    }

    List<SObject> objects = new List<SObject>{};
    objects.add(account);
    objects.addAll(contacts);
    objects.addAll(addresses);
    objects.addAll(relationships);
    objects.addAll(documents);
    objects.addAll(infos);
    objects.addAll(incomes);
    objects.addAll(professionalIncomes);
    objects.addAll(financialRelationships);
    objects.addAll(filiations);

    return objects;
  }

  private Account getAccountToUpsert(Id accountId) {
    Account account = new Account();
    account.Id = accountId;
    account.ExternalId__c = this.requestBodyObject.id;
    account.Name = this.requestBodyObject.fullName;
    account.Gender__c = this.requestBodyObject.gender;
    account.ExternalTenant__c = this.requestBodyObject.tenant;
    account.ExternalModifiedBy__c = this.requestBodyObject.modifiedBy;
    account.CivilStatus__c = this.requestBodyObject.civilStatus;
    account.BirthCity__c = this.requestBodyObject.cityOfBirth;
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

      account.PoliticallyExposed__c = this.requestBodyObject.additionalProperties.politicallyExposed == null ? false : this.requestBodyObject.additionalProperties.politicallyExposed;
    }

    if (this.requestBodyObject.education != null) {
      account.Education__c = this.requestBodyObject.education.degree;
    }

    if (this.requestBodyObject.wealth != null) {
      if (String.isNotBlank(this.requestBodyObject.wealth.networthLowerLimit)) {
        account.NetWorthLowerLimit__c = decimal.valueof(this.requestBodyObject.wealth.networthLowerLimit);
      }

      if (String.isNotBlank(this.requestBodyObject.wealth.networthUpperLimit)) {
        account.NetWorthUpperLimit__c = decimal.valueof(this.requestBodyObject.wealth.networthUpperLimit);
      }

      if (String.isNotBlank(this.requestBodyObject.wealth.currencyCode)) {
        account.CurrencyIsoCode = this.requestBodyObject.wealth.currencyCode;
      }
    }

    account.IsExternallySynched__c = true;
    account.IsSynchEnabled__c = 'ENABLED';
    return account;
  }

  private List<CommunicationContacts__c> getContactsToUpsert(Account parentAccount, List<CommunicationContacts__c> currentContacts) {
    List<CommunicationContacts__c> contacts = new List<CommunicationContacts__c>();

    if (this.requestBodyObject.contacts == null) {
      return contacts;
    }

    Map<String, Id> contactIdByExternalId = new Map<String, Id>();
    if (currentContacts != null) {
      for (CommunicationContacts__c contact : currentContacts) {
        contactIdByExternalId.put(contact.ExternalId__c, contact.Id);
      }
    }

    for (AccountIntegrationRequestVO.Contacts contact : this.requestBodyObject.contacts) {
      CommunicationContacts__c newContact = new CommunicationContacts__c();
      newContact.Id = contactIdByExternalId.get(contact.id);
      newContact.Account__r = parentAccount;
      newContact.ExternalId__c = contact.id;
      newContact.Channel__c = contact.channel;
      newContact.Code__c = contact.code;
      newContact.Type__c = contact.type;
      contacts.add(newContact);

      this.newContactsExternalId.add(contact.id);
    }

    return contacts;
  }

  private List<Addresses__c> getAddressesToUpsert(Account parentAccount, List<Addresses__c> currentAddresses) {
    List<Addresses__c> addresses = new List<Addresses__c>();

    if (this.requestBodyObject.addresses == null) {
      return addresses;
    }

    Map<String, Id> addressIdByExternalId = new Map<String, Id>();
    if (currentAddresses != null) {
      for (Addresses__c address : currentAddresses) {
        addressIdByExternalId.put(address.ExternalAddressId__c, address.Id);
      }
    }

    for (AccountIntegrationRequestVO.Adresses address : this.requestBodyObject.addresses) {
      Addresses__c newAddress = new Addresses__c();
      newAddress.Id = addressIdByExternalId.get(address.id);
      newAddress.Account__r = parentAccount;
      newAddress.ExternalAddressId__c = address.id;
      newAddress.Type__c = address.type;
      newAddress.Country__c = address.country;
      newAddress.Neighborhood__c = address.neighborhood;
      newAddress.Street__c = address.street;
      newAddress.StreetNumber__c = address.streetNumber;
      newAddress.PostalCode__c = address.zipCode;
      newAddress.Complement__c = address.complement;
      newAddress.AreaLevel1__c = address.administrativeAreaLevel1;
      newAddress.AreaLevel2__c = address.administrativeAreaLevel2;
      newAddress.AreaLevel3__c = address.administrativeAreaLevel3;
      newAddress.AreaLevel4__c = address.administrativeAreaLevel4;
      newAddress.AreaLevel5__c = address.administrativeAreaLevel5;
      addresses.add(newAddress);

      this.newAdressesExternalId.add(address.id);
    }

    return addresses;
  }

  private List<AccountRelationships__c> getRelationshipsToUpsert(Account parentAccount, List<AccountRelationships__c> currentRelationships) {
    List<AccountRelationships__c> relationships = new List<AccountRelationships__c>();

    if (this.requestBodyObject.relationships == null) {
      return relationships;
    }

    Map<String, Id> relationshipIdByExternalId = new Map<String, Id>();
    if (currentRelationships != null) {
      for (AccountRelationships__c relationship : currentRelationships) {
        relationshipIdByExternalId.put(relationship.ExternalId__c, relationship.Id);
      }
    }

    Set<String> secondaryAccountExternalIds = new Set<String>();
    for (AccountIntegrationRequestVO.Relationships relationship : this.requestBodyObject.relationships) {
      secondaryAccountExternalIds.add(relationship.personId);
    }

    Map<String, Id> accountIdByExternalId = new Map<String, Id>();
    for (Account account : [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :secondaryAccountExternalIds]) {
      accountIdByExternalId.put(account.ExternalId__c, account.Id);
    }

    for (AccountIntegrationRequestVO.Relationships relationship : this.requestBodyObject.relationships) {
      Id secondaryAccountId = accountIdByExternalId.get(relationship.personId);
      if (secondaryAccountId == null) {
        continue;
      }
      AccountRelationships__c newRelationship = new AccountRelationships__c();
      newRelationship.Id = relationshipIdByExternalId.get(relationship.id);
      newRelationship.ExternalId__c = relationship.id;
      newRelationship.Type__c = relationship.type;
      newRelationship.PrimaryRelationship__r = parentAccount;
      newRelationship.SecondaryRelationship__c = secondaryAccountId;
      relationships.add(newRelationship);

      this.newRelatioshipsExternalId.add(relationship.id);
    }

    return relationships;
  }

  private List<Documents__c> getDocumentsToUpsert(Account parentAccount, List<Documents__c> currentDocuments) {
    List<Documents__c> documents = new List<Documents__c>();

    if (this.requestBodyObject.documents == null) {
      return documents;
    }

    Map<String, Id> documentIdByExternalId = new Map<String, Id>();
    if (currentDocuments != null) {
      for (Documents__c document : currentDocuments) {
        documentIdByExternalId.put(document.ExternalId__c, document.Id);
      }
    }

    for (AccountIntegrationRequestVO.Documents document : this.requestBodyObject.documents) {
      Documents__c newDocument = new Documents__c();
      newDocument.Id = documentIdByExternalId.get(document.id);
      newDocument.Account__r = parentAccount;
      newDocument.ExternalId__c = document.id;
      newDocument.DocumentType__c = document.type;
      newDocument.recordTypeId = Util.getRecordTypeIdbyName('Documents__c', document.type.toUppercase());
      newDocument.DocumentNumber__c = document.code;
      newDocument.Issuer__c = document.issuer;
      newDocument.IssuerState__c = document.issuerState;
      if (String.isNotBlank(document.issueDate)) {
        newDocument.IssueDate__c = Date.valueOf(document.issueDate);
      }
      documents.add(newDocument);

      this.newDocumentsExternalId.add(document.id);
    }

    return documents;
  }

  private List<ProfessionalInfo__c> getProfessionalInfosToUpsert(Account parentAccount, List<ProfessionalInfo__c> currentInfos) {
    List<ProfessionalInfo__c> professionalInfos = new List<ProfessionalInfo__c>();

    if (this.requestBodyObject.professionalInfo == null) {
      return professionalInfos;
    }

    Map<String, Id> professionalInfoIdByExternalId = new Map<String, Id>();
    if (currentInfos != null) {
      for (ProfessionalInfo__c info : currentInfos) {
        professionalInfoIdByExternalId.put(info.ExternalId__c, info.Id);
      }
    }

    for (AccountIntegrationRequestVO.ProfessionalInfo info : this.requestBodyObject.professionalInfo) {
      ProfessionalInfo__c professionalInfo = new ProfessionalInfo__c();
      professionalInfo.Id = professionalInfoIdByExternalId.get(info.id);
      professionalInfo.Account__r = parentAccount;
      professionalInfo.JobTitle__c = info.jobTitle;
      professionalInfo.CompanyName__c = info.companyName;
      professionalInfo.EconomicActivity__c = info.economicActivity;
      professionalInfo.Status__c = info.status;
      professionalInfo.Category__c = info.category;
      professionalInfo.Current__c = info.current;
      professionalInfo.ExternalId__c = info.id;

      if (info.startDate != null) {
        if (info.startDate.year != null && info.startDate.month != null) {
          professionalInfo.StartDate__c = date.newinstance(integer.valueOf(info.startDate.year), integer.valueOf(info.startDate.month), 1);
        }
      }
      professionalInfos.add(professionalInfo);

      this.newProfessionalInfosExternalId.add(info.id);
    }

    return professionalInfos;
  }

  private List<FinancialResources__c> getIncomesToUpsert(List<AccountFinancialRelationship__c> currentRelationships) {
    List<FinancialResources__c> incomes = new List<FinancialResources__c>();

    if (this.requestBodyObject.income == null) {
      return incomes;
    }

    Map<String, Id> resourceIdByExternalId = new Map<String, Id>();
    if (currentRelationships != null) {
      for (AccountFinancialRelationship__c relationship : currentRelationships) {
        resourceIdByExternalId.put(relationship.Recurso_Financeiro__r.ExternalId__c, relationship.Recurso_Financeiro__r.Id);
      }
    }

    for (AccountIntegrationRequestVO.Income income : this.requestBodyObject.income) {
      FinancialResources__c newIncome = new FinancialResources__c();

      if (income.amount != null) {
        if (this.getValidCurrencies().contains(income.amount.currencyCode)) {
          newIncome.CurrencyIsoCode = income.amount.currencyCode;
          newIncome.Amount__c = Decimal.valueOf(income.amount.amount);
        } else {
          throw createAISException('Invalid currency code: ' + income.amount.currencyCode);
        }
      }

      newIncome.Id = resourceIdByExternalId.get(income.id);
      newIncome.ExternalId__c = income.id;
      newIncome.Type__c = income.type;
      newIncome.Source__c = income.source;
      newIncome.ExternalCreationDate__c = Date.valueOf(income.createdAt);
      newIncome.ExternalUpdatedDate__c = Date.valueOf(income.updatedAt);
      incomes.add(newIncome);

      this.newIncomesExternalId.add(income.id);
    }

    return incomes;
  }

  private List<FinancialResources__c> getProfessionalIncomesToUpsert(List<AccountFinancialRelationship__c> currentRelationships) {
    List<FinancialResources__c> incomes = new List<FinancialResources__c>();

    if (this.requestBodyObject.professionalInfo == null) {
      return incomes;
    }

    Map<String, Id> resourceIdByExternalId = new Map<String, Id>();
    if (currentRelationships != null) {
      for (AccountFinancialRelationship__c relationship : currentRelationships) {
        resourceIdByExternalId.put(relationship.Recurso_Financeiro__r.ExternalId__c, relationship.Recurso_Financeiro__r.Id);
      }
    }

    for (AccountIntegrationRequestVO.ProfessionalInfo info : this.requestBodyObject.professionalInfo) {
      if (info.professionalIncome == null || info.professionalIncome.isEmpty()) {
        continue;
      }

      AccountIntegrationRequestVO.ProfessionalIncome income = info.professionalIncome[0];
      FinancialResources__c newIncome = new FinancialResources__c();

      if (income.amount != null && !this.getValidCurrencies().contains(income.amount.currencyCode)) {
        throw createAISException('Invalid currency code: ' + income.amount.currencyCode);
      }

      newIncome.Id = resourceIdByExternalId.get(info.id);
      newIncome.ExternalId__c = info.id;
      newIncome.Type__c = income.type;
      newIncome.Source__c = income.source;
      newIncome.CurrencyIsoCode = income.amount.currencyCode;
      newIncome.Amount__c = Decimal.valueOf(income.amount.amount);
      newIncome.ProfessionalInfo__r = new ProfessionalInfo__c(ExternalId__c = info.id);
      incomes.add(newIncome);

      this.newProfessionalIncomesExternalId.add(info.id);
    }

    return incomes;
  }

  private List<AccountFinancialRelationship__c> getFinancialRelationshipsToUpsert(
    Account parentAccount,
    List<FinancialResources__c> incomes,
    List<AccountFinancialRelationship__c> currentRelationships
  ) {
    List<AccountFinancialRelationship__c> relationships = new List<AccountFinancialRelationship__c>();

    if (incomes == null) {
      return relationships;
    }

    Map<String, Id> relationshipIdByKey = new Map<String, Id>();
    if (currentRelationships != null) {
      for (AccountFinancialRelationship__c relationship : currentRelationships) {
        relationshipIdByKey.put(parentAccount.ExternalId__c + relationship.Recurso_Financeiro__r.ExternalId__c, relationship.Id);
      }
    }

    for (FinancialResources__c income : incomes) {
      String key = parentAccount.ExternalId__c + income.ExternalId__c;
      AccountFinancialRelationship__c newRelationship = new AccountFinancialRelationship__c();
      newRelationship.Id = relationshipIdByKey.get(key);
      newRelationship.Account__r = parentAccount;
      newRelationship.Recurso_Financeiro__r = new FinancialResources__c(ExternalId__c = income.ExternalId__c);
      relationships.add(newRelationship);
    }

    return relationships;
  }

  private List<Filiation__c> getFiliationsToUpsert(Account parentAccount, List<Filiation__c> currentFiliations) {
    List<Filiation__c> filiations = new List<Filiation__c>();

    if (this.requestBodyObject.filiation == null) {
      return filiations;
    }

    Map<String, Id> filiationIdByName = new Map<String, Id>();
    if (currentFiliations != null) {
      for (Filiation__c filiation : currentFiliations) {
        filiationIdByName.put(filiation.Name__c, filiation.Id);
      }
    }

    for (AccountIntegrationRequestVO.Filiation filiation : this.requestBodyObject.filiation) {
      filiations.add(new Filiation__c(Id = filiationIdByName.get(filiation.name), FiliatedAccount__r = parentAccount, Name__c = filiation.name, Type__c = filiation.type));

      this.newFiliationsNames.add(filiation.name);
    }

    return filiations;
  }

  private List<CommunicationContacts__c> getContactsToDelete(List<CommunicationContacts__c> currentContacts) {
    List<CommunicationContacts__c> contactsToDelete = new List<CommunicationContacts__c>();

    if (currentContacts == null || this.requestBodyObject.contacts == null) {
      return contactsToDelete;
    }

    for (CommunicationContacts__c currentContact : currentContacts) {
      if (!this.newContactsExternalId.contains(currentContact.ExternalId__c)) {
        contactsToDelete.add(currentContact);
      }
    }

    return contactsToDelete;
  }

  private List<Addresses__c> getAddressesToDelete(List<Addresses__c> currentAddresses) {
    List<Addresses__c> addressesToDelete = new List<Addresses__c>();

    if (currentAddresses == null || this.requestBodyObject.addresses == null) {
      return addressesToDelete;
    }

    for (Addresses__c currentAddress : currentAddresses) {
      if (!this.newAdressesExternalId.contains(currentAddress.ExternalAddressId__c)) {
        addressesToDelete.add(currentAddress);
      }
    }

    return addressesToDelete;
  }

  private List<AccountRelationships__c> getRelationshipsToDelete(List<AccountRelationships__c> currentRelatioships) {
    List<AccountRelationships__c> relationshipsToDelete = new List<AccountRelationships__c>();

    if (currentRelatioships == null || this.requestBodyObject.relationships == null) {
      return relationshipsToDelete;
    }

    for (AccountRelationships__c currentRelationship : currentRelatioships) {
      if (!this.newRelatioshipsExternalId.contains(currentRelationship.ExternalId__c)) {
        relationshipsToDelete.add(currentRelationship);
      }
    }

    return relationshipsToDelete;
  }

  private List<Documents__c> getDocumentsToDelete(List<Documents__c> currentDocuments) {
    List<Documents__c> documentsToDelete = new List<Documents__c>();

    if (currentDocuments == null || this.requestBodyObject.documents == null) {
      return documentsToDelete;
    }

    for (Documents__c currentDocument : currentDocuments) {
      if (!this.newDocumentsExternalId.contains(currentDocument.ExternalId__c)) {
        documentsToDelete.add(currentDocument);
      }
    }

    return documentsToDelete;
  }

  private List<ProfessionalInfo__c> getProfessionalInfosToDelete(List<ProfessionalInfo__c> currentInfos) {
    List<ProfessionalInfo__c> infosToDelete = new List<ProfessionalInfo__c>();

    if (currentInfos == null || this.requestBodyObject.professionalInfo == null) {
      return infosToDelete;
    }

    for (ProfessionalInfo__c currentInfo : currentInfos) {
      if (!this.newProfessionalInfosExternalId.contains(currentInfo.ExternalId__c)) {
        infosToDelete.add(currentInfo);
      }
    }

    return infosToDelete;
  }

  private List<FinancialResources__c> getIncomesToDelete(List<AccountFinancialRelationship__c> currentIncomes) {
    List<FinancialResources__c> incomesToDelete = new List<FinancialResources__c>();
    List<AccountIntegrationRequestVO.Income> newIncomes = this.requestBodyObject.income;
    List<AccountIntegrationRequestVO.ProfessionalInfo> newProfessionalInfos = this.requestBodyObject.professionalInfo;

    if (currentIncomes == null) {
      return incomesToDelete;
    }

    for (AccountFinancialRelationship__c income : currentIncomes) {
      String incomeExternalId = income.Recurso_Financeiro__r.ExternalId__c;
      if (income.Recurso_Financeiro__r.ProfessionalInfo__c == null) {
        if (newIncomes != null && !this.newIncomesExternalId.contains(incomeExternalId)) {
          incomesToDelete.add(income.Recurso_Financeiro__r);
        }
      } else {
        if (newProfessionalInfos != null && !this.newProfessionalIncomesExternalId.contains(incomeExternalId)) {
          incomesToDelete.add(income.Recurso_Financeiro__r);
        }
      }
    }

    return incomesToDelete;
  }

  private List<AccountFinancialRelationship__c> getFinancialRelationshipsToDelete(List<FinancialResources__c> incomesToDelete, List<AccountFinancialRelationship__c> currentRelationships) {
    List<AccountFinancialRelationship__c> relationshipsToDelete = new List<AccountFinancialRelationship__c>();

    if (incomesToDelete == null || currentRelationships == null) {
      return relationshipsToDelete;
    }

    Set<Id> incomesIds = new Set<Id>();
    for (FinancialResources__c income : incomesToDelete) {
      incomesIds.add(income.Id);
    }

    for (AccountFinancialRelationship__c relationship : currentRelationships) {
      if (incomesIds.contains(relationship.Recurso_Financeiro__c)) {
        relationshipsToDelete.add(relationship);
      }
    }

    return relationshipsToDelete;
  }

  private List<Filiation__c> getFiliationsToDelete(List<Filiation__c> currentFiliations) {
    List<Filiation__c> filiationsToDelete = new List<Filiation__c>();

    if (currentFiliations == null || this.requestBodyObject.filiation == null) {
      return filiationsToDelete;
    }

    System.debug('currentFiliations --> ' + currentFiliations);
    for (Filiation__c filiation : currentFiliations) {
      if (!this.newFiliationsNames.contains(filiation.Name__c)) {
        filiationsToDelete.add(filiation);
      }
    }
    System.debug('filiationsToDelete --> ' + filiationsToDelete);
    return filiationsToDelete;
  }

  private Set<String> getValidCurrencies() {
    Set<String> validCurrencies = new Set<String>();
    Schema.DescribeFieldResult currencyCodes = Pricebook2.CurrencyIsoCode.getDescribe();
    for (Schema.PicklistEntry entry : currencyCodes.getPicklistValues()) {
      validCurrencies.add(entry.getValue());
    }
    return validCurrencies;
  }

  private void handleAISException(AccountIntegrationServiceException aisException) {
    this.setResponse(500, aisException.getMessage());
    this.insertErrorLog(500, aisException.getDetailedMessage());
  }

  private void handleException(Exception e) {
    this.setResponse(500, 'An unexpected error has occurred. Please, contact a Salesforce administrator.');
    this.insertErrorLog(500, e.getMessage());
  }

  private void insertErrorLog(Integer statusCode, String message) {
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

  private void setResponse(Integer statusCode, String message) {
    this.responseBodyObject = new AccountIntegrationResponseVO();
    this.responseBodyObject.accountId = this.upsertedAccountId;
    this.responseBodyObject.message = message;
    this.responseBodyObject.status = statusCode;
  }
}