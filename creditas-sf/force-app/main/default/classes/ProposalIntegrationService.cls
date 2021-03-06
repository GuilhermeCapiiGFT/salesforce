public with sharing class ProposalIntegrationService {
    
    static final String NAMED_CREDENTIAL = 'callout:mulesoftGateway';
    private static Id opportunityId;
    private static String recordTypeName;
    private static Map<String,String> productTypes;
    private static Map<String,String> resultBySection;
    private static Map<String, List<String>> reasonsBySection;
    private static final string PROPOSAL_APPROVED = 'APPROVED';
    private static final string PROPOSAL_PENDENCY = 'PENDING';
    private static final string PROPOSAL_REJECTED = 'REJECTED';
    private static OpportunityRepository opportunityRepository;
    private static String oppExternalId;

    static {

      productTypes  = new Map<String,String>{ 'AutoFin' => 'AUTO_FIN','AtWork'  => 'PAYROLL' };
      resultBySection = new Map<String,String>();
      reasonsBySection = new Map<String,List<String>>();
      opportunityRepository = new OpportunityRepository();

    }

    public static ProposalIntegrationVO getRequest(Id oppId, String status) {

        opportunityId = oppId;
        Opportunity opportunity = opportunityRepository.findById(oppId);
        recordTypeName = opportunity.RecordType.DeveloperName;
        oppExternalId = opportunity.ExternalId__c;

        Garantias__c asset = ( !opportunity.Garantia__r.isEmpty() ) ? opportunity.Garantia__r[0] : null;
        
        ProposalIntegrationVO payload = new ProposalIntegrationVO();
        List<ProposalIntegrationVO.Section> sections = getSections();

        payload.loanApplicationId = opportunity.ExternalId__c;
        payload.context           = opportunity.StageName;
        payload.contextResult     = status;
        payload.productType       = productTypes.containsKey(recordTypeName) ? productTypes.get(recordTypeName) : '';
        payload.assetId           = asset?.Recurso_Financeiro__r?.ExternalId__c;
        payload.personId          = opportunity.Account.ExternalId__c;
        payload.sections          = sections;

        return payload;
    }

    private static List<ProposalIntegrationVO.Section> getSections(){
        List<ProposalIntegrationVO.Section> sections = new List<ProposalIntegrationVO.Section>();
        Map<String, List<ProposalAnalysisFields__mdt>> sectionFields = getMapFields(recordTypeName);
        Map<String, SObject> sectionRecords = getSectionRecords();

        for(String currentSection : sectionFields.KeySet()){
    
            reasonsBySection.put( currentSection , new List<String>() );
            resultBySection.put( currentSection, PROPOSAL_APPROVED );

            ProposalIntegrationVO.Section section = new ProposalIntegrationVO.Section();
            section.sectionId           = sectionRecords.get(currentSection)?.Id;
            section.sectionName         = currentSection;
            section.analyzedItems       = getItems(sectionFields.get(currentSection), sectionRecords.get(currentSection));
            section.sectionResult       = resultBySection.get(currentSection);
            section.sectionReasons      = reasonsBySection.get(currentSection);
            section.sectionObservations = null;
            sections.add(section);
        }
        return sections;
    }

    private static List<ProposalIntegrationVO.AnalyzedItem> getItems(List<ProposalAnalysisFields__mdt> sectionFields, SObject record) {

        List<ProposalIntegrationVO.AnalyzedItem> itens = new List<ProposalIntegrationVO.AnalyzedItem>();

        for(ProposalAnalysisFields__mdt currentField : sectionFields) {

            ProposalIntegrationVO.AnalyzedItem item = new ProposalIntegrationVO.AnalyzedItem();
            String externalId       = currentField.ExternalId__r.QualifiedApiName;
            String observation      = currentField.Observation__r.QualifiedApiName;
            String result           = currentField.Status__r.QualifiedApiName;
            String reason           = getReasons(currentField, record);
            String value            = currentField.Value__r.QualifiedApiName;
            
            item.externalId         = String.isBlank(externalId)  ? null  : (String) record.get(externalId);
            item.fieldName          = currentField.Value__r.DeveloperName;
            item.fieldObservations  = String.isBlank(observation) ? null  : (String) record.get(observation);
            item.itemId             = null;
            item.reasons            = String.isBlank(reason)      ? null  : reason;
            item.result             = String.isBlank(result)      ? null  : (String) record.get(result);
            item.type               = currentField.Item_Type__c;
            item.value              = String.isBlank(value)       ? null  : (String) String.valueOf(record.get(value));
            
            if ( String.isNotBlank(reason) ) {

                item.reasons = reason;
                reasonsBySection.get(currentField.Object_Section__r.DeveloperName).add(reason);
            }

            if ( String.isNotBlank(result) ) {

                item.result = (String) record.get(result);
                updateResultSection(item.result, currentField.Object_Section__r.DeveloperName);
            }

            itens.add(item);
        }
        return itens;
    }

    private static void updateResultSection(String itemResult, String sectionName) {

        String currentSectionResult = resultBySection.get(sectionName);

        if ( itemResult == PROPOSAL_APPROVED || currentSectionResult == PROPOSAL_REJECTED ) return;
        
        String sectionResultToStorage = ( itemResult == PROPOSAL_PENDENCY ) ? PROPOSAL_PENDENCY : PROPOSAL_REJECTED;
        resultBySection.put(sectionName, sectionResultToStorage);

    }

    private static String getReasons(ProposalAnalysisFields__mdt reason, SObject record){
        String rejectField  = reason.Reject_Reason__r.QualifiedApiName;
        String pendingField = reason.Pending_Reason__r.QualifiedApiName;

        if( String.isNotBlank(rejectField) && String.isNotBlank((String)record.get(rejectField))){
            return (String) record.get(rejectField);
        }else if( String.isNotBlank(pendingField) && String.isNotBlank((String)record.get(pendingField))){
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
        records.put('OthersSection'      ,getRecordBySObject('OthersSection__c'));
        records.put('GeneralSection'      ,getRecordBySObject('GeneralSection__c'));
        
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

    private static Map<String, List<ProposalAnalysisFields__mdt>> getMapFields(String recordType){
        Map<String, List<ProposalAnalysisFields__mdt>> mapSectionFields = new Map<String, List<ProposalAnalysisFields__mdt>>();
        for(ProposalAnalysisFields__mdt currentSectionField : [SELECT Id, Item_Type__c, Value__r.DeveloperName, Value__r.QualifiedApiName, Object_Section__r.DeveloperName, 
                                                                Observation__r.QualifiedApiName, Pending_Reason__r.QualifiedApiName, 
                                                                Reject_Reason__r.QualifiedApiName, Status__r.QualifiedApiName, ExternalId__c, ExternalId__r.QualifiedApiName
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
        string endpoint = NAMED_CREDENTIAL + '/api/analisis-report/' + oppExternalId;
        String authorization = getAuth();

        if('error' == authorization) { return 'Error'; }

        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorization);
        request.setMethod('PATCH');
        request.setBody(payload);
        
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        return (response.getStatusCode() == 200) ? 'Success' : 'Error';
    }

    private static String getAuth(){
        String authResponse;
        HTTPResponse httpAuthRes = GetMulesoftAuthController.getAuth();
        if(httpAuthRes.getStatusCode() == 200){
          Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpAuthRes.getBody());
          authResponse = responseMap.get('token_type') + ' ' + responseMap.get('access_token');
        } else {
            authResponse = 'error';
        }
        return authResponse;
    }
}