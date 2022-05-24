public with sharing class ProposalIntegrationService {
    static final String NAMED_CREDENTIAL = 'callout:proposalIntegration';
    private static Id opportunityId;
    private static String recordTypeName;
    private static Map<String,String> productTypes = new Map<String,String>
    {
        'AutoFin' => 'AUTO_FIN',
        'AtWork'  => 'PAYROLL'
    };

    public static ProposalIntegrationVO getRequest(Id oppId, String status){
        opportunityId = oppId;
        Opportunity opportunity = getRecordTypeOpp();
        recordTypeName = opportunity.RecordType.DeveloperName;
        
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        List<ProposalIntegrationVO.Section> sections = getSections();

        payload.loanApplicationId = opportunity.ExternalId__c;
        payload.context           = opportunity.StageName;
        payload.contextResult     = status;
        payload.productType       = productTypes.containsKey(recordTypeName) ? productTypes.get(recordTypeName) : '';
        payload.sections          = sections;

        System.debug(JSON.serializePretty(payload));
        return payload;
    }

    private static List<ProposalIntegrationVO.Section> getSections(){
        List<ProposalIntegrationVO.Section> sections = new List<ProposalIntegrationVO.Section>();
        Map<String, List<ProposalAnalysisFields__mdt>> sectionFields = getMapFields(recordTypeName);
        Map<String, SObject> sectionRecords = getSectionRecords();

        for(String currentSection : sectionFields.KeySet()){
            ProposalIntegrationVO.Section section = new ProposalIntegrationVO.Section();
            section.sectionId           = sectionRecords.get(currentSection)?.Id;
            section.sectionName         = currentSection;
            section.sectionResult       = null;
            section.sectionReasons      = null;
            section.sectionObservations = null;
            section.analyzedItems       = getItems(sectionFields.get(currentSection), sectionRecords.get(currentSection));
            sections.add(section);
        }
        return sections;
    }

    private static List<ProposalIntegrationVO.AnalyzedItem> getItems(List<ProposalAnalysisFields__mdt> sectionFields, SObject record){
        List<ProposalIntegrationVO.AnalyzedItem> itens = new List<ProposalIntegrationVO.AnalyzedItem>();
        for(ProposalAnalysisFields__mdt currentField : sectionFields){
            ProposalIntegrationVO.AnalyzedItem item = new ProposalIntegrationVO.AnalyzedItem();
            String result           = currentField.Status__r.QualifiedApiName;
            String reason           = getReasons(currentField, record);
            String observation      = currentField.Observation__r.QualifiedApiName;
            String value            = currentField.Value__r.QualifiedApiName;
            
            item.type               = currentField.Item_Type__c;
            item.fieldName          = currentField.Value__r.DeveloperName;
            item.itemId             = null;
            item.result             = String.isBlank(result)      ? null  : (String) record.get(result);
            item.value              = String.isBlank(value)       ? null  : (String) String.valueOf(record.get(value));
            item.reasons            = String.isBlank(reason)      ? null  : reason;
            item.fieldObservations  = String.isBlank(observation) ? null  : (String) record.get(observation);

            itens.add(item);
        }
        return itens;
    }

    private static String getReasons(ProposalAnalysisFields__mdt reason, SObject record){
        String rejectField  = reason.Reject_Reason__r.QualifiedApiName;
        String pendingField = reason.Pending_Reason__r.QualifiedApiName;

        if(!String.isBlank(rejectField) && !String.isBlank((String)record.get(rejectField))){
            return (String) record.get(rejectField);
        }else if(!String.isBlank(pendingField) && !String.isBlank((String)record.get(pendingField))){
            return (String) record.get(pendingField);
        }
        return null;
    }

    private static Map<String, SObject> getSectionRecords(){
        Map<String,Sobject> records = new Map<String,SObject>();
        records.put('PersonalDataSection'   ,getRecordBySObject('PersonalDataSection__c'));
        records.put('AddressDataSection'    ,getRecordBySObject('AddressDataSection__c'));
        records.put('ContactDetailsSection' ,getRecordBySObject('ContactDetailsSection__c'));
        records.put('WarrantyDataSection'   ,getRecordBySObject('WarrantyDataSection__c'));
        records.put('IncomeDataSection'     ,getRecordBySObject('IncomeDataSection__c'));
        records.put('OperationSection'      ,getRecordBySObject('OperationSection__c'));

        return records;
    }

    private static SObject getRecordBySObject(String objectName){
        List<String> sObjectFields = Util.selectAllFields(objectName);
        String query = 'SELECT ' + String.join(sObjectFields, ', ') +
                       ' FROM ' + objectName  +
                       ' WHERE Opportunity__c = :opportunityId ' +
                       ' ORDER BY CreatedDate DESC LIMIT 1';

        return Database.query(query.escapeUnicode());
    }

    private static Opportunity getRecordTypeOpp(){
        return [SELECT Id, RecordType.DeveloperName, ExternalId__c, StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
    }

    private static Map<String, List<ProposalAnalysisFields__mdt>> getMapFields(String recordType){
        Map<String, List<ProposalAnalysisFields__mdt>> mapSectionFields = new Map<String, List<ProposalAnalysisFields__mdt>>();
        for(ProposalAnalysisFields__mdt currentSectionField : [SELECT Id, Item_Type__c, Value__r.DeveloperName, Value__r.QualifiedApiName, Object_Section__r.DeveloperName, 
                                                                Observation__r.QualifiedApiName, Pending_Reason__r.QualifiedApiName, Reject_Reason__r.QualifiedApiName, Status__r.QualifiedApiName 
                                                                FROM ProposalAnalysisFields__mdt
                                                                WHERE Product_Type__c = :recordType]){
            if(mapSectionFields.containsKey(currentSectionField.Object_Section__r.DeveloperName)){
                List<ProposalAnalysisFields__mdt> fields = mapSectionFields.get(currentSectionField.Object_Section__r.DeveloperName);
                fields.add(currentSectionField);
                mapSectionFields.put(currentSectionField.Object_Section__r.DeveloperName, fields);
            }else{
                mapSectionFields.put(currentSectionField.Object_Section__r.DeveloperName, new List<ProposalAnalysisFields__mdt>{currentSectionField});
            }
        }
        return mapSectionFields;
    }

    public static String sendAnalysis(String payload){
        HttpRequest request = new HttpRequest();

        request.setEndpoint(NAMED_CREDENTIAL);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody(payload);
        
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        return (response.getStatusCode() == 200) ? 'Success' : 'Error';
    }
}