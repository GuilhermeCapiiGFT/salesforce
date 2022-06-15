@isTest
private with sharing class GeneralDataTest {
    private static String authMockSuccess = '{"access_token":"tOxqtBAtTEMUdeCNOlZdsUnvjO8gGmMFq01AFQeOLAtlOWglcI3lR6aXpKNvYH8i2hXgbKjqDZ6sJs8SmpQZ9g","token_type":"Bearer","expires_in":86400}';
    private static final String failMock = '{"createdAt":"2021-12-27T17:42:31.221","document":{"type":"CPF","code":"98765432100"},"name":"Consulta em Análise e Telefone Inválido","birthDate":"1995-08-28","productName":"AutoFin","workflowStatus":"GREY_ZONE","result":{"status":"FAILED","reason":"Failed to complete one or several challenges","similarityScore":0.0,"attemptedAt":"2022-01-25T14:48:03.809","attempt":2,"maxAttempts":10},"externalId":"LAP-BDA1167F-994E-4DB0-80F8-6E6C0DEE39DEGG"}';
    private static final String successMock = '{"createdAt":"2021-12-27T17:42:31.221","document":{"type":"CPF","code":"98765432100"},"name":"Consultado com Sucesso","birthDate":"1995-08-28","productName":"AutoFin","workflowStatus":"APPROVED","result":{"status":"CERTIFIED","reason":"","similarityScore":100.0,"attemptedAt":"2022-01-25T14:48:03.809"},"externalId":"LAP-BDA1167F-994E-4DB0-80F8-6E6C0DEE39DEGG"}';
    private static final String assertMsg = 'Wrong field value ';

    @TestSetup
    static void makeData(){
        Account acc = AccountSetup.createAccount('Biometry', 'Pessoa_Fisica');
        insert acc;

        Opportunity opp = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        opp.ExternalId__c = 'LAP-BDA1167F-994E-4DB0-80F8-6E6C0DEE39DEGG';
        opp.Name = 'OppTest';
        insert opp;
    }

    @isTest
    private static void testNewSectionSuccess(){

        String oppId = [SELECT Id FROM Opportunity]?.Id;
        String sectionId;

        HttpMockFactory mock = generateMockResponse(new List<Integer>{200,200}, new List<String>{authMockSuccess, successMock});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        string response = GeneralDataController.getBiometry(oppId,sectionId);
        Test.stopTest();

        GeneralSection__c responseObject = (GeneralSection__c) JSON.deserialize(response.removeStart('{"GeneralSection__c":').removeEnd('}'), GeneralSection__c.class);
        GeneralSection__c databaseSection = [SELECT Opportunity__c, Biometric__c, BiometricFailReason__c, FacialBiometricAnalysis__c, GeneralSectionExternalIdAtWork__c FROM GeneralSection__c LIMIT 1];
        assertFields(null, '', databaseSection, responseObject);
    }

    @isTest
    private static void testExistingSectionSuccess(){

        String oppId = [SELECT Id FROM Opportunity]?.Id;
        GeneralSection__c section = new GeneralSection__c(
            Opportunity__c = oppId,
            GeneralSectionExternalIdAtWork__c = 'AXd-32-B2077'
        );
        insert section;

        HttpMockFactory mock = generateMockResponse(new List<Integer>{200,200}, new List<String>{authMockSuccess, successMock});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        string response = GeneralDataController.getBiometry(oppId,section.Id);
        Test.stopTest();

        GeneralSection__c responseObject = (GeneralSection__c) JSON.deserialize(response.removeStart('{"GeneralSection__c":').removeEnd('}'), GeneralSection__c.class);
        GeneralSection__c databaseSection = [SELECT Opportunity__c, Biometric__c, BiometricFailReason__c, FacialBiometricAnalysis__c, GeneralSectionExternalIdAtWork__c FROM GeneralSection__c LIMIT 1];
        assertFields('AXd-32-B2077', '', databaseSection, responseObject);
    }

    @isTest
    private static void testNewSectionDisapprove(){

        String oppId = [SELECT Id FROM Opportunity]?.Id;
        String sectionId;

        HttpMockFactory mock = generateMockResponse(new List<Integer>{200,200}, new List<String>{authMockSuccess, failMock});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        string response = GeneralDataController.getBiometry(oppId,sectionId);
        Test.stopTest();
        GeneralSection__c responseObject = (GeneralSection__c) JSON.deserialize(response.removeStart('{"GeneralSection__c":').removeEnd('}'), GeneralSection__c.class);
        GeneralSection__c databaseSection = [SELECT Opportunity__c, Biometric__c, BiometricFailReason__c, FacialBiometricAnalysis__c, GeneralSectionExternalIdAtWork__c FROM GeneralSection__c LIMIT 1];
        assertFields(null, databaseSection, responseObject);
    }

    @isTest
    private static void testNewSectionEmptyResponse(){

        String oppId = [SELECT Id FROM Opportunity]?.Id;
        String sectionId;

        HttpMockFactory mock = generateMockResponse(new List<Integer>{200,200}, new List<String>{authMockSuccess, '{}'});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        string response = GeneralDataController.getBiometry(oppId,sectionId);
        Test.stopTest();
        GeneralSection__c responseObject = (GeneralSection__c) JSON.deserialize(response.removeStart('{"GeneralSection__c":').removeEnd('}'), GeneralSection__c.class);
        GeneralSection__c databaseSection = [SELECT Opportunity__c, Biometric__c, BiometricFailReason__c, FacialBiometricAnalysis__c, GeneralSectionExternalIdAtWork__c FROM GeneralSection__c LIMIT 1];

        assertFields(null, databaseSection, responseObject);
    }

    @isTest
    private static void testFailedAuth(){

        String oppId = [SELECT Id FROM Opportunity]?.Id;
        String sectionId;

        HttpMockFactory mock = generateMockResponse(new List<Integer>{500,500}, new List<String>{'{}', '{}'});
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        string response = GeneralDataController.getBiometry(oppId,sectionId);
        Test.stopTest();
        GeneralSection__c section = new GeneralSection__c(Opportunity__c = oppId);
        System.assertEquals(JSON.serialize(new Map<String, SObject>{'GeneralSection__c' => section}), response, 'Wrong response value');
    }

    private static void assertFields(String externalId, GeneralSection__c database, GeneralSection__c response){
        assertFields(externalId, database.BiometricFailReason__c, database, response);
    }

    private static void assertFields(String externalId, String bioFailReason, GeneralSection__c database, GeneralSection__c response){
        System.assertEquals(database.Opportunity__c, response.Opportunity__c, assertMsg + 'Opportunity__c');
        System.assertEquals(database.Biometric__c, response.Biometric__c, assertMsg + 'Biometric__c');
        System.assertEquals(bioFailReason, response.BiometricFailReason__c, assertMsg + 'BiometricFailReason__c');
        System.assertEquals(database.FacialBiometricAnalysis__c, response.FacialBiometricAnalysis__c, assertMsg + '');
        System.assertEquals(externalId, database.GeneralSectionExternalIdAtWork__c, assertMsg + 'GeneralSectionExternalIdAtWork__c');

    }

    private static HttpMockFactory generateMockResponse(List<Integer> statusCode, List<String> payloadMock){
        return new HttpMockFactory(
            statusCode,
            new List<String>{'OK','OK'},
            payloadMock,
            new List<Map<String,String>>{new Map<String,String>(),new Map<String,String>()});
    }
}