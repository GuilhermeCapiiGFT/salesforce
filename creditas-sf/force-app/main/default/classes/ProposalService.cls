public with sharing class ProposalService 
{
    private static final Integer CURRENT_RECORD = 1;
    private static Integer historyLimit;
    private static final String STAGE_WAITING_UE = 'Aguardando Análise de Formalização';
    private static final String STAGE_IN_ANALYSIS_UE = 'Em Análise de Formalização';
    private static final String PENDENCY_STAGE = 'Pending';
    private static final String PENDENCY_RETURN_STAGE = 'RETURNED_PENDING';
    
    private static Id opportunityId;
    private static Id accountId;
    private static OpportunityRepository opportunityRepository = new OpportunityRepository();
    private static AccountRepository accountRepository = new AccountRepository();

    private static String stageName;
    //globals
    private static Opportunity globalOpp;
    private static Account globalAcc;
    private static Map<String,Documents__c> mapDocuments = new Map<String,Documents__c>();
    private static Map<String,CommunicationContacts__c> mapContacts = new Map<String,CommunicationContacts__c>();
    private static Map<String,Addresses__c> mapAddress = new Map<String,Addresses__c>();
    private static Map<String,ProfessionalInfo__c> mapProfessionalInfo = new Map<String,ProfessionalInfo__c>();
    private static List<OpportunityRole__c> oppRoleList = new List<OpportunityRole__c>();
    
    public static void start(Id accId, Id oppId) 
    {
        Opportunity opp = OpportunityRepository.getOpportunityWithChildren(oppId, new List<String>{'GeneralSection','PersonalDataSection','AddressDataSection','ContactDetailsSection','WarrantyDataSection','IncomeDataSection','OperationSection','OthersSection','OpportunityRole'}, null, 'ASC');
        stageName = opp.StageName;
        if(stageName.equals(STAGE_WAITING_UE))
        {
            historyLimit = (Integer) Object_Section_History_Limit__mdt.getInstance('History_Limit').Value__c;
            opportunityId = oppId;
            accountId = accId;
            globalOpp = opp;
            
            List<SObject> sectionRecords = new List<SObject>();
            Map<String, List<SObject>> mapString = getSectionRecords(opp);

            deleteOldestSections(mapString);
            
            GeneralSection__c oldGeneralSection            = mapString.get('GeneralSection') != null ? (GeneralSection__c) mapString.get('GeneralSection')[0] : null;
            PersonalDataSection__c oldPersonalDataSection  = mapString.get('PersonalDataSection') != null ? (PersonalDataSection__c) mapString.get('PersonalDataSection')[0] : null;
            ContactDetailsSection__c oldContactDataSection = mapString.get('ContactDetailsSection') != null ? (ContactDetailsSection__c) mapString.get('ContactDetailsSection')[0] : null; 
            AddressDataSection__c oldAddressDataSection    = mapString.get('AddressDataSection') != null ? (AddressDataSection__c) mapString.get('AddressDataSection')[0] : null;
            WarrantyDataSection__c oldWarrantyDataSection  = mapString.get('WarrantyDataSection') != null ? (WarrantyDataSection__c) mapString.get('WarrantyDataSection')[0] : null;
            IncomeDataSection__c oldIncomeDataSection      = mapString.get('IncomeDataSection') != null ? (IncomeDataSection__c) mapString.get('IncomeDataSection')[0] : null;
            OperationSection__c oldOperationDataSection    = mapString.get('OperationSection') != null ? (OperationSection__c) mapString.get('OperationSection')[0] : null;
            OthersSection__c oldOthersDataSection          = mapString.get('OthersSection') != null ? (OthersSection__c) mapString.get('OthersSection')[0] : null;

            GeneralSection__c newGeneralSection         = new GeneralSection__c(Opportunity__c = opportunityId);
            PersonalDataSection__c personalDataSection  = new PersonalDataSection__c(Opportunity__c = opportunityId);
            ContactDetailsSection__c contactDataSection = new ContactDetailsSection__c(Opportunity__c = opportunityId);
            AddressDataSection__c addressDataSection    = new AddressDataSection__c(Opportunity__c = opportunityId);
            WarrantyDataSection__c warrantyDataSection  = new WarrantyDataSection__c(Opportunity__c = opportunityId);
            IncomeDataSection__c incomeDataSection      = new IncomeDataSection__c(Opportunity__c = opportunityId);
            OperationSection__c operationDataSection    = new OperationSection__c(Opportunity__c = opportunityId);
            OthersSection__c newOthersSection           = new OthersSection__c(Opportunity__c = opportunityId);
            
            getAccountAndChildren(accountId);

            syncSection(newGeneralSection, oldGeneralSection, opp);
            copyPersonalDataSection(personalDataSection, oldPersonalDataSection);
            copyContactDataSection(contactDataSection, oldContactDataSection);
            copyAddressDataSection(addressDataSection, oldAddressDataSection);
            copyWarrantyDataSection(warrantyDataSection, oldWarrantyDataSection);
            copyIncomeDataSection(incomeDataSection, oldIncomeDataSection);
            copyOperationDataSection(operationDataSection, oldOperationDataSection);
            syncSection(newOthersSection, oldOthersDataSection, opp);
            
            sectionRecords.add(newGeneralSection);
            sectionRecords.add(personalDataSection);
            sectionRecords.add(contactDataSection);
            sectionRecords.add(addressDataSection);
            sectionRecords.add(warrantyDataSection);
            sectionRecords.add(incomeDataSection);
            sectionRecords.add(operationDataSection);
            sectionRecords.add(newOthersSection);
    
            if(!sectionRecords.isEmpty())
            {
                Database.insert(sectionRecords);
            }
        }
    }

    public static void changeStageName(Id oppId)
    {
        if(stageName.equals(STAGE_WAITING_UE))
        {
            Opportunity opp = new Opportunity(Id = oppId);
            opp.StageName = STAGE_IN_ANALYSIS_UE;
    
            Database.update(opp);   
        }
    }

    public static void deleteOldestSections(Map<String, List<SObject>> mapString)
    {
        List<SObject> recordsToDelete = new List<SObject>();

        for(String currentSObject : mapString.keySet())
        {
            List<SObject> recordsSObject = mapString.get(currentSObject);

            if(recordsSObject != null && recordsSObject.size() == (historyLimit + CURRENT_RECORD))
            {
                recordsToDelete.add(recordsSObject.remove(0));
            }
        }

        if(!recordsToDelete.isEmpty())
        {
            Database.delete(recordsToDelete);
        }
    }

    private static List<SObject> createList(List<SObject> inputList){
        List<SObject> SObjectList = new List<SObject>();
        for(SObject obj : inputList){
            SObjectList.add(obj);
        }
        return SObjectList;
    }
    private static Map<String, List<SObject>> getSectionRecords(Opportunity opp)
    {
        Map<String, List<SObject>> records = new Map<String, List<SObject>>();
       
        List<GeneralSection__c> generalList = new List<GeneralSection__c>();
        for(GeneralSection__c obj : opp.GeneralSection__r){
            generalList.add(obj);
        }
        generalList = generalList.isEmpty() ? null : generalList;

        List<PersonalDataSection__c> perList = new List<PersonalDataSection__c>();
        for(PersonalDataSection__c obj : opp.PersonalDataSection__r){
            perList.add(obj);
        }
        perList = perList.isEmpty() ? null : perList;

        List<ContactDetailsSection__c> conList = new List<ContactDetailsSection__c>();
        for(ContactDetailsSection__c obj : opp.ContactDetailsSection__r){
            conList.add(obj);
        }
        conList = conList.isEmpty() ? null : conList;

        List<AddressDataSection__c> addressList = new List<AddressDataSection__c>();
        for(AddressDataSection__c obj : opp.AddressDataSection__r){
            addressList.add(obj);
        }
        addressList = addressList.isEmpty() ? null : addressList;

        List<WarrantyDataSection__c> warrList = new List<WarrantyDataSection__c>();
        for(WarrantyDataSection__c obj : opp.WarrantyDataSection__r){
            warrList.add(obj);
        }
        warrList = warrList.isEmpty() ? null : warrList;

        List<IncomeDataSection__c> incomeList = new List<IncomeDataSection__c>();
        for(IncomeDataSection__c obj : opp.IncomeDataSection__r){
            incomeList.add(obj);
        }
        incomeList = incomeList.isEmpty() ? null : incomeList;

        List<OperationSection__c> operationList = new List<OperationSection__c>();
        for(OperationSection__c obj : opp.OperationSection__r){
            operationList.add(obj);
        }
        operationList = operationList.isEmpty() ? null : operationList;

        List<OthersSection__c> otherList = new List<OthersSection__c>();
        for(OthersSection__c obj : opp.OthersSection__r){
            otherList.add(obj);
        }
        otherList = otherList.isEmpty() ? null : otherList;
        
        for(OpportunityRole__c role : opp.OpportunityRole__r){
            oppRoleList.add(role);
        }

        records.put('GeneralSection'        , generalList);
        records.put('PersonalDataSection'   , perList);
        records.put('AddressDataSection'    , addressList);
        records.put('ContactDetailsSection' , conList);
        records.put('WarrantyDataSection'   , warrList);
        records.put('IncomeDataSection'     , incomeList);
        records.put('OperationSection'      , operationList);
        records.put('OthersSection'         , otherList);
        return records;
    }
    
    public static void syncObjectFields(SObject sourceObject, SObject sectionObject, SObject oldSectionObject, String type)
    {
        if(sourceObject != null)
        {
            String sObjectSourceApiName  = sourceObject.getSObjectType().getDescribe().Name;
            String sObjectSectionApiName = sectionObject.getSObjectType().getDescribe().Name;
    
            for(Proposal_Copy_Sections__mdt record : [SELECT Source_Field__r.QualifiedApiName, Section_Field__r.QualifiedApiName, Status__r.QualifiedApiName 
                                                      FROM Proposal_Copy_Sections__mdt
                                                      WHERE Source_Object__r.QualifiedApiName = :sObjectSourceApiName
                                                      AND Section_Object__r.QualifiedApiName = :sObjectSectionApiName
                                                      AND Type__c = :type
                                                      WITH SECURITY_ENFORCED])
            {   
                sectionObject.put(record.Section_Field__r.QualifiedApiName, sourceObject.get(record.Source_Field__r.QualifiedApiName));

                if(oldSectionObject != null && record.Status__r.QualifiedApiName != null) 
                {
                    sectionObject.put(record.Status__r.QualifiedApiName, oldSectionObject.get(record.Status__r.QualifiedApiName) == PENDENCY_STAGE ? PENDENCY_RETURN_STAGE : null);
                }
            }
        }
    }
    
    public static void syncSection(Sobject newSection, Sobject oldSection, Opportunity opp){
        if(oldSection != null){
            List<ProposalAnalysisFields__mdt> sectionFieldsMeta = getSectionFields(oldSection, opp.RecordType.DeveloperName);
            Map<String, Map<String, String>> fieldsStatusByController = getFieldsStatusByController(sectionFieldsMeta);
            Map<String, Object> oldSectionFields = oldSection.getPopulatedFieldsAsMap();
            for(String field : fieldsStatusByController.keySet()){
                String oldValue = oldSectionFields.get(field) != null ?
                                String.valueOf(oldSectionFields.get(field)):
                                '';
                if(String.isNotBlank(oldValue) && oldValue == PENDENCY_STAGE){
                    newSection.put(field, PENDENCY_RETURN_STAGE);
                }
            }
        }
        syncObjectFields(opp, newSection, oldSection, '');
    }

    private static Map<String, Map<String, String>> getFieldsStatusByController(List<ProposalAnalysisFields__mdt> sectionFieldsMeta){
        Map<String, Map<String, String>> sectionFieldsMap = new Map<String, Map<String, String>>();
        for(ProposalAnalysisFields__mdt sectionField : sectionFieldsMeta){
            Map<String, String> relatedFields = new Map<String, String>();
            relatedFields.put('Value', String.valueOf(sectionField.Value__r.DeveloperName));
            relatedFields.put('PendingReason',String.valueOf(sectionField.Pending_Reason__r.QualifiedApiName));
            relatedFields.put('RejectReason', String.valueOf(sectionField.Reject_Reason__r.QualifiedApiName));
            sectionFieldsMap.put(String.valueOf(sectionField.Status__r.QualifiedApiName), relatedFields);
        }
        return sectionFieldsMap;
    }
    public static List<ProposalAnalysisFields__mdt> getSectionFields(Sobject newSection, String recordType){
        String sobjectName = String.valueOf(newSection.getSObjectType());
        return [   
                SELECT Id, Item_Type__c, Value__r.DeveloperName, Value__r.QualifiedApiName, 
                Object_Section__r.DeveloperName, Observation__r.QualifiedApiName, 
                Pending_Reason__r.QualifiedApiName, Reject_Reason__r.QualifiedApiName, 
                Status__r.QualifiedApiName 
                    FROM ProposalAnalysisFields__mdt
                    WHERE Product_Type__c = :recordType AND Object_Section__r.QualifiedApiName = :sobjectName
        ];
    }

    private static void getAccountAndChildren(String accId){
        globalAcc = AccountRepository.getAccountWithChildren(accId, new List<String>{'Documents','CommunicationContacts','Addresses','ProfessionalInfo'});
        createDocumentsMap(globalAcc.Documents__r);
        createCommunicationContactMap(globalAcc.CommunicationContacts__r);
        createAddressMap(globalAcc.Addresses__r);
        createProfessionalInfoMap(globalAcc.ProfessionalInfo__r);
    }

    private static void createDocumentsMap(List<Documents__c> docList){
        for(Documents__c doc : docList){
            if(String.isNotBlank(doc.DocumentKey__c) && !mapDocuments.containsKey(doc.DocumentKey__c)){
                mapDocuments.put(doc.DocumentKey__c, doc);
            } else if(mapDocuments.size() == 2){
                break;
            }
        }
    }

    private static void createCommunicationContactMap(List<CommunicationContacts__c> commList){
        for(CommunicationContacts__c comm : commList){
            if(String.isNotBlank(comm.Channel__c) && !mapContacts.containsKey(comm.Channel__c)){
                mapContacts.put(comm.Channel__c, comm);
            } else if(mapDocuments.size() == 2){
                break;
            }
        }
    }

    private static void createAddressMap(List<Addresses__c> addressList){
        for(Addresses__c address :addressList){
            if(!mapAddress.containsKey('Address')){
                mapAddress.put('Address',address);
            } else if (mapAddress.size() == 1){
                break;
            }
        }
    }

    private static void createProfessionalInfoMap(List<ProfessionalInfo__c> profInfoList){
        for(ProfessionalInfo__c profInfo :profInfoList){
            if(!mapProfessionalInfo.containsKey('profInfo')){
                mapProfessionalInfo.put('profInfo',profInfo);
            } else if (mapProfessionalInfo.size() == 1){
                break;
            }
        }
    }


    public static void copyPersonalDataSection(PersonalDataSection__c personalDataSection, PersonalDataSection__c oldPersonalDataSection)
    {
        Account acc      = globalAcc;
        Documents__c rg  = mapDocuments.get('RG');
        Documents__c cnh = mapDocuments.get('CNH');
        
        syncObjectFields(acc, personalDataSection, oldPersonalDataSection, '');
        syncObjectFields(rg, personalDataSection, oldPersonalDataSection, 'RG');
        syncObjectFields(cnh, personalDataSection, oldPersonalDataSection, 'CNH');
    }

    public static void copyContactDataSection(ContactDetailsSection__c contactDataSection, ContactDetailsSection__c oldContactDataSection)
    {
        CommunicationContacts__c email = mapContacts.get('EMAIL');
        CommunicationContacts__c sms   = mapContacts.get('SMS');
        
        syncObjectFields(email, contactDataSection, oldContactDataSection, 'EMAIL');
        syncObjectFields(sms, contactDataSection, oldContactDataSection, 'SMS');
    }

    public static void copyAddressDataSection(AddressDataSection__c addressDataSection, AddressDataSection__c oldAddressDataSection)
    {
        Addresses__c address = mapAddress.get('Address');
        
        syncObjectFields(address, addressDataSection, oldAddressDataSection, '');
    }

    public static void copyWarrantyDataSection(WarrantyDataSection__c warrantyDataSection, WarrantyDataSection__c oldWarrantyDataSection)
    {
        FinancialResources__c warranty = (FinancialResources__c) mountWarrantyStringQuery();
        
        syncObjectFields(warranty, warrantyDataSection, oldWarrantyDataSection, 'AUTO');
    }

    public static void copyIncomeDataSection(IncomeDataSection__c incomeDataSection, IncomeDataSection__c oldIncomeDataSection)
    {
        Map<String, FinancialResources__c> financialResourcesById =  mountIncomeStringQuery();
        
        ProfessionalInfo__c professionalInfo  = mapProfessionalInfo.get('profInfo');
        FinancialResources__c presumedIncome  = financialResourcesById.get('PRESUMED_MONTHLY_INCOME');
        FinancialResources__c monthlyIncome   = financialResourcesById.get('MONTHLY_INCOME');
        FinancialResources__c confirmedIncome = financialResourcesById.get('CONFIRMED_MONTHLY_INCOME');
    
        setNetworthValue(globalAcc, incomeDataSection);
        syncObjectFields(globalOpp, incomeDataSection, oldIncomeDataSection, '');
        syncObjectFields(professionalInfo, incomeDataSection, oldIncomeDataSection, '');
        syncObjectFields(monthlyIncome, incomeDataSection, oldIncomeDataSection, 'MONTHLY_INCOME');
        syncObjectFields(presumedIncome, incomeDataSection, oldIncomeDataSection, 'PRESUMED_MONTHLY_INCOME');
        syncObjectFields(confirmedIncome, incomeDataSection, oldIncomeDataSection, 'CONFIRMED_MONTHLY_INCOME');
    }

    public static void copyOperationDataSection(OperationSection__c operationDataSection, OperationSection__c oldOperationDataSection)
    {
        Quote quote                             = (Quote) mountOpportunityRelatedObjectStringQuery('Quote');
        FinancialResources__c financialResource = (FinancialResources__c) mountOperationStringQuery();
        Account proponent                       = getProponentFromOpp();
        Account partner                         = (Account) mountObjectStringQuery('Account', globalOpp.PartnerAccount__c);

        syncObjectFields(quote, operationDataSection, oldOperationDataSection, '');
        syncObjectFields(globalOpp, operationDataSection, oldOperationDataSection, '');
        syncObjectFields(financialResource, operationDataSection, oldOperationDataSection, 'CAR');
        syncObjectFields(proponent, operationDataSection, oldOperationDataSection, 'PROPONENT');
        syncObjectFields(partner, operationDataSection, oldOperationDataSection, 'PARTNER');
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

    public static SObject mountObjectStringQuery(String objectName, Id identifier)
    {
        List<String> sObjectFields = Util.selectAllFields(objectName);

        String query = 'SELECT ' + String.join(sObjectFields, ', ') + 
                       ' FROM ' + objectName  + 
                       ' WHERE Id = :identifier';
        
        List<SObject> objects = Database.query(query.escapeUnicode());

        return !objects.isEmpty() ? objects[0] : null;
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
        if(oppRoleList.isEmpty()){
            for(OpportunityRole__c proponents : [ SELECT Id, ExternalPersonId__c FROM OpportunityRole__c WHERE Opportunity__c = :opportunityId AND Role__c = 'PRINCIPAL']){
                proponentIdSet.add(proponents.ExternalPersonId__c);
            }

        } else {
            for(OpportunityRole__c proponents : oppRoleList){
                proponentIdSet.add(proponents.ExternalPersonId__c);
            }
        }
        return proponentIdSet;
    }
}