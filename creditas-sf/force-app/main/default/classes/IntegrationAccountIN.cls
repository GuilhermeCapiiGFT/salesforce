@RestResource(urlMapping='/IntegrationAccountIN/*')
global without sharing class IntegrationAccountIN {
    
    @HttpPost
    global static void postMethod() 
    {
        String accountId = '';
        Set<String> addressesExternalIds = new Set<String>();
        Set<String> relationshipsExternalIds = new Set<String>();
        Set<String> relationshipsPersonIds = new Set<String>();
        Set<String> documentsExternalIds = new Set<String>();
        Set<String> incomeExternalIds = new Set<String>();
        Set<String> professionalInfoExternalIds = new Set<String>();
        Map<String, CommunicationContacts__c> contactKeyToSalesForceContactsMap = new Map<String, CommunicationContacts__c>();
        Map<String, Addresses__c> addressExternalIdToSalesForceAddressMap = new Map<String, Addresses__c>();
        Map<String, AccountRelationships__c> relationshipsExternalIdToSalesForceRelationshipsMap = new Map<String, AccountRelationships__c>();
        Map<String, Account> relationshipPersonIdToAccountMap = new Map<String, Account>();
        Map<String, Documents__c> documentsExternalIdsToSalesForceDocumentsMap = new Map<String, Documents__c>();
        Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap = new Map<String, FinancialResources__c>();
        Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap = new Map<String, ProfessionalInfo__c>();
                
        AccountIntegrationModel typedRequestBody = AccountIntegrationModel.parse(RestContext.request.requestBody.toString());
        String accountExternalId = typedRequestBody.Id;  
        
        List<Account> existingAccounts = [SELECT ExternalId__c FROM Account WHERE ExternalId__c = :accountExternalId];                 
        typedRequestBody.salesforceId = existingAccounts.size() == 0 ? null : existingAccounts[0].Id;  
        
		accountResponseData ard = upsertAccount(typedRequestBody);
        accountId = ard.accountId;
        
        /*if (existingAccounts.size() == 0 ){          
            accountResponseData ard = insertAccount(typedRequestBody);
            accountId = ard.accountId;
            
            RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
            res.responseBody = Blob.valueOf(JSON.serialize(ard));
            res.statusCode = 200;
        } else {
            typedRequestBody.salesforceId = existingAccounts[0].Id;
            accountResponseData ard = updateAccount(typedRequestBody);
            accountId = ard.accountId;
            
            RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
            res.responseBody = Blob.valueOf(JSON.serialize(ard));
            res.statusCode = 200;
        }*/
        
        //Contacts
        for (CommunicationContacts__c cnt : [SELECT Id, Account__c, Code__c, Channel__c FROM CommunicationContacts__c WHERE Account__c = :accountId]){
        	contactKeyToSalesForceContactsMap.put(cnt.Channel__c + '_' + cnt.Code__c, cnt);
        }            
        for (AccountIntegrationModel.contactsModel cm : typedRequestBody.contacts){
            String contactKey = cm.channel + '_' + cm.code;
            CommunicationContacts__c SalesForceContact = contactKeyToSalesForceContactsMap.get(contactKey);
            cm.isUpdate = SalesForceContact != null;                                  
        }
        
        upsertContacts(typedRequestBody.contacts, accountId);
        
        //Addresses
        for (AccountIntegrationModel.adressesModel addr : typedRequestBody.addresses){
            addressesExternalIds.add(addr.Id);
            addr.isUpdate = false;
        }       
        for (Addresses__c addr : [SELECT Id, ExternalAddressId__c, Account__c FROM Addresses__c WHERE ExternalAddressId__c IN :addressesExternalIds AND Account__c = :accountId]){
            addressExternalIdToSalesForceAddressMap.put(addr.ExternalAddressId__c, addr);
        }     
        
        upsertAddresses(typedRequestBody.addresses, accountId, addressExternalIdToSalesForceAddressMap);
        
        //Relationship
        for (AccountIntegrationModel.relationshipsModel rtm : typedRequestBody.relationships){
            relationshipsExternalIds.add(rtm.Id);
            relationshipsPersonIds.add(rtm.personId);
            rtm.isUpdate = false;
        }       
        for (AccountRelationships__c rtm : [SELECT Id, ExternalId__c, PrimaryRelationship__c FROM AccountRelationships__c WHERE ExternalId__c IN :relationshipsExternalIds]){
            relationshipsExternalIdToSalesForceRelationshipsMap.put(rtm.ExternalId__c, rtm);
        }     
        
        for (Account acc :  [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :relationshipsPersonIds]){
            relationshipPersonIdToAccountMap.put(acc.ExternalId__c, acc);
        }
        
        upsertRelationships(typedRequestBody.relationships, accountId, relationshipsExternalIdToSalesForceRelationshipsMap, relationshipPersonIdToAccountMap);
        
        //Documents
        for (AccountIntegrationModel.documentsModel documents : typedRequestBody.documents){
            documentsExternalIds.add(documents.id);
            documents.isUpdate = false;
            
        }
        
        for (Documents__c documents : [SELECT Id, Account__c, ExternalId__c, IssueDate__c, IssuerState__c, CurrencyIsoCode, Name, DocumentNumber__c, DocumentType__c, Issuer__c FROM Documents__c  WHERE ExternalId__c IN :documentsExternalIds AND Account__c = :accountId]){
            documentsExternalIdsToSalesForceDocumentsMap.put(documents.ExternalId__c, documents);
        }     
        
        upsertDocuments(typedRequestBody.documents, accountId, documentsExternalIdsToSalesForceDocumentsMap);
        
        //Income Model / Recursos Financeiros
        for (AccountIntegrationModel.incomeModel incom : typedRequestBody.income){
            incomeExternalIds.add(incom.Id);
            incom.isUpdate = false;
        }       
        for (FinancialResources__c incom : [SELECT Id, ExternalId__c, Account__c, Amount__c, Type__c FROM FinancialResources__c  WHERE ExternalId__c IN :incomeExternalIds AND Account__c = :accountId]){
            incomeExternalIdToSalesForceIncomeMap.put(incom.ExternalId__c, incom);
        }     
        
        upsertIncome(typedRequestBody.income, accountId, incomeExternalIdToSalesForceIncomeMap);
        
        //professionalInfo
        for (AccountIntegrationModel.professionalInfoModel professionalInfoObj : typedRequestBody.professionalInfo){
            professionalInfoExternalIds.add(professionalInfoObj.Id);
            professionalInfoObj.isUpdate = false;
        }       
        for (ProfessionalInfo__c professionalInfoObj : [SELECT Id, ExternalId__c, Account__c, StartDate__c, JobTitle__c, CompanyName__c, EconomicActivity__c, Status__c, Category__c, Current__c, CurrencyIsoCode, Name  FROM ProfessionalInfo__c WHERE ExternalId__c IN :professionalInfoExternalIds AND Account__c = :accountId]){
            professionalInfoExternalIdToSalesForceProfessionalInfoMap.put(professionalInfoObj.ExternalId__c, professionalInfoObj);
        }     
        
        upsertProfessionalInfo(typedRequestBody.professionalInfo, accountId, professionalInfoExternalIdToSalesForceProfessionalInfoMap);
        
        //Response
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.responseBody = Blob.valueOf(JSON.serialize(ard));
        res.statusCode = 200;
    }
        
    /*@HttpPost
    global static void IntegrationAccountIN(){       
    }*/
    
    private static void upsertContacts(List<AccountIntegrationModel.contactsModel> accountContactsToupsert, String accountId){
        List<CommunicationContacts__c> contactsToInsert = new List<CommunicationContacts__c>();
        //List<CommunicationContacts__c> contactsToUpdate = new List<CommunicationContacts__c>();       
        
        for (AccountIntegrationModel.contactsModel cm : accountContactsToupsert){
            CommunicationContacts__c cnt = new CommunicationContacts__c();
            cnt.Channel__c = cm.channel;
            cnt.Code__c = cm.code;
            cnt.Type__c = cm.type;
            cnt.Account__c = accountId;
            if (!cm.isUpdate){
            	contactsToInsert.add(cnt);  
            } 
            /*else {
                contactsToUpdate.add(cnt);
            }*/
        }
        /*if (contactsToUpdate.size() > 0)
            update contactsToUpdate;*/
        
        if (contactsToInsert.size() > 0)
            insert contactsToInsert;

    }
    
    private static void upsertAddresses(List<AccountIntegrationModel.adressesModel> accountAddressesToupsert, Id accountId,  Map<String, Addresses__c> addressExternalIdToSalesForceAddressMap){
    	List<Addresses__c> addressesToInsert = new List<Addresses__c>();
    	List<Addresses__c> addressesToUpdate = new List<Addresses__c>();       
        system.debug('adresses 1');
        
        for (AccountIntegrationModel.adressesModel am : accountAddressesToupsert){
            Addresses__c salesForceAddress = addressExternalIdToSalesForceAddressMap.get(am.id);
            System.debug('salesForceAddress: '+salesForceAddress);
            System.debug('is null? '+salesForceAddress != null);
            am.isUpdate = salesForceAddress != null;
            
            Addresses__c adr = new Addresses__c();
            adr.Account__c = accountId;
            adr.ExternalAddressId__c = am.id;
            adr.Type__c = am.type;
            adr.Country__c = am.country;
            adr.Neighborhood__c = am.neighborhood;
            adr.Street__c = am.street;
            adr.StreetNumber__c = am.streetNumber;
            adr.PostalCode__c = am.zipCode;
            //Complemento não está no layout
            adr.Complement__c = am.complement;
            
            
            if (am.isUpdate){
                adr.Id = salesForceAddress.Id;
            	addressesToUpdate.add(adr);  
            } else {
                addressesToInsert.add(adr);
            }
        }
        if (addressesToInsert.size() > 0)
            insert addressesToInsert;
        if (addressesToUpdate.size() > 0)
            update addressesToUpdate;
    }   
    
    private static void upsertRelationships(List<AccountIntegrationModel.relationshipsModel> relationshipsToupsert, Id accountId, Map<String, AccountRelationships__c> relationshipsExternalIdToSalesForceRelationshipsMap, Map<String, Account> relationshipPersonIdToAccountMap){ 
    	List<AccountRelationships__c> relationshipsToInsert = new List<AccountRelationships__c>();
    	List<AccountRelationships__c> relationshipsToUpdate = new List<AccountRelationships__c>();       
        
        for (AccountIntegrationModel.relationshipsModel rm : relationshipsToupsert){
            Account relationshipAccount = relationshipPersonIdToAccountMap.get(rm.personId);
            if (relationshipAccount == null ) continue;
            
            AccountRelationships__c salesForceRelationships = relationshipsExternalIdToSalesForceRelationshipsMap.get(rm.id);
            rm.isUpdate = salesForceRelationships != null;
            
            AccountRelationships__c art = new AccountRelationships__c();
            art.ExternalId__c = rm.id;
            art.Type__c = rm.type;
            art.PrimaryRelationship__c = accountId;
            art.SecondaryRelationship__c = relationshipAccount.Id;           
                      
            if (rm.isUpdate){
                art.Id = salesForceRelationships.Id;
            	relationshipsToUpdate.add(art);  
            } else {
                relationshipsToInsert.add(art);
            }
        }
        if (relationshipsToInsert.size() > 0)
            insert relationshipsToInsert;
        if (relationshipsToUpdate.size() > 0)
            update relationshipsToUpdate;
    }   
    
    @TestVisible private static void upsertDocuments(List<AccountIntegrationModel.documentsModel> documentsToUpsert, Id accountId, Map<String, Documents__c> documentsExternalIdsToSalesForceDocumentsMap){ 
    	List<Documents__c> documentsToInsert = new List<Documents__c>();
    	List<Documents__c> documentsToUpdate = new List<Documents__c>();  
        
         for (AccountIntegrationModel.documentsModel doc : documentsToUpsert){
            Documents__c salesForceDocuments = documentsExternalIdsToSalesForceDocumentsMap.get(doc.id);
            doc.isUpdate = salesForceDocuments != null;
            
            Documents__c documentsSF = new Documents__c();
            documentsSF.Account__c = accountId;
            documentsSF.ExternalId__c = doc.id;
            documentsSF.DocumentType__c = doc.type;
            documentsSF.DocumentNumber__c = doc.code;             
            documentsSF.Issuer__c = doc.issuer;
            documentsSF.IssuerState__c = doc.issuerState;
            
            if (doc.issueDate != null)
            	documentsSF.IssueDate__c = Date.valueOf(doc.issueDate);
            //date.newinstance(integer.valueOf(doc.issueDate.year), integer.valueOf(doc.issueDate.month), 1);
           
         
            if (doc.isUpdate){
                documentsSF.Id = salesForceDocuments.Id;
            	documentsToUpdate.add(documentsSF);  
            } else {
                documentsToInsert.add(documentsSF);
            }
        }
       		 if (documentsToInsert.size() > 0)
            insert documentsToInsert;
        	if (documentsToUpdate.size() > 0)
            update documentsToUpdate;
    }  
            
    private static void upsertIncome(List<AccountIntegrationModel.incomeModel> incomeToUpsert, Id accountId, Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap){ 
    	List<FinancialResources__c> incomeToInsert = new List<FinancialResources__c>();
    	List<FinancialResources__c> incomeToUpdate = new List<FinancialResources__c>();       
        
        for (AccountIntegrationModel.incomeModel inc : incomeToUpsert){
            FinancialResources__c salesForceIncome = incomeExternalIdToSalesForceIncomeMap.get(inc.id);
            inc.isUpdate = salesForceIncome != null;
            
            FinancialResources__c income = new FinancialResources__c();
            income.Account__c = accountId;
            income.ExternalId__c = inc.id;
            income.Type__c = inc.type;
            income.Source__c = inc.source;
         	income.CurrencyIsoCode = inc.amount.currencyCode;
            income.Amount__c = Decimal.valueOf(inc.amount.amount);
            
           
            if (inc.isUpdate){
                income.Id = salesForceIncome.Id;
            	incomeToUpdate.add(income);  
            } else {
                incomeToInsert.add(income);
            }
        }
        if (incomeToInsert.size() > 0)
            insert incomeToInsert;
        if (incomeToUpdate.size() > 0)
            update incomeToUpdate;
    }  
    
    private static void upsertProfessionalInfo(List<AccountIntegrationModel.professionalInfoModel> professionalInfoToUpsert, Id accountId, Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap){ 
    	List<ProfessionalInfo__c> professionalInfoToInsert = new List<ProfessionalInfo__c>();
    	List<ProfessionalInfo__c> professionalInfoToUpdate = new List<ProfessionalInfo__c>();       
        
        for (AccountIntegrationModel.professionalInfoModel professionalInfoSF : professionalInfoToUpsert){
            ProfessionalInfo__c salesForceProfessionalInfo = professionalInfoExternalIdToSalesForceProfessionalInfoMap.get(professionalInfoSF.id);
            professionalInfoSF.isUpdate = salesForceProfessionalInfo != null;
            
            ProfessionalInfo__c professionalObj = new ProfessionalInfo__c();          
            professionalObj.JobTitle__c = professionalInfoSF.jobTitle;
            professionalObj.CompanyName__c = professionalInfoSF.companyName;
            professionalObj.EconomicActivity__c = professionalInfoSF.economicActivity;
            professionalObj.Status__c = professionalInfoSF.status;
            professionalObj.Category__c = professionalInfoSF.category;
            professionalObj.Current__c = professionalInfoSF.current;
            professionalObj.Account__c = accountId;
            professionalObj.ExternalId__c = professionalInfoSF.id;
            professionalObj.StartDate__c = date.newinstance(integer.valueOf(professionalInfoSF.startDate.year), integer.valueOf(professionalInfoSF.startDate.month), 1);
            professionalObj.CurrencyIsoCode = professionalInfoSF.professionalIncome[0].amount.currencyCode;    
                                        
                       
            if (professionalInfoSF.isUpdate){
                professionalObj.Id = salesForceProfessionalInfo.Id;
            	professionalInfoToUpdate.add(professionalObj);  
            } else {
                professionalInfoToInsert.add(professionalObj);
            }
        }
        if (professionalInfoToInsert.size() > 0)
            insert professionalInfoToInsert;
        if (professionalInfoToUpdate.size() > 0)
            update professionalInfoToUpdate;
    }  
    
    @TestVisible private static accountResponseData upsertAccount(AccountIntegrationModel typedAccountToUpsert){
        Account accountToUpsert = new Account();
        accountToUpsert.ExternalId__c = typedAccountToUpsert.id;
        Boolean isUpdate = typedAccountToUpsert.salesforceId != null;
        
        accountToUpsert.DocumentType__c = typedAccountToUpsert.mainDocument.type;
        accountToUpsert.DocumentNumber__c = typedAccountToUpsert.mainDocument.code;
        
        accountToUpsert.Name = typedAccountToUpsert.fullName;
        accountToUpsert.Gender__c = typedAccountToUpsert.gender;
        accountToUpsert.BirthDate__c = Date.valueOf(typedAccountToUpsert.birthDate);
        accountToUpsert.CivilStatus__c = typedAccountToUpsert.civilStatus;
        accountToUpsert.Birth_City__c = typedAccountToUpsert.cityOfBirth;
        accountToUpsert.Birth_Country__c = typedAccountToUpsert.countryOfBirth;
        accountToUpsert.Nationality__c = typedAccountToUpsert.nationality;
        accountToUpsert.ExternalCreationDate__c = Date.valueOf(typedAccountToUpsert.createdAt);
        accountToUpsert.ExternalUpdatedDate__c = Date.valueOf(typedAccountToUpsert.updatedAt);
        accountToUpsert.ExternalVersion__c = typedAccountToUpsert.version;
        
        accountToUpsert.FirstName__c = typedAccountToUpsert.additionalProperties.firstName;
        accountToUpsert.SecondName__c = typedAccountToUpsert.additionalProperties.secondName;
        accountToUpsert.LastName__c = typedAccountToUpsert.additionalProperties.lastName;
        accountToUpsert.SecondLastName__c = typedAccountToUpsert.additionalProperties.secondLastName;
        accountToUpsert.Curp__c = typedAccountToUpsert.additionalProperties.curp;
        accountToUpsert.IneNumber__c = typedAccountToUpsert.additionalProperties.ineNumber;
        accountToUpsert.BankName__c = typedAccountToUpsert.additionalProperties.bankName;
        accountToUpsert.BankAccountNumber__c = typedAccountToUpsert.additionalProperties.accountNumber;
        accountToUpsert.Clabe__c = typedAccountToUpsert.additionalProperties.clabe;
        accountToUpsert.PoliticallyExposed__c = typedAccountToUpsert.additionalProperties.politicallyExposed;
        
        accountToUpsert.Education__c = typedAccountToUpsert.education.degree;
        
        accountToUpsert.NetWorthLowerLimit__c = decimal.valueof(typedAccountToUpsert.wealth.networthLowerLimit);
        accountToUpsert.NetWorthUpperLimit__c = decimal.valueof(typedAccountToUpsert.wealth.networthUpperLimit);
        accountToUpsert.CurrencyIsoCode = typedAccountToUpsert.wealth.currencyCode;                            
                              
        if (isUpdate){
            accountToUpsert.Id = typedAccountToUpsert.salesforceId;
            update accountToUpsert;
        } else {
            insert accountToUpsert;
        }
               
        accountResponseData ard = new accountResponseData();
        ard.accountId = accountToUpsert.Id;
        ard.message = isUpdate ? 'Account sucessfully updated.' : 'Account sucessfully created.';
        return ard;
    }
    
    /*private static accountResponseData insertAccount(AccountIntegrationModel typedAccountToInsert){
        Account accountToInsert = new Account();
        accountToInsert.ExternalId__c = typedAccountToInsert.id;
        
        accountToInsert.DocumentType__c = typedAccountToInsert.mainDocument.type;
        accountToInsert.DocumentNumber__c = typedAccountToInsert.mainDocument.code;
        
        accountToInsert.Name = typedAccountToInsert.fullName;
        
        insert accountToInsert;
        
        accountResponseData ard = new accountResponseData();
        ard.accountId = accountToInsert.Id;
        ard.message = 'Account sucessfully created.';
        return ard;
        
    }
    
    private static accountResponseData updateAccount(AccountIntegrationModel  typedAccountToUpdate){
        Account accountToUpdate = new Account();
        accountToUpdate.ExternalId__c = typedAccountToUpdate.id;
        accountToUpdate.Id = typedAccountToUpdate.salesforceId;
        
        accountToUpdate.DocumentType__c = typedAccountToUpdate.mainDocument.type;
        accountToUpdate.DocumentNumber__c = typedAccountToUpdate.mainDocument.code;
        
        accountToUpdate.Name = typedAccountToUpdate.fullName;
        
        update accountToUpdate;
        
        accountResponseData ard = new accountResponseData();
        ard.accountId = accountToUpdate.Id;
        ard.message = 'Account sucessfully updated.';
        return ard;
    }*/
    
    public class accountResponseData{
        public String accountId;
        public String message;
    }
}