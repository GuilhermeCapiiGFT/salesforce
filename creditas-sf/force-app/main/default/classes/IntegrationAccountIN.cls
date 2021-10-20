/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Web Service customizado para cadastrar/atualizar dados de Person/Account
* ================================================================================================================================
* History
* -------
* VERSION   AUTHORS                  DATE            DETAIL      Description
* 1.0       Gabriel Vidal        20/09/2021         Created     Implementação das requisições REST do web service de Account
            Nathália Rosa          
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationAccountIN/*')
global without sharing class IntegrationAccountIN {
    
    @HttpPost
    global static void postMethod(){
        Set<String> contactsExternalIds = new Set<String>();
        Set<String> addressesExternalIds = new Set<String>();
        Set<String> relationshipsExternalIds = new Set<String>();
        Set<String> relationshipsPersonIds = new Set<String>();
        Set<String> documentsExternalIds = new Set<String>();
        Set<String> incomeExternalIds = new Set<String>();
        Set<String> professionalInfoExternalIds = new Set<String>();
        Set<String> accountRelationshipExternalIds = new Set<String>();
        Map<String, CommunicationContacts__c> contactKeyToSalesForceContactsMap = new Map<String, CommunicationContacts__c>();
        Map<String, Addresses__c> addressExternalIdToSalesForceAddressMap = new Map<String, Addresses__c>();
        Map<String, AccountRelationships__c> relationshipsExternalIdToSalesForceRelationshipsMap = new Map<String, AccountRelationships__c>();
        Map<String, Account> relationshipPersonIdToAccountMap = new Map<String, Account>();
        Map<String, Documents__c> documentsExternalIdsToSalesForceDocumentsMap = new Map<String, Documents__c>();
        Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap = new Map<String, FinancialResources__c>();
        Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap = new Map<String, ProfessionalInfo__c>();
        Map<String, AccountFinancialRelationship__c> accountExternalIdToSalesforceMap = new Map<String, AccountFinancialRelationship__c>(); 
             
        AccountIntegrationModel typedRequestBody = AccountIntegrationModel.parse(RestContext.request.requestBody.toString());
        for(AccountIntegrationModel.professionalInfoModel professionalInfo : typedRequestBody.professionalInfo){
            if(professionalInfo.professionalIncome != null && professionalInfo.professionalIncome.size() > 1){

                AccountResponseData ard = new AccountResponseData();
                ard.accountId = null;
                ard.message = 'Incorrect professionalIncome';

                RestResponse res = RestContext.response;
                if (res == null) {
                    res = new RestResponse();
                    RestContext.response = res;
                }
                res.responseBody = Blob.valueOf(JSON.serialize(ard));
                res.statusCode = 400;
                return;
            }
        }
        String accountExternalId = typedRequestBody.Id;  
        
        List<Account> existingAccounts = [SELECT ExternalId__c FROM Account WHERE ExternalId__c = :accountExternalId];                 
        typedRequestBody.salesforceId = existingAccounts.size() == 0 ? null : existingAccounts[0].Id;  
        
        AccountResponseData ard = upsertAccount(typedRequestBody);
        String accountId = ard.accountId;
                
         //Contacts
        for (CommunicationContacts__c cnt : [SELECT Id, Account__c, Code__c, Channel__c FROM CommunicationContacts__c WHERE Account__c = :accountId]){
            contactKeyToSalesForceContactsMap.put(cnt.Channel__c + '_' + cnt.Code__c, cnt);
        }            
        if(typedRequestBody.contacts != null){
            for (AccountIntegrationModel.contactsModel cm : typedRequestBody.contacts){
                String contactKey = cm.channel + '_' + cm.code;
                CommunicationContacts__c salesForceContact = contactKeyToSalesForceContactsMap.get(contactKey);
                cm.isUpdate = salesForceContact != null;                                  
            }
        }
                
        upsertContacts(typedRequestBody.contacts, accountId);
        
        //Addresses
        if(typedRequestBody.addresses != null){
            for (AccountIntegrationModel.adressesModel addr : typedRequestBody.addresses){
                addressesExternalIds.add(addr.Id);
                addr.isUpdate = false;
            }    
        }
           
        for (Addresses__c addr : [SELECT Id, ExternalAddressId__c, Account__c FROM Addresses__c WHERE ExternalAddressId__c IN :addressesExternalIds AND Account__c = :accountId]){
            addressExternalIdToSalesForceAddressMap.put(addr.ExternalAddressId__c, addr);
        }     
        
        upsertAddresses(typedRequestBody.addresses, accountId, addressExternalIdToSalesForceAddressMap);
        
        //Relationship
        if(typedRequestBody.relationships != null){
            for (AccountIntegrationModel.relationshipsModel rtm : typedRequestBody.relationships){
                relationshipsExternalIds.add(rtm.Id);
                relationshipsPersonIds.add(rtm.personId);
                rtm.isUpdate = false;
            }    
        }
           
        for (AccountRelationships__c rtm : [SELECT Id, ExternalId__c, PrimaryRelationship__c FROM AccountRelationships__c WHERE ExternalId__c IN :relationshipsExternalIds]){
            relationshipsExternalIdToSalesForceRelationshipsMap.put(rtm.ExternalId__c, rtm);
        }     
        
        for (Account acc :  [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :relationshipsPersonIds]){
            relationshipPersonIdToAccountMap.put(acc.ExternalId__c, acc);
        }
        
        upsertRelationships(typedRequestBody.relationships, accountId, relationshipsExternalIdToSalesForceRelationshipsMap, relationshipPersonIdToAccountMap);
        
        //Documents
        if(typedRequestBody.documents != null){
            for (AccountIntegrationModel.documentsModel documents : typedRequestBody.documents){
                documentsExternalIds.add(documents.id);
                documents.isUpdate = false;
           }
        }
    
        for (Documents__c documents : [SELECT Id, Account__c, ExternalId__c FROM Documents__c  WHERE ExternalId__c IN :documentsExternalIds AND Account__c = :accountId]){
            documentsExternalIdsToSalesForceDocumentsMap.put(documents.ExternalId__c, documents);
        }     
        
        upsertDocuments(typedRequestBody.documents, accountId, documentsExternalIdsToSalesForceDocumentsMap);
        
        //Income Model / Recursos Financeiros
        if(typedRequestBody.income != null){
            for (AccountIntegrationModel.incomeModel incom : typedRequestBody.income){
              incomeExternalIds.add(incom.Id);
              accountRelationshipExternalIds.add(incom.id);
              incom.isUpdate = false;
           }   
        }
        // for (ProfessionalInfo__c professionalInfoObj : [SELECT Id, ExternalId__c, Account__c  FROM ProfessionalInfo__c WHERE ExternalId__c IN :incomeExternalIds AND Account__c = :accountId]){
        // professionalInfoExternalIdToSalesForceProfessionalInfoMap.put(professionalInfoObj.ExternalId__c, professionalInfoObj);
        // }     
        
        for (FinancialResources__c incom : [SELECT Id, ExternalId__c FROM FinancialResources__c  WHERE ExternalId__c IN :incomeExternalIds]){
           incomeExternalIdToSalesForceIncomeMap.put(incom.ExternalId__c, incom);
      }    
        
       for(AccountFinancialRelationship__c accountRelationship : [SELECT Id, Account__c, Recurso_Financeiro__c FROM AccountFinancialRelationship__c WHERE Account__c IN :accountRelationshipExternalIds]){
        accountExternalIdToSalesforceMap.put(accountRelationship.Account__c, accountRelationship);
       }
        
      upsertIncome(typedRequestBody.income, accountId, incomeExternalIdToSalesForceIncomeMap, accountExternalIdToSalesforceMap, professionalInfoExternalIdToSalesForceProfessionalInfoMap);
    
        //professionalInfo
        if(typedRequestBody.professionalInfo !=null){
            for (AccountIntegrationModel.professionalInfoModel professionalInfoObj : typedRequestBody.professionalInfo){
                professionalInfoExternalIds.add(professionalInfoObj.Id);
                professionalInfoObj.isUpdate = false;
           }  
        }
             
        for (ProfessionalInfo__c professionalInfoObj : [SELECT Id, ExternalId__c, Account__c  FROM ProfessionalInfo__c WHERE ExternalId__c IN :professionalInfoExternalIds AND Account__c = :accountId]){
            professionalInfoExternalIdToSalesForceProfessionalInfoMap.put(professionalInfoObj.ExternalId__c, professionalInfoObj);
        }     

        upsertProfessionalInfo(typedRequestBody.professionalInfo, accountId, professionalInfoExternalIdToSalesForceProfessionalInfoMap, incomeExternalIdToSalesForceIncomeMap);
        
        //Response
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.responseBody = Blob.valueOf(JSON.serialize(ard));
        res.statusCode = 200;
    }
               
    private static void upsertContacts(List<AccountIntegrationModel.contactsModel> accountContactsToUpsert, String accountId){
        List<CommunicationContacts__c> contactsToInsert = new List<CommunicationContacts__c>();           
        
        if(accountContactsToUpsert != null){
            for (AccountIntegrationModel.contactsModel cm : accountContactsToUpsert){
                CommunicationContacts__c cnt = new CommunicationContacts__c();
                cnt.Channel__c = cm.channel;
                cnt.Code__c = cm.code;
                cnt.Type__c = cm.type;
                cnt.Account__c = accountId;
                if (!cm.isUpdate){
                    contactsToInsert.add(cnt);  
                } 
            }
        }
        
        if (contactsToInsert.size() > 0)
            insert contactsToInsert;
    }

    
    private static void upsertAddresses(List<AccountIntegrationModel.adressesModel> accountAddressesToupsert, Id accountId,  Map<String, Addresses__c> addressExternalIdToSalesForceAddressMap){
        List<Addresses__c> addressesToInsert = new List<Addresses__c>();
        List<Addresses__c> addressesToUpdate = new List<Addresses__c>();       
                
        if(accountAddressesToupsert != null){
            for (AccountIntegrationModel.adressesModel am : accountAddressesToupsert){
                Addresses__c salesForceAddress = addressExternalIdToSalesForceAddressMap.get(am.id);
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
                adr.Complement__c = am.complement;
                adr.AreaLevel1__c = am.administrativeAreaLevel1;
                adr.AreaLevel2__c = am.administrativeAreaLevel2;
                adr.AreaLevel3__c = am.administrativeAreaLevel3;
                adr.AreaLevel4__c = am.administrativeAreaLevel4;
                adr.AreaLevel5__c = am.administrativeAreaLevel5;
                                
                if (am.isUpdate){
                    adr.Id = salesForceAddress.Id;
                    addressesToUpdate.add(adr);  
                } else {
                    addressesToInsert.add(adr);
                }
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
        
        if( relationshipsToupsert != null){
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
        }
        
        if (relationshipsToInsert.size() > 0)
            insert relationshipsToInsert;
        if (relationshipsToUpdate.size() > 0)
            update relationshipsToUpdate;
    }   
    
    private static void upsertDocuments(List<AccountIntegrationModel.documentsModel> documentsToUpsert, Id accountId, Map<String, Documents__c> documentsExternalIdsToSalesForceDocumentsMap){ 
        List<Documents__c> documentsToInsert = new List<Documents__c>();
        List<Documents__c> documentsToUpdate = new List<Documents__c>();  
        
        if(documentsToUpsert != null){
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
                       
                if (doc.isUpdate){
                    documentsSF.Id = salesForceDocuments.Id;
                    documentsToUpdate.add(documentsSF);  
                } else {
                    documentsToInsert.add(documentsSF);
                }
            }
        }
        
        if (documentsToInsert.size() > 0)
            insert documentsToInsert;
        if (documentsToUpdate.size() > 0)
            update documentsToUpdate;
    }  
            
    private static void upsertIncome(List<AccountIntegrationModel.incomeModel> incomeToUpsert, Id accountId, Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap, Map<String, AccountFinancialRelationship__c> accountExternalIdToSalesforceMap, Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap){ 
        List<FinancialResources__c> incomesToUpsert = new List<FinancialResources__c>();
        List<AccountFinancialRelationship__c> accountRelationshipToUpsert = new List<AccountFinancialRelationship__c>();
        
        if(incomesToUpsert != null) {
            for (AccountIntegrationModel.incomeModel inc : incomeToUpsert){
                FinancialResources__c salesForceIncome = incomeExternalIdToSalesForceIncomeMap.get(inc.id);
                                                    
                FinancialResources__c income = new FinancialResources__c();
                income.ExternalId__c = inc.id;
                income.Type__c = inc.type;
                income.Source__c = inc.source;
                income.CurrencyIsoCode = inc.amount.currencyCode;
                income.Amount__c = Decimal.valueOf(inc.amount.amount);
                income.ExternalCreationDate__c = Date.valueOf(inc.createdAt);
                income.ExternalUpdatedDate__c = Date.valueOf(inc.updatedAt);                         

                income.Id = salesForceIncome?.Id; 

                incomesToUpsert.add(income);
            }
        }

        if (incomeToUpsert.size() > 0)
            upsert incomesToUpsert;

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
        
        for (FinancialResources__c income : incomesToUpsert){
            AccountFinancialRelationship__c accountIncomeRelationship = new AccountFinancialRelationship__c();
            accountIncomeRelationship.Id = accountFinancialRelationshipKeys.get(accountId + '_' + income.Id);
            accountIncomeRelationship.Account__c = accountId;
            accountIncomeRelationship.Recurso_Financeiro__c = income.Id;

            accountRelationshipToUpsert.add(accountIncomeRelationship);
        }
       
        if(accountRelationshipToUpsert.size() >0){
            upsert accountRelationshipToUpsert;
        }
    }
    
    private static void upsertProfessionalInfo(List<AccountIntegrationModel.professionalInfoModel> professionalInfoToUpsert, Id accountId, 
                                               Map<String, ProfessionalInfo__c> professionalInfoExternalIdToSalesForceProfessionalInfoMap,  Map<String, FinancialResources__c> incomeExternalIdToSalesForceIncomeMap){ 
        List<ProfessionalInfo__c> professionalsInfoToUpsert = new List<ProfessionalInfo__c>();
        List<FinancialResources__c> professionalInfoIncomeToUpsert = new List<FinancialResources__c>();
        List<AccountFinancialRelationship__c> professionalRelationshipToUpsert = new List<AccountFinancialRelationship__c>();
        
        if(professionalsInfoToUpsert != null){
            for (AccountIntegrationModel.professionalInfoModel professionalInfoSF :professionalInfoToUpsert){
                Id salesForceProfessionalInfoId = professionalInfoExternalIdToSalesForceProfessionalInfoMap.get(professionalInfoSF.id)?.Id;
                  
                ProfessionalInfo__c professionalObj = new ProfessionalInfo__c();          
                professionalObj.JobTitle__c = professionalInfoSF.jobTitle;
                professionalObj.CompanyName__c = professionalInfoSF.companyName;
                professionalObj.EconomicActivity__c = professionalInfoSF.economicActivity;
                professionalObj.Status__c = professionalInfoSF.status;
                professionalObj.Category__c = professionalInfoSF.category;
                professionalObj.Current__c = professionalInfoSF.current;
                professionalObj.Account__c = accountId;
                professionalObj.ExternalId__c = professionalInfoSF.id;
                                            
                if(professionalInfoSF.startDate != null){

                    if(professionalInfoSF.startDate.year != null || professionalInfoSF.startDate.month != null){
                        professionalObj.StartDate__c = date.newinstance(integer.valueOf(professionalInfoSF.startDate.year), integer.valueOf(professionalInfoSF.startDate.month), 1);
                    }
                }

                professionalObj.Id = salesForceProfessionalInfoId;

                professionalsInfoToUpsert.add(professionalObj);
                 
              }
        }
              if (professionalInfoToUpsert.size() > 0)
                
                  upsert professionalsInfoToUpsert;
                               
                Set<Id> professionalInfoIds = new Set<Id>();
                Map<String, Id> professionalInfoExternalIdToSalesforceIdMap = new  Map<String, Id>();
                for(ProfessionalInfo__c professionalObj : professionalsInfoToUpsert){
                    professionalInfoExternalIdToSalesforceIdMap.put(professionalObj.ExternalId__c, professionalObj.Id);
                    professionalInfoIds.add(professionalObj.Id);
                }
                
                Map<Id, Id> professionalInfoIdToProfessionalIncomeIdMap = new Map<Id, Id>();
                for(FinancialResources__c financialResources : [SELECT Id, ExternalId__c, ProfessionalInfo__c, ProfessionalInfo__r.ExternalId__c FROM FinancialResources__c WHERE ProfessionalInfo__c IN :professionalInfoIds]){                
                    professionalInfoIdToProfessionalIncomeIdMap.put(financialResources.ProfessionalInfo__c, financialResources.Id);
                }
                
          
                for(AccountIntegrationModel.professionalInfoModel professionalInfoSF : professionalInfoToUpsert){
                    if (professionalInfoSF.professionalIncome != null && professionalInfoSF.professionalIncome.size() > 0) {

                        //FinancialResources__c salesForceProfessionalInfoIncome = incomeExternalIdToSalesForceIncomeMap.get(professionalInfoSF.id);
                        Id professionalInfoId = professionalInfoExternalIdToSalesforceIdMap.get(professionalInfoSF.id);
                        
                        FinancialResources__c professionalInfoIncome = new FinancialResources__c();
                        professionalInfoIncome.Id = professionalInfoIdToProfessionalIncomeIdMap.get(professionalInfoId);
                        professionalInfoIncome.Amount__c =  Decimal.valueOf(professionalInfoSF.professionalIncome[0].amount.amount);  
                        professionalInfoIncome.CurrencyIsoCode = professionalInfoSF.professionalIncome[0].amount.currencyCode; 
                        professionalInfoIncome.Type__c = professionalInfoSF.professionalIncome[0].type;
                        professionalInfoIncome.Source__c = professionalInfoSF.professionalIncome[0].source;
                        professionalInfoIncome.ExternalId__c = professionalInfoSF.id;   
                        professionalInfoIncome.ProfessionalInfo__c = professionalInfoId;

                        //professionalInfoIncome.Id = salesForceProfessionalInfoIncome?.Id;
     
                        professionalInfoIncomeToUpsert.add(professionalInfoIncome);
                  } 
                } 
                        if (professionalInfoIncomeToUpsert.size() > 0){
                        upsert professionalInfoIncomeToUpsert;
                     
                 	 Set<Id> financialResourceIds = new Set<Id>();
                       for(FinancialResources__c professionalInfoIncome :professionalInfoIncomeToUpsert){
            		   financialResourceIds.add(professionalInfoIncome.Id);
      			   }
    
                Map<String, Id> financialResourceKeys = new Map<String, Id>();
                for(AccountFinancialRelationship__c accountRelation : [SELECT Id, Account__c, Recurso_Financeiro__c 
                                                                            FROM AccountFinancialRelationship__c 
                                                                            WHERE Account__c = :accountId 
                                                                            AND Recurso_Financeiro__c IN :financialResourceIds]){
                    System.debug('map key: '+accountRelation.Account__c + '_' + accountRelation.Recurso_Financeiro__c);
                    financialResourceKeys.put(accountRelation.Account__c + '_' + accountRelation.Recurso_Financeiro__c, accountRelation.Id);
                }
				
                for(FinancialResources__c professionalInfoIncome :professionalInfoIncomeToUpsert){
                    AccountFinancialRelationship__c professionalIncomeRelationship = new AccountFinancialRelationship__c();
                    professionalIncomeRelationship.Id = financialResourceKeys.get(accountId + '_' + professionalInfoIncome.Id);
                    professionalIncomeRelationship.Account__c = accountId;
                    professionalIncomeRelationship.Recurso_Financeiro__c = professionalInfoIncome.Id;
                    
                    professionalRelationshipToUpsert.add(professionalIncomeRelationship);
                }
                           
                    if(professionalRelationshipToUpsert.size() > 0){
                        upsert professionalRelationshipToUpsert;
                    } 
                }
             }              
    private static AccountResponseData upsertAccount(AccountIntegrationModel typedAccountToUpsert){
        Account accountToUpsert = new Account();
        accountToUpsert.ExternalId__c = typedAccountToUpsert.id;
        Boolean isUpdate = typedAccountToUpsert.salesforceId != null;
        
        if(typedAccountToUpsert != null){    
            accountToUpsert.Name = typedAccountToUpsert.fullName;
            accountToUpsert.Gender__c = typedAccountToUpsert.gender;
            accountToUpsert.ExternalTenant__c = typedAccountToUpsert.tenant;
            accountToUpsert.ExternalModifiedBy__c = typedAccountToUpsert.modifiedBy;
            accountToUpsert.CivilStatus__c = typedAccountToUpsert.civilStatus;
            accountToUpsert.Birth_City__c = typedAccountToUpsert.cityOfBirth;
            accountToUpsert.Birth_Country__c = typedAccountToUpsert.countryOfBirth;
            accountToUpsert.Nationality__c = typedAccountToUpsert.nationality;
            
            if(typedAccountToUpsert.birthDate != null){ 
                accountToUpsert.BirthDate__c = Date.valueOf(typedAccountToUpsert.birthDate);
            }   
            
            if(typedAccountToUpsert.createdAt != null){
                accountToUpsert.ExternalCreationDate__c = Date.valueOf(typedAccountToUpsert.createdAt);
            }
            
            if(typedAccountToUpsert.updatedAt != null){
                accountToUpsert.ExternalUpdatedDate__c = Date.valueOf(typedAccountToUpsert.updatedAt);   
            }
            
            accountToUpsert.ExternalVersion__c = typedAccountToUpsert.version;
        }    
            
        if(typedAccountToUpsert.mainDocument != null){
            accountToUpsert.DocumentType__c = typedAccountToUpsert.mainDocument.type;
            accountToUpsert.DocumentNumber__c = typedAccountToUpsert.mainDocument.code;
        }
       
        if(typedAccountToUpsert.additionalProperties != null){
            accountToUpsert.FirstName__c = typedAccountToUpsert.additionalProperties.firstName;
            accountToUpsert.SecondName__c = typedAccountToUpsert.additionalProperties.secondName;
            accountToUpsert.LastName__c = typedAccountToUpsert.additionalProperties.lastName;
            accountToUpsert.SecondLastName__c = typedAccountToUpsert.additionalProperties.secondLastName;
            accountToUpsert.Curp__c = typedAccountToUpsert.additionalProperties.curp;
            accountToUpsert.IneNumber__c = typedAccountToUpsert.additionalProperties.ineNumber;
            accountToUpsert.BankName__c = typedAccountToUpsert.additionalProperties.bankName;
            accountToUpsert.BankAccountNumber__c = typedAccountToUpsert.additionalProperties.accountNumber;
            accountToUpsert.Clabe__c = typedAccountToUpsert.additionalProperties.clabe;
            
            if(typedAccountToUpsert.additionalProperties.politicallyExposed == null){
                accountToUpsert.PoliticallyExposed__c = false;
            }else{
                accountToUpsert.PoliticallyExposed__c = typedAccountToUpsert.additionalProperties.politicallyExposed;
            }
        }
    
        if(typedAccountToUpsert.education != null){
            accountToUpsert.Education__c = typedAccountToUpsert.education.degree;
        }
        
        //if(typedAccountToUpsert.filiation != null){
        //}
         
        if(typedAccountToUpsert.wealth != null){
            if(typedAccountToUpsert.wealth.networthLowerLimit != null){
                accountToUpsert.NetWorthLowerLimit__c = decimal.valueof(typedAccountToUpsert.wealth.networthLowerLimit);
            }
            
            if(typedAccountToUpsert.wealth.networthUpperLimit != null){
                 accountToUpsert.NetWorthUpperLimit__c = decimal.valueof(typedAccountToUpsert.wealth.networthUpperLimit);
            }
            
            if(typedAccountToUpsert.wealth.currencyCode != null){
                accountToUpsert.CurrencyIsoCode = typedAccountToUpsert.wealth.currencyCode; 
            }
        }
                            
        if (isUpdate){
            accountToUpsert.Id = typedAccountToUpsert.salesforceId;
            update accountToUpsert;
        } else {
            insert accountToUpsert;
        }
               
        AccountResponseData ard = new AccountResponseData();
        ard.accountId = accountToUpsert.Id;
        ard.message = isUpdate ? 'Account sucessfully updated.' : 'Account sucessfully created.';
        
        return ard;
    }  
   
    public class AccountResponseData{
        public String accountId;
        public String message;
    }
}