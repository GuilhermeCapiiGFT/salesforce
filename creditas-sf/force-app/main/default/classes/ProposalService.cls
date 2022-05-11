public with sharing class ProposalService 
{
    Integer historyLimit;
    
    public ProposalService() 
    {
        this.historyLimit = (Integer) Object_Section_History_Limit__mdt.getInstance('History_Limit').Value__c;
    }

    public static void start(Id accountId, Id opportunityId) 
    {
        List<SObject> sectionRecords = new List<SObject>();

        PersonalDataSection__c personalDataSection = new PersonalDataSection__c(Opportunity__c = opportunityId);
        ContactDetailsSection__c contactDataSection = new ContactDetailsSection__c(Opportunity__c = opportunityId);
        AddressDataSection__c addressDataSection = new AddressDataSection__c(Opportunity__c = opportunityId);
        WarrantyDataSection__c warrantyDataSection = new WarrantyDataSection__c(Opportunity__c = opportunityId);
        IncomeDataSection__c incomeDataSection = new IncomeDataSection__c(Opportunity__c = opportunityId);
        OperationSection__c operationDataSection = new OperationSection__c(Opportunity__c = opportunityId);

        copyPersonalDataSection(accountId, opportunityId, personalDataSection);
        copyContactDataSection(accountId, opportunityId, contactDataSection);
        copyAddressDataSection(accountId, opportunityId, addressDataSection);
        copyWarrantyDataSection(accountId, opportunityId, warrantyDataSection);
        copyIncomeDataSection(accountId, opportunityId, incomeDataSection);
        copyOperationDataSection(accountId, opportunityId, operationDataSection);
        
        sectionRecords.add(personalDataSection);
        sectionRecords.add(contactDataSection);
        sectionRecords.add(addressDataSection);
        sectionRecords.add(warrantyDataSection);
        sectionRecords.add(incomeDataSection);
        sectionRecords.add(operationDataSection);

        System.debug(JSON.serializePretty(sectionRecords));
    }
    
    public static void syncObjectFields(SObject sourceObject, SObject sectionObject, String type)
    {
        String sObjectSourceApiName  = sourceObject.getSObjectType().getDescribe().Name;
        String sObjectSectionApiName = sectionObject.getSObjectType().getDescribe().Name;

        for(Proposal_Copy_Sections__mdt record : [SELECT Source_Field__r.QualifiedApiName, Section_Field__r.QualifiedApiName FROM Proposal_Copy_Sections__mdt
                                                  WHERE Source_Object__r.QualifiedApiName = :sObjectSourceApiName
                                                  AND Section_Object__r.QualifiedApiName = :sObjectSectionApiName
                                                  AND Type__c = :type
                                                  WITH SECURITY_ENFORCED])
        {   
            sectionObject.put(record.Section_Field__r.QualifiedApiName, sourceObject.get(record.Source_Field__r.QualifiedApiName));
        }
    }

    public static void copyPersonalDataSection(Id accountId, Id opportunityId, PersonalDataSection__c personalDataSection)
    {
        Account acc      = (Account) mountObjectStringQuery('Account', accountId);
        Documents__c rg  = (Documents__c) mountDocumentsStringQuery('Documents__c', accountId, 'RG');
        Documents__c cnh = (Documents__c) mountDocumentsStringQuery('Documents__c', accountId, 'CNH');
        
        syncObjectFields(acc, personalDataSection, '');
        syncObjectFields(rg, personalDataSection, 'RG');
        syncObjectFields(cnh, personalDataSection, 'CNH');
    }

    public static void copyContactDataSection(Id accountId, Id opportunityId, ContactDetailsSection__c contactDataSection)
    {
        CommunicationContacts__c email = (CommunicationContacts__c) mountContactStringQuery('CommunicationContacts__c', accountId, 'EMAIL');
        CommunicationContacts__c sms   = (CommunicationContacts__c) mountContactStringQuery('CommunicationContacts__c', accountId, 'SMS');
        
        syncObjectFields(email, contactDataSection, 'EMAIL');
        syncObjectFields(sms, contactDataSection, 'SMS');
    }

    public static void copyAddressDataSection(Id accountId, Id opportunityId, AddressDataSection__c addressDataSection)
    {
        Addresses__c address = (Addresses__c) mountAccountRelatedObjectStringQuery('Addresses__c', accountId);
        
        syncObjectFields(address, addressDataSection, '');
    }

    public static void copyWarrantyDataSection(Id accountId, Id opportunityId, WarrantyDataSection__c warrantyDataSection)
    {
        FinancialResources__c warranty = (FinancialResources__c) mountWarrantyStringQuery(opportunityId, accountId);
        
        syncObjectFields(warranty, warrantyDataSection, 'AUTO');
    }

    public static void copyIncomeDataSection(Id accountId, Id opportunityId, IncomeDataSection__c incomeDataSection)
    {
        Map<String, FinancialResources__c> financialResourcesById =  mountIncomeStringQuery(opportunityId, accountId);
        
        ProfessionalInfo__c professionalInfo  = (ProfessionalInfo__c) mountAccountRelatedObjectStringQuery('ProfessionalInfo__c', accountId);
        Opportunity opp                       = (Opportunity) mountObjectStringQuery('Opportunity', opportunityId);
        Account acc                           = (Account) mountObjectStringQuery('Account', accountId);
        FinancialResources__c presumedIncome  = financialResourcesById.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c monthlyIncome   = financialResourcesById.get('MONTHLY_INCOME');
        FinancialResources__c confirmedIncome = financialResourcesById.get('CONFIRMED_MONTHLY_INCOME');
    
        syncObjectFields(professionalInfo, incomeDataSection, '');
        syncObjectFields(opp, incomeDataSection, '');
        syncObjectFields(monthlyIncome, incomeDataSection, 'MONTHLY_INCOME');
        syncObjectFields(presumedIncome, incomeDataSection, 'PRESUMED_MONTHLY_INCOME');
        syncObjectFields(confirmedIncome, incomeDataSection, 'CONFIRMED_MONTHLY_INCOME');

        setNetworthValue(acc, incomeDataSection);
    }

    public static void copyOperationDataSection(Id accountId, Id opportunityId, OperationSection__c operationDataSection)
    {
        Quote quote = (Quote) mountOpportunityRelatedObjectStringQuery('Quote', opportunityId);
        Opportunity opp = (Opportunity) mountObjectStringQuery('Opportunity', opportunityId);
        FinancialResources__c financialResource = (FinancialResources__c) mountOperationStringQuery(opportunityId, accountId);
        Account proponent = getProponentFromOpp(opportunityId);

        syncObjectFields(quote, operationDataSection, '');
        syncObjectFields(opp, operationDataSection, '');
        syncObjectFields(financialResource, operationDataSection, 'CAR');
        syncObjectFields(proponent, operationDataSection, 'PROPONENT');
    }

    private static void setNetworthValue(Account acc, IncomeDataSection__c incomeSection)
    {
        System.debug('todo');
    }

    public static SObject mountAccountRelatedObjectStringQuery(String objectName, Id accountId)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountObjectStringQuery(String objectName, Id identifier)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Id = :identifier';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountOpportunityRelatedObjectStringQuery(String objectName, Id opportunityId)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE OpportunityId = :opportunityId ORDER BY CreatedDate DESC LIMIT 1';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountDocumentsStringQuery(String objectName, Id accountId, String type)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId ' +
                       ' AND DocumentType__c = :type WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountContactStringQuery(String objectName, Id accountId, String type)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId ' +
                       ' AND Channel__c = :type WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountWarrantyStringQuery(Id opportunityId, Id accountId) 
    {
        Set<Id> financialResourceIdSet = getAutoFinancialResourcesId(opportunityId);

        if(financialResourceIdSet.isEmpty()) {
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> resourceList = [SELECT ResourceKey__c,Plate__c,ModelYear__c,ManufacturingYear__c,Brand__c,Model__c,Color__c,LicensingState__c,State__c,ExternalCodeOrigin__c, Chassis__c, RecordTypeId FROM FinancialResources__c WHERE Id IN :financialResourceIdSet WITH SECURITY_ENFORCED ORDER BY ExternalUpdatedDate__c DESC];
            return resourceList[0];
        }
    }

    public static Map<String, FinancialResources__c> mountIncomeStringQuery(Id opportunityId, Id accountId)
    {
        Set<Id> financialResourceIdSet = getIncomeFinancialResourcesId(accountId);

        if(financialResourceIdSet.isEmpty()) {
            return new Map<String, FinancialResources__c>();
        } else {
            List<FinancialResources__c> resourceList = [SELECT Id, Type__c, Amount__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet WITH SECURITY_ENFORCED ORDER BY ExternalUpdatedDate__c DESC];
            Map<String, FinancialResources__c> financialResourcesByType = new Map<String, FinancialResources__c>();

            for(FinancialResources__c financialResource : resourceList)
            {   
                if(String.isNotBlank(financialResource?.Type__c))
                {
                    if(financialResource.Type__c.equals('MONTHLY_INCOME')) {
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } else if(financialResource.Type__c.equals('PRESUMED_MONTHLY_INCOME')) { 
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } else if(financialResource.Type__c.equals('CONFIRMED_MONTHLY_INCOME')) { 
                        financialResourcesByType.put(financialResource.Type__c, financialResource);
                    } 
                }
            }

            return financialResourcesByType;
        }
    }

    public static SObject mountOperationStringQuery(Id opportunityId, Id accountId)
    {
        Set<Id> financialResourceIdSet = getAutoFinancialResourcesId(opportunityId);

        if(financialResourceIdSet.isEmpty()) {
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> finResources = [SELECT Id, ManufacturingYear__c, Amount__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet ORDER BY ExternalUpdatedDate__c DESC];
            return finResources[0];
        }
    }

    private static Set<Id> getIncomeFinancialResourcesId(String accountId) 
    {    
        String financialResourceOthersId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Outros');
        Set<Id> financialResourceIdSet = new Set<Id>();
        
        for(AccountFinancialRelationship__c accFinancialRel : [SELECT Recurso_Financeiro__c, Recurso_Financeiro__r.RecordTypeId, Recurso_Financeiro__r.Type__c FROM AccountFinancialRelationship__c WHERE Account__c = :accountId WITH SECURITY_ENFORCED])
        {
            if(financialResourceOthersId == accFinancialRel.Recurso_Financeiro__r.RecordTypeId)
            {
                financialResourceIdSet.add(accFinancialRel.Recurso_Financeiro__c);
            }
        }

        return financialResourceIdSet;
    }

    private static Set<Id> getAutoFinancialResourcesId(Id opportunityId)
    {
        String financialResourceAutoId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Auto');
        Set<Id> financialResourceIdSet = new Set<Id>();
        
        for(Garantias__c garantia : [SELECT Recurso_Financeiro__c, Recurso_Financeiro__r.RecordTypeId, Recurso_Financeiro__r.Type__c 
                                     FROM Garantias__c 
                                     WHERE Opportunity__c = :opportunityId])
        {
            if(financialResourceAutoId == garantia.Recurso_Financeiro__r.RecordTypeId && garantia.Recurso_Financeiro__r.Type__c == 'CAR')
            {
                financialResourceIdSet.add(garantia.Recurso_Financeiro__c);
            }

            else if(financialResourceAutoId == garantia.Recurso_Financeiro__r.RecordTypeId)
            {
                financialResourceIdSet.add(garantia.Recurso_Financeiro__c);
            }
        }

        return financialResourceIdSet;
    }

    public static Account getProponentFromOpp(Id opportunityId)
    {
        Set<Id> proponentIdSet = getProponentsId(opportunityId);
        if(proponentIdSet.isEmpty()) {
            return new Account();
        } else {
            List<Account> accounts = [  SELECT Id, BankName__c, Agency__c, BankAccountNumber__c
                                        FROM Account 
                                        WHERE Id IN :proponentIdSet 
                                        ORDER BY ExternalUpdatedDate__c DESC];
            return accounts[0];
        }
    }

    private static Set<Id> getProponentsId(Id opportunityId)
    {
        Set<Id> proponentIdSet = new Set<Id>();
        for(OpportunityRole__c proponents : [ SELECT Id, ExternalPersonId__c 
                                              FROM OpportunityRole__c 
                                              WHERE Opportunity__c = :opportunityId AND Role__c = 'PRINCIPAL'])
        {
            proponentIdSet.add(proponents.ExternalPersonId__c);
        }

        return proponentIdSet;
    }
}