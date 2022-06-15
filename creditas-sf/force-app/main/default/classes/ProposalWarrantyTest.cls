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
        
        WarrantyDataSection__c dataSection = new WarrantyDataSection__c(
            UFplateStatus__c = 'APPROVED',
            RenavamStatus__c = 'APPROVED',
            PlateStatus__c = 'APPROVED',
            Opportunity__c = oppWithFinResource.Id
        );
        insert dataSection;

    }

    @isTest
    private static void testSaveMethodSucess(){
        
        String oppId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPP-JORGE-CAPACIDOCA-NO-RESOURCE']?.Id;

        WarrantyDataSection__c warrantyObject = new WarrantyDataSection__c(UFplateStatus__c = 'APPROVED', Opportunity__c = oppId);

        Test.startTest();
            ProposalWarrantyController.saveMethod(warrantyObject);
        Test.stopTest();

        System.assertEquals(2, [SELECT Count() FROM WarrantyDataSection__c], '2 Record should exist');
    }

    @isTest
    private static void testSaveWarrantyDataException(){

        WarrantyDataSection__c warrantyObject = new WarrantyDataSection__c(UFplateStatus__c = 'APPROVED');
        
        Exception testException;

        Test.startTest();
            try{
                ProposalWarrantyController.saveMethod(warrantyObject);
            }catch(Exception e){
                testException = e;
            }
        Test.stopTest();
        
        System.assertEquals('System.AuraHandledException', testException.getTypeName(), 'Wrong exception was thrown');
        System.assertEquals(1, [SELECT Count() FROM WarrantyDataSection__c], 'only 1 Record should exist');
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
}