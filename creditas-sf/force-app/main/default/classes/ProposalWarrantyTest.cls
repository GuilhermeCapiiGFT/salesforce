@isTest
private with sharing class ProposalWarrantyTest {

    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>();
        Account acc = AccountSetup.createAccount('Jorge da Capacidoca', 'Pessoa_Fisica');
        acc.ExternalId__c = 'ID-JORGE-CAPACIDOCA';
        accList.add(acc);

        Account accRole = AccountSetup.createAccount('Fiador do Jorge', 'Pessoa_Fisica');
        accRole.ExternalId__c = 'ID-DO-FIADOR';
        accList.add(accRole);
        insert accList;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppWithFinResource = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        oppWithFinResource.ExternalId__c = 'OPP-JORGE-CAPACIDOCA';
        oppList.add(oppWithFinResource);
        Opportunity oppWithoutFinResource = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        oppWithoutFinResource.ExternalId__c = 'OPP-JORGE-CAPACIDOCA-NO-RESOURCE';
        oppList.add(oppWithoutFinResource);
        insert oppList;
        FinancialResources__c finResource = FinancialResourceSetup.createFinancialResource('Auto');
        insert finResource;
        OpportunityRole__c oppRole = new OpportunityRole__c(
            Opportunity__c = oppWithFinResource.Id,
            Role__c = 'COLLATERAL_GUARANTOR',
            ExternalPersonId__c = accRole.Id,
            ExternalOpportunityId__c = 'OPP-JORGE-CAPACIDOCA',
            ReportedIncome__c = 666
        );
        insert oppRole;

        Garantias__c guarantee = new Garantias__c(
            Account__c = accRole.Id,
            Opportunity__c = oppWithFinResource.Id,
            Recurso_Financeiro__c = finResource.Id
        );
        insert guarantee;

        WarrantyDataSection__c dataSection = new WarrantyDataSection__c(
            UFplateStatus__c = 'Aprovado',
            RenavamStatus__c = 'Aprovado',
            PlateStatus__c = 'Aprovado',
            Opportunity__c = oppWithFinResource.Id
        );
        insert dataSection;

    }

    @isTest
    private static void testgetFinancialResourceSucess(){
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA']?.Id;
        FinancialResources__c finBase = [SELECT ResourceKey__c,Plate__c,ModelYear__c,ManufacturingYear__c,Brand__c,Model__c,Color__c,LicensingState__c,State__c,ExternalCodeOrigin__c FROM FinancialResources__c];

        Test.startTest();
            FinancialResources__c getFin = ProposalWarrantyController.getFinancialResource(oppId);
        Test.stopTest();

        System.assertEquals(finBase.Plate__c, getFin.Plate__c, 'Wrong financial Resources queried');
        System.assertEquals(finBase.Brand__c, getFin.Brand__c, 'Wrong financial Resources queried');
        System.assertEquals(finBase.ResourceKey__c, getFin.ResourceKey__c, 'Wrong financial Resources queried');
    }

    @isTest
    private static void testgetFinancialResourceException(){
        String oppId = 'FAKE_OPP_ID';
        Exception testException;
        Test.startTest();
            try{
                FinancialResources__c getFin = ProposalWarrantyController.getFinancialResource(oppId);
            }catch(Exception e){
                testException = e;
            }
        Test.stopTest();
        System.assertEquals('Invalid id: FAKE_OPP_ID', testException.getMessage(), 'Wrong exception Thrown');
    }

    @isTest
    private static void testgetFinancialResourceEmptyId(){
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA-NO-RESOURCE']?.Id;
        Test.startTest();
            
            FinancialResources__c getFin = ProposalWarrantyController.getFinancialResource(oppId);
            
        Test.stopTest();
        System.assertEquals(new FinancialResources__c(), getFin, 'should return empty FinancialResources__c');
    }

    @isTest
    private static void testSaveFinancialResourceSucess(){
        FinancialResources__c financialResource = FinancialResourceSetup.createFinancialResource('Auto');
        Test.startTest();
            Boolean operationSucess = ProposalWarrantyController.saveFinancialResource(financialResource);
        Test.stopTest();
        System.assert(operationSucess, 'Should be true');
        System.assertEquals(2, [SELECT Count() FROM FinancialResources__c], '2 Record should exist');
    }

    @isTest
    private static void testSaveFinancialResourceFail(){
        String autoRTId = Util.getRecordTypeIdbyName('FinancialResources__c', 'Auto');
        FinancialResources__c financialResource = new FinancialResources__c(Plate__c = 'DBZ-2077', RecordTypeId = autoRTId, ExternalTenant__c = 'blabla');
        Test.startTest();
            Boolean operationSucess = ProposalWarrantyController.saveFinancialResource(financialResource);
        Test.stopTest();
        System.debug(operationSucess);
        System.assert(!operationSucess, 'Should be false');
        System.assertEquals(1, [SELECT Count() FROM FinancialResources__c], '2 Record should exist');
    }

    @isTest
    private static void testgetWarrantyDataSectionSuccess(){
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA']?.Id;
        WarrantyDataSection__c warrantyData = [SELECT UFplateStatus__c, RenavamStatus__c, PlateStatus__c FROM WarrantyDataSection__c WHERE Opportunity__c = :oppId];

        Test.startTest();
        WarrantyDataSection__c getWarrantyData = ProposalWarrantyController.getWarrantyDataSection(oppId);
        Test.stopTest();

        System.assertEquals(warrantyData.UFplateStatus__c, getWarrantyData.UFplateStatus__c, 'Wrong warranty data queried');
        System.assertEquals(warrantyData.RenavamStatus__c, getWarrantyData.RenavamStatus__c, 'Wrong warranty data queried');
        System.assertEquals(warrantyData.PlateStatus__c, getWarrantyData.PlateStatus__c, 'Wrong warranty data queried');
    }

    @isTest
    private static void testgetWarrantyDataSectionEmptyId(){
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA-NO-RESOURCE']?.Id;

        Test.startTest();  
            WarrantyDataSection__c getWarrantyData = ProposalWarrantyController.getWarrantyDataSection(oppId);
        Test.stopTest();

        System.assertEquals(new WarrantyDataSection__c(), getWarrantyData, 'should return empty WarrantyDataSection__c');
    }

    @isTest
    private static void testgetWarrantyDataException(){
        String oppId = 'FAKE_WARRANTY_DATA_ID';
        Exception testException;
        Test.startTest();
            try{
                WarrantyDataSection__c getWarrantyData = ProposalWarrantyController.getWarrantyDataSection(oppId);
            }catch(Exception e){
                testException = e;
            }
        Test.stopTest();
        System.assertEquals('Invalid id: FAKE_WARRANTY_DATA_ID', testException.getMessage(), 'Wrong exception Thrown');
    }

    @isTest
    private static void testSaveWarrantyDataSucess(){
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA-NO-RESOURCE']?.Id;
        WarrantyDataSection__c warrantyData = new WarrantyDataSection__c(UFplateStatus__c = 'Aprovado', Opportunity__c = oppId);
        Test.startTest();
            Boolean operationSucess = ProposalWarrantyController.saveWarrantyDataSection(warrantyData);
        Test.stopTest();
        System.assert(operationSucess, 'Should be true');
        System.assertEquals(2, [SELECT Count() FROM WarrantyDataSection__c], '2 Record should exist');
    }

    @isTest
    private static void testSaveWarrantyDataFail(){
        WarrantyDataSection__c warrantyData = new WarrantyDataSection__c(UFplateStatus__c = 'Aprovado');
        Test.startTest();
            Boolean operationSucess = ProposalWarrantyController.saveWarrantyDataSection(warrantyData);
        Test.stopTest();
        System.assert(!operationSucess, 'Should be false');
        System.assertEquals(1, [SELECT Count() FROM WarrantyDataSection__c], 'only 1 Record should exist');
    }
    
}
