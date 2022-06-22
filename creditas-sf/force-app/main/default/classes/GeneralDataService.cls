public with sharing class GeneralDataService {
    private String authToken;
    private final String biometryCredential = 'callout:mulesoftGateway';
    private String oppExternalId;

    public GeneralSection__c getGeneralData(String opportunityid, String sectionId) {
        GeneralSection__c section = new GeneralSection__c(Opportunity__c = opportunityid);

        if(String.isBlank(this.authToken)) { return section; }
        
        GeneralDataVO response = getBiometryResult();

        section.Id = sectionId;
        section.FacialBiometricAnalysis__c = response?.workflowStatus;
        section.Biometric__c = response?.result?.status;
        section.BiometricFailReason__c = response?.result?.reason;
        upsert section;
        return section;
    }

    public void setExternalId(String oppId){
        this.oppExternalId = getOppFields(oppId).ExternalId__c;
    }

    public void getAuth(){
        HTTPResponse httpAuthRes = GetMulesoftAuthController.getAuth();
    
        if(httpAuthRes.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpAuthRes.getBody());
            this.authToken = responseMap.get('token_type') + ' ' + responseMap.get('access_token');
        }
    }
    public void updateCrivoQuery(String oppId, String sectionId){
        Opportunity opp = this.getOppFields(oppId);
        GeneralSection__c section = new GeneralSection__c(Id = sectionId);
        section.CrivoQuery__c = opp.CrivoQuery__c;
        update section;
    }
    private GeneralDataVO getBiometryResult(){
        String endpoint = this.biometryCredential + '/api/trust/facial-biometric/session?externalId=' + this.oppExternalId;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', this.authToken);
        request.setMethod('GET');

        HTTPResponse response = new Http().send(request);
        return parseResponse(response.getBody());
    }

    private GeneralDataVO parseResponse(String body){
        return GeneralDataVO.parse(body);
    }

    private Opportunity getOppFields(String oppId){
        OpportunityRepository repo = new OpportunityRepository();
        Opportunity opp = repo.findById(oppId);
        return opp;
    }

}