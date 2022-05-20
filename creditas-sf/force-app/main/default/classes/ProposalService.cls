public with sharing class ProposalService 
{
    private static final Integer CURRENT_RECORD = 1;
    private static Integer historyLimit;
    
    private static Id opportunityId;
    private static Id accountId;

    private static String stageName;
    
    public static void start(Id accId, Id oppId) 
    {
        stageName = getStageName(oppId);

        if(stageName.equals('Aguardando Análise de Formalização'))
        {
            historyLimit = (Integer) Object_Section_History_Limit__mdt.getInstance('History_Limit').Value__c;
            List<SObject> sectionRecords = new List<SObject>();
    
            opportunityId = oppId;
            accountId = accId;
    
            deleteOldestSections();
    
            PersonalDataSection__c personalDataSection = new PersonalDataSection__c(Opportunity__c = opportunityId);
            ContactDetailsSection__c contactDataSection = new ContactDetailsSection__c(Opportunity__c = opportunityId);
            AddressDataSection__c addressDataSection = new AddressDataSection__c(Opportunity__c = opportunityId);
            WarrantyDataSection__c warrantyDataSection = new WarrantyDataSection__c(Opportunity__c = opportunityId);
            IncomeDataSection__c incomeDataSection = new IncomeDataSection__c(Opportunity__c = opportunityId);
            OperationSection__c operationDataSection = new OperationSection__c(Opportunity__c = opportunityId);
    
            copyPersonalDataSection(personalDataSection);
            copyContactDataSection(contactDataSection);
            copyAddressDataSection(addressDataSection);
            copyWarrantyDataSection(warrantyDataSection);
            copyIncomeDataSection(incomeDataSection);
            copyOperationDataSection(operationDataSection);
            
            sectionRecords.add(personalDataSection);
            sectionRecords.add(contactDataSection);
            sectionRecords.add(addressDataSection);
            sectionRecords.add(warrantyDataSection);
            sectionRecords.add(incomeDataSection);
            sectionRecords.add(operationDataSection);
    
            if(!sectionRecords.isEmpty())
            {
                Database.insert(sectionRecords);
            }
        }
    }

    public static void changeStageName(Id oppId)
    {
        if(stageName.equals('Aguardando Análise de Formalização'))
        {
            Opportunity opp = new Opportunity(Id = oppId);
            opp.StageName = 'Em Análise de Formalização';
    
            Database.update(opp);   
        }
    }

    public static String getStageName(Id oppId)
    {
        return [SELECT Id, StageName FROM Opportunity where Id =:oppId LIMIT 1].StageName;
    }

    public static void deleteOldestSections()
    {
        Map<String, List<SObject>> mapString = getSectionRecords();
        List<SObject> recordsToDelete = new List<SObject>();

        for(String currentSObject : mapString.keySet())
        {
            List<SObject> recordsSObject = mapString.get(currentSObject);

            if(recordsSObject != null && recordsSObject.size() == (historyLimit + CURRENT_RECORD))
            {
                recordsToDelete.add(recordsSObject[0]);
            }
        }

        if(!recordsToDelete.isEmpty())
        {
            Database.delete(recordsToDelete);
        }
    }

    private static Map<String, List<SObject>> getSectionRecords()
    {
        Map<String, List<SObject>> records = new Map<String, List<SObject>>();
        records.put('PersonalDataSection'   , mountSectionStringQuery('PersonalDataSection__c'));
        records.put('AddressDataSection'    , mountSectionStringQuery('AddressDataSection__c'));
        records.put('ContactDetailsSection' , mountSectionStringQuery('ContactDetailsSection__c'));
        records.put('WarrantyDataSection'   , mountSectionStringQuery('WarrantyDataSection__c'));
        records.put('IncomeDataSection'     , mountSectionStringQuery('IncomeDataSection__c'));
        records.put('OperationSection'      , mountSectionStringQuery('OperationSection__c'));

        return records;
    }
    
    public static void syncObjectFields(SObject sourceObject, SObject sectionObject, String type)
    {
        if(sourceObject != null)
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
    }

    public static void copyPersonalDataSection(PersonalDataSection__c personalDataSection)
    {
        Account acc      = (Account) mountObjectStringQuery('Account', accountId);
        Documents__c rg  = (Documents__c) mountDocumentsStringQuery('Documents__c', 'RG');
        Documents__c cnh = (Documents__c) mountDocumentsStringQuery('Documents__c', 'CNH');
        
        syncObjectFields(acc, personalDataSection, '');
        syncObjectFields(rg, personalDataSection, 'RG');
        syncObjectFields(cnh, personalDataSection, 'CNH');
    }

    public static void copyContactDataSection(ContactDetailsSection__c contactDataSection)
    {
        CommunicationContacts__c email = (CommunicationContacts__c) mountContactStringQuery('CommunicationContacts__c', 'EMAIL');
        CommunicationContacts__c sms   = (CommunicationContacts__c) mountContactStringQuery('CommunicationContacts__c', 'SMS');
        
        syncObjectFields(email, contactDataSection, 'EMAIL');
        syncObjectFields(sms, contactDataSection, 'SMS');
    }

    public static void copyAddressDataSection(AddressDataSection__c addressDataSection)
    {
        Addresses__c address = (Addresses__c) mountAccountRelatedObjectStringQuery('Addresses__c');
        
        syncObjectFields(address, addressDataSection, '');
    }

    public static void copyWarrantyDataSection(WarrantyDataSection__c warrantyDataSection)
    {
        FinancialResources__c warranty = (FinancialResources__c) mountWarrantyStringQuery();
        
        syncObjectFields(warranty, warrantyDataSection, 'AUTO');
    }

    public static void copyIncomeDataSection(IncomeDataSection__c incomeDataSection)
    {
        Map<String, FinancialResources__c> financialResourcesById =  mountIncomeStringQuery();
        
        ProfessionalInfo__c professionalInfo  = (ProfessionalInfo__c) mountAccountRelatedObjectStringQuery('ProfessionalInfo__c');
        Opportunity opp                       = (Opportunity) mountObjectStringQuery('Opportunity', opportunityId);
        Account acc                           = (Account) mountObjectStringQuery('Account', accountId);
        FinancialResources__c presumedIncome  = financialResourcesById.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c monthlyIncome   = financialResourcesById.get('MONTHLY_INCOME');
        FinancialResources__c confirmedIncome = financialResourcesById.get('CONFIRMED_MONTHLY_INCOME');
    
        setNetworthValue(acc, incomeDataSection);
        syncObjectFields(opp, incomeDataSection, '');
        syncObjectFields(professionalInfo, incomeDataSection, '');
        syncObjectFields(monthlyIncome, incomeDataSection, 'MONTHLY_INCOME');
        syncObjectFields(presumedIncome, incomeDataSection, 'PRESUMED_MONTHLY_INCOME');
         syncObjectFields(confirmedIncome, incomeDataSection, 'CONFIRMED_MONTHLY_INCOME');
    }

    public static void copyOperationDataSection(OperationSection__c operationDataSection)
    {
        Quote quote                             = (Quote) mountOpportunityRelatedObjectStringQuery('Quote');
        Opportunity opp                         = (Opportunity) mountObjectStringQuery('Opportunity', opportunityId);
        FinancialResources__c financialResource = (FinancialResources__c) mountOperationStringQuery();
        Account proponent                       = getProponentFromOpp();

        syncObjectFields(quote, operationDataSection, '');
        syncObjectFields(opp, operationDataSection, '');
        syncObjectFields(financialResource, operationDataSection, 'CAR');
        syncObjectFields(proponent, operationDataSection, 'PROPONENT');
    }

    private static void setNetworthValue(Account acc, IncomeDataSection__c incomeSection)
    { 
        List<Networth_Options__mdt> networthOptions = [SELECT QualifiedApiName, Text__c, Value__c, Position__c FROM Networth_Options__mdt WITH SECURITY_ENFORCED ORDER BY Position__c ASC];
        String picklistValue = '';
        
        for(Networth_Options__mdt option : networthOptions)
        {
            if(Decimal.valueOf(option.Value__c.split('-')[0].replaceAll(',','.')) < acc.NetWorthUpperLimit__c || 
              (option.Position__c == 0 && acc.NetWorthUpperLimit__c <= Decimal.valueOf(option.Value__c.split('-')[0].replaceAll(',','.') )))
            {
                picklistValue = option.QualifiedApiName;
            }
        }

        if(String.isBlank(picklistValue))
        {
            picklistValue = networthOptions[networthOptions.size() - 1].QualifiedApiName;
        }

        incomeSection.put('NetWorth__c', picklistValue);
    }

    public static SObject mountAccountRelatedObjectStringQuery(String objectName)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId';
        
        List<SObject> objects = Database.query(query.escapeUnicode());
        
        return !objects.isEmpty() ? objects[0] : null;
    }

    public static SObject mountObjectStringQuery(String objectName, Id identifier)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Id = :identifier';
        
        return Database.query(query.escapeUnicode());
    }

    public static SObject mountOpportunityRelatedObjectStringQuery(String objectName)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE OpportunityId = :opportunityId ORDER BY CreatedDate DESC LIMIT 1';
        
        List<SObject> objects = Database.query(query.escapeUnicode());

        return !objects.isEmpty() ? objects[0] : null;
    }

    public static List<SObject> mountSectionStringQuery(String objectName)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Opportunity__c = :opportunityId ORDER BY CreatedDate ASC';
        
        List<SObject> objects = Database.query(query.escapeUnicode());

        return !objects.isEmpty() ? objects : null;
    }

    public static SObject mountDocumentsStringQuery(String objectName, String type)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId ' +
                       ' AND DocumentType__c = :type WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';
        
        List<SObject> objects = Database.query(query.escapeUnicode());

        return !objects.isEmpty() ? objects[0] : null;
    }

    public static SObject mountContactStringQuery(String objectName, String type)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Account__c = :accountId ' +
                       ' AND Channel__c = :type WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';
        
        List<SObject> objects = Database.query(query.escapeUnicode());

        return !objects.isEmpty() ? objects[0] : null;
    }

    public static SObject mountWarrantyStringQuery() 
    {
        Set<Id> financialResourceIdSet = getAutoFinancialResourcesId();

        if(financialResourceIdSet.isEmpty()) {
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> resourceList = [SELECT ResourceKey__c,Plate__c,ModelYear__c,ManufacturingYear__c,Brand__c,Model__c,Color__c,LicensingState__c,State__c,ExternalCodeOrigin__c, Chassis__c, RecordTypeId FROM FinancialResources__c WHERE Id IN :financialResourceIdSet WITH SECURITY_ENFORCED ORDER BY ExternalUpdatedDate__c DESC];
            return resourceList[0];
        }
    }

    public static Map<String, FinancialResources__c> mountIncomeStringQuery()
    {
        Set<Id> financialResourceIdSet = getIncomeFinancialResourcesId();

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

    public static SObject mountOperationStringQuery()
    {
        Set<Id> financialResourceIdSet = getAutoFinancialResourcesId();

        if(financialResourceIdSet.isEmpty()) {
            return new FinancialResources__c();
        } else {
            List<FinancialResources__c> finResources = [SELECT Id, ManufacturingYear__c, Amount__c FROM FinancialResources__c WHERE Id IN :financialResourceIdSet WITH SECURITY_ENFORCED ORDER BY ExternalUpdatedDate__c DESC ];
            return finResources[0];
        }
    }

    private static Set<Id> getIncomeFinancialResourcesId() 
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

    private static Set<Id> getAutoFinancialResourcesId()
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

    public static Account getProponentFromOpp()
    {
        Set<Id> proponentIdSet = getProponentsId();
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

    private static Set<Id> getProponentsId()
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