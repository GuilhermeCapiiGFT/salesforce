/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Web Service customizado para cadastrar/atualizar dados de Person/Account
* ================================================================================================================================
* History
* -------
* VERSION   AUTHORS                  DATE           DETAIL     Description
* 1.0       Gabriel Vidal,       20/09/2021         Created     Implementação das requisições REST do web service de Account
            Nathália Rosa       
            Gabriel Vidal        25/01/2022         Updated     Refatoração da classe para atender às boas práticas 
                                                                e ajustes de mensagens de erro     
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationAccountIN/*')
global without sharing class IntegrationAccountIN { 
    public static Boolean hasError = false;

    @HttpPut
    global static void putMethod(){
        String requestBodyString = RestContext.request.requestBody.toString();
        try{               
            AccountIntegrationModel requestBodyObj =  AccountIntegrationModel.parse(requestBodyString);
            String errorMessage = '';
            String errorMessageToReturn = '';
            if (requestBodyObj.hasError){
                errorMessage = requestBodyObj.errorMessage;
                errorMessageToReturn = 'Invalid JSON format.';
                setErrorResponse(500, errorMessageToReturn);
                insertErrorLog(500, errorMessage, requestBodyString);
                return;
            }
            if (requestBodyObj.professionalInfo != null){
                for(AccountIntegrationModel.professionalInfoModel professionalInfo : requestBodyObj.professionalInfo){
                    if(professionalInfo.professionalIncome != null && professionalInfo.professionalIncome.size() > 1){
                        errorMessage = 'Each professional info. must has only one professional income.';                   
                        setErrorResponse(500, errorMessage);
                        insertErrorLog(500, errorMessage, requestBodyString);
                        return;
                    }
                }
            }
            if (requestBodyObj.mainDocument == null || String.isBlank(requestBodyObj.mainDocument.code)){
                errorMessage = 'Main Document cannot be null.';
                setErrorResponse(500, errorMessage);
                insertErrorLog(500, errorMessage, requestBodyString);
                return;
            }
            Id salesforceId = [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c = :requestBodyObj.id LIMIT 1]?.Id;
            if (salesforceId == null){
                String docNumber = requestBodyObj.mainDocument.type == 'CPF' ? Util.getMaskedCPF(requestBodyObj.mainDocument.code) : requestBodyObj.mainDocument.code;
            	salesforceId = [SELECT Id, ExternalId__c, DocumentNumber__c FROM Account WHERE DocumentNumber__c = :docNumber LIMIT 1]?.Id;         
            }
            requestBodyObj.salesforceId = salesforceId;
                                      
            Map<String, String> commitReturnMap = commitTransactions(requestBodyObj);

            if (!hasError){
                AccountResponseData accResponse = new AccountResponseData();
                accResponse.accountId = commitReturnMap.get('accountId');
                accResponse.message = 'Account upserted.';
                accResponse.status = 200;

                RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
                res.responseBody = Blob.valueOf(JSON.serialize(accResponse));
                res.statusCode = 200;
            } else {
                errorMessage = commitReturnMap.get('dmlErrorMessage');
                errorMessageToReturn = commitReturnMap.get('friendlyErrorMessage');
            	setErrorResponse(500, errorMessageToReturn);
            	insertErrorLog(500, errorMessage, requestBodyString); 
            }
        } catch (Exception e){
            System.debug(e.getLineNumber());
            String errorMessage =  e.getMessage();
            String errorMessageToReturn = 'An unexpected error has occurred. Please contact SalesForce administrator.';
            setErrorResponse(500, errorMessageToReturn);
            insertErrorLog(500, errorMessage, requestBodyString);
            return;
        }
    }

    private static Map<String, String> upsertAccount(AccountIntegrationModel requestBodyObj){
        Account accountToUpsert = new Account();
      
        if(requestBodyObj != null){    
            accountToUpsert.ExternalId__c = requestBodyObj.id;
            accountToUpsert.Name = requestBodyObj.fullName;
            accountToUpsert.Gender__c = requestBodyObj.gender;
            accountToUpsert.ExternalTenant__c = requestBodyObj.tenant;
            accountToUpsert.ExternalModifiedBy__c = requestBodyObj.modifiedBy;
            accountToUpsert.CivilStatus__c = requestBodyObj.civilStatus;
            accountToUpsert.Birth_City__c = requestBodyObj.cityOfBirth;
            accountToUpsert.Birth_Country__c = requestBodyObj.countryOfBirth;
            accountToUpsert.Nationality__c = requestBodyObj.nationality;
            
            if(requestBodyObj.birthDate != null){ 
                accountToUpsert.BirthDate__c = Date.valueOf(requestBodyObj.birthDate);
            }   
            
            if(requestBodyObj.createdAt != null){
                accountToUpsert.ExternalCreationDate__c = Date.valueOf(requestBodyObj.createdAt);
            }
            
            if(requestBodyObj.updatedAt != null){
                accountToUpsert.ExternalUpdatedDate__c = Date.valueOf(requestBodyObj.updatedAt);   
            }
            
            accountToUpsert.ExternalVersion__c = requestBodyObj.version;
        }    
            
        if(requestBodyObj.mainDocument != null){
            accountToUpsert.DocumentType__c = requestBodyObj.mainDocument.type;
            accountToUpsert.DocumentNumber__c = requestBodyObj.mainDocument.code;
        }
       
        if(requestBodyObj.additionalProperties != null){
            accountToUpsert.FirstName__c = requestBodyObj.additionalProperties.firstName;
            accountToUpsert.SecondName__c = requestBodyObj.additionalProperties.secondName;
            accountToUpsert.LastName__c = requestBodyObj.additionalProperties.lastName;
            accountToUpsert.SecondLastName__c = requestBodyObj.additionalProperties.secondLastName;
            accountToUpsert.Curp__c = requestBodyObj.additionalProperties.curp;
            accountToUpsert.IneNumber__c = requestBodyObj.additionalProperties.ineNumber;
            accountToUpsert.BankName__c = requestBodyObj.additionalProperties.bankName;
            accountToUpsert.BankAccountNumber__c = requestBodyObj.additionalProperties.accountNumber;
            accountToUpsert.Clabe__c = requestBodyObj.additionalProperties.clabe;
            
            accountToUpsert.PoliticallyExposed__c = requestBodyObj.additionalProperties.politicallyExposed == null ? false : requestBodyObj.additionalProperties.politicallyExposed;
        }
    
        if(requestBodyObj.education != null){
            accountToUpsert.Education__c = requestBodyObj.education.degree;
        }    
         
        if(requestBodyObj.wealth != null){
            if(requestBodyObj.wealth.networthLowerLimit != null){
                accountToUpsert.NetWorthLowerLimit__c = decimal.valueof(requestBodyObj.wealth.networthLowerLimit);
            }
            
            if(requestBodyObj.wealth.networthUpperLimit != null){
                 accountToUpsert.NetWorthUpperLimit__c = decimal.valueof(requestBodyObj.wealth.networthUpperLimit);
            }
            
            if(requestBodyObj.wealth.currencyCode != null){
                accountToUpsert.CurrencyIsoCode = requestBodyObj.wealth.currencyCode; 
            }
        }

        accountToUpsert.Id = requestBodyObj.salesforceId;
        accountToUpsert.IsExternallySynched__c = true;
        accountToUpsert.IsSynchEnabled__c = 'ENABLED';
        Map<String, String> accountReturnMap = new Map<String, String>();
        try {
            upsert accountToUpsert;            
            accountReturnMap.put('accountId', accountToUpsert.Id);  
        } catch (System.DmlException e){
            hasError = true;
            accountReturnMap.put('dmlErrorMessage', e.getDmlMessage(0));  
        } 
        return accountReturnMap;          
    }  
               
    private static String upsertContacts(AccountIntegrationModel requestBodyObj, Id accountId){
        List<AccountIntegrationModel.contactsModel> accountContactsToUpsert = requestBodyObj.contacts;  
        List<CommunicationContacts__c> contactsToUpsert = new List<CommunicationContacts__c>(); 
        if(accountContactsToUpsert == null){
            return '';
        }
        Set<String> contactsExternalIds = new Set<String>();
        for (AccountIntegrationModel.contactsModel cm : accountContactsToUpsert){
            contactsExternalIds.add(cm.id);
        }  

        Map<String, CommunicationContacts__c> contactExternalIdToCommunicationContactMap = new Map<String, CommunicationContacts__c>();
        for (CommunicationContacts__c cnt : [SELECT Id, ExternalId__c FROM CommunicationContacts__c WHERE ExternalId__c IN :contactsExternalIds]){         
            contactExternalIdToCommunicationContactMap.put(cnt.ExternalId__c, cnt);
        }   
        for (AccountIntegrationModel.contactsModel cm : accountContactsToUpsert){
            CommunicationContacts__c cnt = new CommunicationContacts__c();
            cnt.Account__c = accountId;
            cnt.Id = contactExternalIdToCommunicationContactMap.get(cm.id)?.Id;
            cnt.ExternalId__c = cm.id;
            cnt.Channel__c = cm.channel;
            cnt.Code__c = cm.code;
            cnt.Type__c = cm.type;

            contactsToUpsert.add(cnt);  
        }

        for (CommunicationContacts__c cnt : [SELECT Id, ExternalId__c FROM CommunicationContacts__c WHERE Account__c = :accountId AND ExternalId__c NOT IN :contactsExternalIds]){         
            cnt.Account__c = null;
            contactsToUpsert.add(cnt);  
        }  
            
   
        try {
            upsert contactsToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }
        return 'Success';
    }

    
    private static String upsertAddresses(AccountIntegrationModel requestBodyObj, Id accountId){
        List<AccountIntegrationModel.adressesModel> accountAddressesToupsert = requestBodyObj.addresses;
        if (accountAddressesToupsert == null){
            return '';
        }

        Set<String> addressesExternalIds = new Set<String>();
        for (AccountIntegrationModel.adressesModel addr : accountAddressesToupsert){
            addressesExternalIds.add(addr.Id);
        }    
        
        Map<String, Addresses__c> addressExternalIdToSalesForceAddressMap = new Map<String, Addresses__c>();
        for (Addresses__c addr : [SELECT Id, ExternalAddressId__c, Account__c FROM Addresses__c WHERE ExternalAddressId__c IN :addressesExternalIds AND Account__c = :accountId]){
            addressExternalIdToSalesForceAddressMap.put(addr.ExternalAddressId__c, addr);
        }     
        
        List<Addresses__c> addressesToUpsert = new List<Addresses__c>();                     
        for (AccountIntegrationModel.adressesModel am : accountAddressesToupsert){            
            Addresses__c adr = new Addresses__c();
            adr.Account__c = accountId;
            adr.Id = addressExternalIdToSalesForceAddressMap.get(am.id)?.Id;
            adr.ExternalAddressId__c = am.id;
            adr.Type__c = am.type;
            adr.Country__c = am.country;
            adr.Neighborhood__c = am.neighborhood;
            adr.Street__c = am.street;
            adr.StreetNumber__c = am.streetNumber;
            adr.PostalCode__c = am.zipCode;
            adr.Complement__c = am.complement;
            adr.AreaLevel1__c = am.administrativeAreaLevel1;
            adr.AreaLevel2__c = am.administrativeAreaLevel2;
            adr.AreaLevel3__c = am.administrativeAreaLevel3;
            adr.AreaLevel4__c = am.administrativeAreaLevel4;
            adr.AreaLevel5__c = am.administrativeAreaLevel5;

            addressesToUpsert.add(adr);                              
        }    

        for (Addresses__c addr : [SELECT Id, ExternalAddressId__c FROM Addresses__c WHERE Account__c = :accountId AND ExternalAddressId__c NOT IN :addressesExternalIds]){         
            addr.Account__c = null;
            addressesToUpsert.add(addr);  
        }           

        try {
            upsert addressesToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }
        return 'success';
    }   
    
    private static String upsertRelationships(AccountIntegrationModel requestBodyObj, Id accountId){  
        List<AccountIntegrationModel.relationshipsModel> relationshipsToupsert = requestBodyObj.relationships;
        Map<String, String> relationshipReturnMap = new Map<String, String>(); 
        if (relationshipsToupsert == null){
            return '';
        }
        Map<String, AccountRelationships__c> relationshipsExternalIdToSalesForceRelationshipsMap = new Map<String, AccountRelationships__c>();
        Map<String, Account> relationshipPersonIdToAccountMap = new Map<String, Account>();
        Set<String> relationshipsPersonIds = new Set<String>();
        Set<String> relationshipsExternalIds = new Set<String>();

        for (AccountIntegrationModel.relationshipsModel rtm : relationshipsToupsert){
            relationshipsExternalIds.add(rtm.Id);
            relationshipsPersonIds.add(rtm.personId);
        }    

        for (AccountRelationships__c rtm : [SELECT Id, ExternalId__c, PrimaryRelationship__c FROM AccountRelationships__c WHERE ExternalId__c IN :relationshipsExternalIds]){
            relationshipsExternalIdToSalesForceRelationshipsMap.put(rtm.ExternalId__c, rtm);
        }     
        
        for (Account acc :  [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :relationshipsPersonIds]){
            relationshipPersonIdToAccountMap.put(acc.ExternalId__c, acc);
        }


        List<AccountRelationships__c> accountRelationshipsToUpsert = new List<AccountRelationships__c>();             
        for (AccountIntegrationModel.relationshipsModel rm : relationshipsToupsert){
            Account relationshipAccount = relationshipPersonIdToAccountMap.get(rm.personId);
            if (relationshipAccount == null){
                continue;
            }            
            AccountRelationships__c art = new AccountRelationships__c();
            art.Id =  relationshipsExternalIdToSalesForceRelationshipsMap.get(rm.id)?.Id;
            art.ExternalId__c = rm.id;
            art.Type__c = rm.type;
            art.PrimaryRelationship__c = accountId;
            art.SecondaryRelationship__c = relationshipAccount.Id;    
            
            accountRelationshipsToUpsert.add(art);
        }
        
        List<AccountRelationships__c> arsToDelete = new List<AccountRelationships__c>();
        for (AccountRelationships__c ars : [SELECT PrimaryRelationship__c FROM AccountRelationships__c WHERE PrimaryRelationship__c = :accountId AND ExternalId__c NOT IN :relationshipsExternalIds]){
            arsToDelete.add(ars);
        }

        try {
            upsert accountRelationshipsToUpsert;
            delete arsToDelete;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }
        return 'Success';
    }   
    
    private static String upsertDocuments(AccountIntegrationModel requestBodyObj, Id accountId){ 
        List<AccountIntegrationModel.documentsModel> documentsToUpsert = requestBodyObj.documents;
        if (documentsToUpsert == null){
            return '';
        }
        Set<String> documentsExternalIds = new Set<String>();
        for (AccountIntegrationModel.documentsModel documents : documentsToUpsert){
            documentsExternalIds.add(documents.id);
        }
                
        Map<String, Documents__c> documentsExternalIdsToSalesForceDocumentsMap = new Map<String, Documents__c>();
        for (Documents__c documents : [SELECT Id, Account__c, ExternalId__c FROM Documents__c  WHERE ExternalId__c IN :documentsExternalIds]){
            documentsExternalIdsToSalesForceDocumentsMap.put(documents.ExternalId__c, documents);
        }     

        List<Documents__c> docsToUpsert = new List<Documents__c>();     
        if(documentsToUpsert != null){
            for (AccountIntegrationModel.documentsModel doc : documentsToUpsert){              
                Documents__c documentsSF = new Documents__c();
                documentsSF.Account__c = accountId;
                documentsSF.Id = documentsExternalIdsToSalesForceDocumentsMap.get(doc.id)?.Id;
                documentsSF.ExternalId__c = doc.id;
                documentsSF.DocumentType__c = doc.type;
                documentsSF.DocumentNumber__c = doc.code;             
                documentsSF.Issuer__c = doc.issuer;
                documentsSF.IssuerState__c = doc.issuerState;
            
                if (doc.issueDate != null){
                    documentsSF.IssueDate__c = Date.valueOf(doc.issueDate);
                }
                docsToUpsert.add(documentsSF);                  
            }
        }      

        for (Documents__c doc : [SELECT Account__c FROM Documents__c WHERE Account__c = :accountId AND ExternalId__c NOT IN :documentsExternalIds]){         
            doc.Account__c = null;
            docsToUpsert.add(doc);  
        }             

        try {
            upsert docsToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }
        return 'Success';
    }  
            
    private static String upsertIncome(AccountIntegrationModel requestBodyObj, Id accountId){
        List<AccountIntegrationModel.incomeModel> incomeToUpsert = requestBodyObj.income;
        if (incomeToUpsert == null){
            return '';
        }
        Set<String> incomeExternalIds = new Set<String>();
        for (AccountIntegrationModel.incomeModel incom : incomeToUpsert){
            incomeExternalIds.add(incom.Id);
        }   

        Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap = new Map<String, FinancialResources__c>();
        for (FinancialResources__c incom : [SELECT Id, ExternalId__c FROM FinancialResources__c  WHERE ExternalId__c IN :incomeExternalIds]){
            incomeExternalIdToSalesForceIncomeMap.put(incom.ExternalId__c, incom);
        }

        Set<String> validCurrency = new Set<String>();
        Schema.DescribeFieldResult currencyCodes = Pricebook2.CurrencyIsoCode.getDescribe();
        for (Schema.PicklistEntry pick : currencyCodes.getPicklistValues()){
            validCurrency.add(pick.getValue());
        }

        List<FinancialResources__c> incomesToUpsert = new List<FinancialResources__c>();      
        for (AccountIntegrationModel.incomeModel inc : incomeToUpsert){
            FinancialResources__c income = new FinancialResources__c();   
            if (inc.amount != null){
                if (!validCurrency.contains(inc.amount.currencyCode)){
                    hasError = true;
                    return 'invalid currency code: ' + inc.amount.currencyCode;
                }
                income.CurrencyIsoCode = inc.amount.currencyCode;
                income.Amount__c = Decimal.valueOf(inc.amount.amount);
            }       
            income.Id = incomeExternalIdToSalesForceIncomeMap.get(inc.id)?.Id; 
            income.ExternalId__c = inc.id;
            income.Type__c = inc.type;
            income.Source__c = inc.source;
            income.ExternalCreationDate__c = Date.valueOf(inc.createdAt);
            income.ExternalUpdatedDate__c = Date.valueOf(inc.updatedAt);                         

            incomesToUpsert.add(income);
        }        
        try {
            upsert incomesToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }

        Set<Id> incomeIds = new Set<Id>();
        for (FinancialResources__c income : incomesToUpsert){
            incomeIds.add(income.Id);
        }

        Map<String, Id> accountFinancialRelationshipKeys = new Map<String, Id>();
        for (AccountFinancialRelationship__c afr : [SELECT Id, Account__c, Recurso_Financeiro__c 
                                                    FROM AccountFinancialRelationship__c
                                                    WHERE Account__c = :accountId AND Recurso_Financeiro__c IN :incomeIds]){
            accountFinancialRelationshipKeys.put(afr.Account__c + '_' + afr.Recurso_Financeiro__c, afr.Id);                                         
        }

        List<AccountFinancialRelationship__c> afrToDelete = new List<AccountFinancialRelationship__c>();
        for (AccountFinancialRelationship__c afr : [SELECT Id, Account__c, Recurso_Financeiro__c 
                                                    FROM AccountFinancialRelationship__c
                                                    WHERE Account__c = :accountId AND Recurso_Financeiro__c NOT IN :incomeIds]){
            afrToDelete.add(afr);                                            
        }
        
        List<AccountFinancialRelationship__c> accountRelationshipToUpsert = new List<AccountFinancialRelationship__c>();
        for (FinancialResources__c income : incomesToUpsert){
            AccountFinancialRelationship__c accountIncomeRelationship = new AccountFinancialRelationship__c(Account__c = accountId);
            accountIncomeRelationship.Id = accountFinancialRelationshipKeys.get(accountId + '_' + income.Id);
            accountIncomeRelationship.Recurso_Financeiro__c = income.Id;

            accountRelationshipToUpsert.add(accountIncomeRelationship);
        }
        try {
            upsert accountRelationshipToUpsert;
            delete afrToDelete;
        } catch (System.DmlException e){
            hasError = true;
            return e.getDmlMessage(0);
        }
        return 'Success';
    }
    
    private static Map<String, String> upsertProfessionalInfo(AccountIntegrationModel requestBodyObj, Id accountId){ 
        List<AccountIntegrationModel.professionalInfoModel> professionalInfoToUpsert = requestBodyObj.professionalInfo;
        Map<String, String> professionalInfoReturnMap = new Map<String, String>();   
        if(professionalInfoToUpsert == null){
            return professionalInfoReturnMap;
        }
        Set<String> professionalInfoExternalIds = new Set<String>();
        for (AccountIntegrationModel.professionalInfoModel professionalInfoObj : requestBodyObj.professionalInfo){
            professionalInfoExternalIds.add(professionalInfoObj.Id);
        }  
    
        Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap = new Map<String, ProfessionalInfo__c>();
        for (ProfessionalInfo__c professionalInfoObj : [SELECT Id, ExternalId__c, Account__c  FROM ProfessionalInfo__c WHERE ExternalId__c IN :professionalInfoExternalIds AND Account__c = :accountId]){
            professionalInfoExternalIdToSalesForceProfessionalInfoMap.put(professionalInfoObj.ExternalId__c, professionalInfoObj);
        }     
                                  
        List<ProfessionalInfo__c> professionalsInfoToUpsert = new List<ProfessionalInfo__c>();
        for (AccountIntegrationModel.professionalInfoModel professionalInfoSF :professionalInfoToUpsert){
            ProfessionalInfo__c professionalObj = new ProfessionalInfo__c();     
            professionalObj.Account__c = accountId;
            professionalObj.Id = professionalInfoExternalIdToSalesForceProfessionalInfoMap.get(professionalInfoSF.id)?.Id;
            professionalObj.JobTitle__c = professionalInfoSF.jobTitle;
            professionalObj.CompanyName__c = professionalInfoSF.companyName;
            professionalObj.EconomicActivity__c = professionalInfoSF.economicActivity;
            professionalObj.Status__c = professionalInfoSF.status;
            professionalObj.Category__c = professionalInfoSF.category;
            professionalObj.Current__c = professionalInfoSF.current;
            professionalObj.ExternalId__c = professionalInfoSF.id;
                                        
            if(professionalInfoSF.startDate != null){
                if(professionalInfoSF.startDate.year != null && professionalInfoSF.startDate.month != null){
                    professionalObj.StartDate__c = date.newinstance(integer.valueOf(professionalInfoSF.startDate.year), integer.valueOf(professionalInfoSF.startDate.month), 1);
                }
            }           
            professionalsInfoToUpsert.add(professionalObj);               
        }

        for (ProfessionalInfo__c profInfo : [SELECT Account__c FROM ProfessionalInfo__c WHERE Account__c = :accountId AND ExternalId__c NOT IN :professionalInfoExternalIds]){
            profInfo.Account__c = null;
            professionalsInfoToUpsert.add(profInfo);
        }

        try {
            upsert professionalsInfoToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            professionalInfoReturnMap.put('dmlErrorMessage', e.getDmlMessage(0));
            professionalInfoReturnMap.put('friendlyErrorMessage','An error has occurred upserting Professional Info object.');
            return professionalInfoReturnMap;
        }

                        
        Set<Id> professionalInfoIds = new Set<Id>();
        Map<String, Id> professionalInfoExternalIdToSalesforceIdMap = new Map<String, Id>();
        for(ProfessionalInfo__c professionalObj : professionalsInfoToUpsert){
            professionalInfoExternalIdToSalesforceIdMap.put(professionalObj.ExternalId__c, professionalObj.Id);
            professionalInfoIds.add(professionalObj.Id);
        }
        
        Map<Id, Id> professionalInfoIdToProfessionalIncomeIdMap = new Map<Id, Id>();
        for(FinancialResources__c financialResources : [SELECT Id, ExternalId__c, ProfessionalInfo__c, ProfessionalInfo__r.ExternalId__c FROM FinancialResources__c WHERE ProfessionalInfo__c IN :professionalInfoIds]){                
            professionalInfoIdToProfessionalIncomeIdMap.put(financialResources.ProfessionalInfo__c, financialResources.Id);
        }
        
        List<FinancialResources__c> professionalInfoIncomeToUpsert = new List<FinancialResources__c>();
        Set<String> validCurrency = new Set<String>();
        Schema.DescribeFieldResult currencyCodes = Pricebook2.CurrencyIsoCode.getDescribe();
        for (Schema.PicklistEntry pick : currencyCodes.getPicklistValues()){
            validCurrency.add(pick.getValue());
        }

        for(AccountIntegrationModel.professionalInfoModel professionalInfoSF : professionalInfoToUpsert){
            if (professionalInfoSF.professionalIncome != null && professionalInfoSF.professionalIncome.size() > 0) {

                Id professionalInfoId = professionalInfoExternalIdToSalesforceIdMap.get(professionalInfoSF.id);
                
                FinancialResources__c professionalInfoIncome = new FinancialResources__c();
                professionalInfoIncome.Id = professionalInfoIdToProfessionalIncomeIdMap.get(professionalInfoId);
                if (professionalInfoSF.professionalIncome[0].amount != null){
                    String currencyCode = professionalInfoSF.professionalIncome[0].amount.currencyCode;
                    if (!validCurrency.contains(currencyCode)){
                        hasError = true;
                        String errorMessage = 'invalid currency code: ' + currencyCode;
                        professionalInfoReturnMap.put('dmlErrorMessage',errorMessage);
                        professionalInfoReturnMap.put('friendlyErrorMessage', errorMessage);
                        return professionalInfoReturnMap;
                    }
                    professionalInfoIncome.Amount__c =  Decimal.valueOf(professionalInfoSF.professionalIncome[0].amount.amount);  
                    professionalInfoIncome.CurrencyIsoCode = currencyCode; 
                }
                professionalInfoIncome.Type__c = professionalInfoSF.professionalIncome[0].type;
                professionalInfoIncome.Source__c = professionalInfoSF.professionalIncome[0].source;
                professionalInfoIncome.ExternalId__c = professionalInfoSF.id;   
                professionalInfoIncome.ProfessionalInfo__c = professionalInfoId;

                professionalInfoIncomeToUpsert.add(professionalInfoIncome);
            } 
        } 
        try {
            upsert professionalInfoIncomeToUpsert;
        } catch (System.DmlException e){
            hasError = true;
            professionalInfoReturnMap.put('dmlErrorMessage', e.getDmlMessage(0));
            professionalInfoReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Professional Income object.');
            return professionalInfoReturnMap;
        }
  
        Set<Id> financialResourceIds = new Set<Id>();
        for(FinancialResources__c professionalInfoIncome :professionalInfoIncomeToUpsert){
            financialResourceIds.add(professionalInfoIncome.Id);
        }

        Map<String, Id> financialResourceKeys = new Map<String, Id>();
        for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__c, Recurso_Financeiro__c 
                                                                    FROM AccountFinancialRelationship__c 
                                                                    WHERE Account__c = :accountId 
                                                                    AND Recurso_Financeiro__c IN :financialResourceIds]){
            financialResourceKeys.put(accountRelation.Account__c + '_' + accountRelation.Recurso_Financeiro__c, accountRelation.Id);
        }
    
        List<AccountFinancialRelationship__c> professionalRelationshipToUpsert = new List<AccountFinancialRelationship__c>();
        for(FinancialResources__c professionalInfoIncome :professionalInfoIncomeToUpsert){
            AccountFinancialRelationship__c professionalIncomeRelationship = new AccountFinancialRelationship__c();
            professionalIncomeRelationship.Id = financialResourceKeys.get(accountId + '_' + professionalInfoIncome.Id);
            professionalIncomeRelationship.Account__c = accountId;
            professionalIncomeRelationship.Recurso_Financeiro__c = professionalInfoIncome.id;
            
            professionalRelationshipToUpsert.add(professionalIncomeRelationship);
        }   

        List<AccountFinancialRelationship__c> professionalRelationshipToDelete = new List<AccountFinancialRelationship__c>();
        for (AccountFinancialRelationship__c afr : [SELECT Account__c FROM AccountFinancialRelationship__c WHERE Account__c = :accountId AND Recurso_Financeiro__c NOT IN :financialResourceIds]){
            professionalRelationshipToDelete.add(afr);
        }


        try {
            upsert professionalRelationshipToUpsert;
            delete professionalRelationshipToDelete;
        } catch (System.DmlException e){
            hasError = true;
            professionalInfoReturnMap.put('dmlErrorMessage', e.getDmlMessage(0));
            professionalInfoReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Professional Income object.');
        }  
        return professionalInfoReturnMap; 
    } 

    public static void setErrorResponse(Integer errorCode, String errorMessage){
        AccountResponseData resp = new AccountResponseData();
        resp.accountId = null;
        resp.message = errorMessage != '' ? errorMessage : 'An error has occurred. Please, contact a Salesforce Administrator.';
        resp.status = errorCode;

        RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(resp));
        res.statusCode = errorCode;
    }

    public static void insertErrorLog(Integer errorCode, String errorMessage, String requestBodyString){
        System.debug('Error >> '+errorMessage);
        API_Transaction_Errors__b ate = new API_Transaction_Errors__b();
        ate.Endpoint__c = '/services/apexrest/IntegrationAccountIN';
        ate.RequestBody__c = requestBodyString;
        ate.ReturnCode__c = errorCode;
        ate.ErrorMessage__c = errorMessage;
        ate.CreatedDate__c = System.now();
        ate.CreatedBy__c = UserInfo.getUserId();

        try {
            if (!Test.isRunningTest()){
 				database.insertImmediate(ate);                
            }
        } catch (Exception e) {
            setErrorResponse(500, e.getMessage());
        }
    }

    public static Map<String, String> commitTransactions(AccountIntegrationModel requestBodyObj){
        Boolean varSuccessAccount = false, varSuccessContacts = false, varSuccessAddresses = false, varSuccessDocs = false,
        varSuccessIncome = false, varSuccessProfessionalInfo = false, varSuccessRelationships = false;
        Id accountId;
        Map<String, String> commitReturnMap = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        if (!hasError)
        {
            try
            {
                Map<String, String> accountReturnMap = upsertAccount(requestBodyObj);
                if (!hasError){
                    accountId = accountReturnMap.get('accountId');
                    commitReturnMap.put('accountId', accountId);
                    varSuccessAccount = true;                
                } else {
                    commitReturnMap.put('dmlErrorMessage', accountReturnMap.get('dmlErrorMessage'));
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Account object.');   
                    Database.rollback(sp); 
                }

            } catch(Exception e)
            {
                commitReturnMap.put('dmlErrorMessage', e.getMessage());
                commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Account object.');   
                hasError = true;
                Database.rollback(sp); 
            }
            if(varSuccessAccount)
            {
                try
                {
                    String contactsError = upsertContacts(requestBodyObj, accountId);
                    if (!hasError){
                        varSuccessContacts = true;               
                    } else {
                        commitReturnMap.put('dmlErrorMessage', contactsError);
                        commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Contact object.');   
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Contact object.');  
                    Database.rollback(sp); 
                }
            }
            if(varSuccessContacts)
            {
                try
                {
                    String addressError = upsertAddresses(requestBodyObj, accountId);
                    if (!hasError){
                        varSuccessAddresses = true;               
                    } else {
                        commitReturnMap.put('dmlErrorMessage', addressError);
                        commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Address object.');   
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Address object.');  
                    Database.rollback(sp); 
                }
            }
            if(varSuccessAddresses)
            {
                try
                {
                    String documentsError = upsertDocuments(requestBodyObj, accountId);
                    if (!hasError){
                        varSuccessDocs = true;
                    } else {
                        commitReturnMap.put('dmlErrorMessage', documentsError);
                        commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Document object.');  
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Document object.');  
                    Database.rollback(sp); 
                }
            }
            if(varSuccessDocs)
            {
                try
                {
                    String incomeError = upsertIncome(requestBodyObj, accountId);
                    if (!hasError){
     					varSuccessIncome = true;                   
                    } else {
                        String errorMessageToReturn = incomeError.contains('currency') ? incomeError : 'An error has occurred upserting Income object.';
                        commitReturnMap.put('dmlErrorMessage', incomeError);
                        commitReturnMap.put('friendlyErrorMessage', errorMessageToReturn); 
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Income object.'); 
                    Database.rollback(sp); 
                }
            }
            if(varSuccessIncome)
            {
                try
                {
                    Map<String, String> errorsProfessionalInfo = upsertProfessionalInfo(requestBodyObj, accountId);
                    if (!hasError){
                        varSuccessProfessionalInfo = true;                 
                    } else {
                        commitReturnMap.put('dmlErrorMessage', errorsProfessionalInfo.get('dmlErrorMessage'));
                        commitReturnMap.put('friendlyErrorMessage', errorsProfessionalInfo.get('friendlyErrorMessage'));
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Professional Info object.');
                    Database.rollback(sp); 
                }
            }
            if(varSuccessProfessionalInfo)
            {
                try
                {
                    String relationshipError = upsertRelationships(requestBodyObj, accountId);
                    if (!hasError){
                        varSuccessRelationships = true;              
                    } else {
                        commitReturnMap.put('dmlErrorMessage', relationshipError);
                        commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Relationship object.'); 
                        Database.rollback(sp); 
                    }
                } catch(Exception e)
                {
                    hasError = true;
                    commitReturnMap.put('dmlErrorMessage', e.getMessage());
                    commitReturnMap.put('friendlyErrorMessage', 'An error has occurred upserting Relationship object.'); 
                    Database.rollback(sp); 
                }
            }
        }
        return commitReturnMap;
    }
   
    public class AccountResponseData{
        public String accountId;
        public String message;
        public Integer status;
    }
}