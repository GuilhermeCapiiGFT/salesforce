@isTest
private with sharing class OpportunityIntegrationServiceTest {
    
    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();
        Account acc = AccountSetup.createAccount('Roberval', 'Pessoa_Fisica');
        acc.ExternalId__c = 'PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664';
        accounts.add(acc);
        
        Account accPartner = AccountSetup.createAccount('Partner Account', 'Parceiro');
        accPartner.ExternalId__c = '21b0f42e-f27d-4696-9cfe-2f4258e31164';
        accounts.add(accPartner);
        
        Account accOldPartner = AccountSetup.createAccount('Old Partner Account', 'Parceiro');
        accOldPartner.ExternalId__c = 'TESTE-1234';
        accounts.add(accOldPartner);
        
        Account accNivaele = AccountSetup.createAccount('Nivaele', 'Pessoa_Fisica');
        accNivaele.ExternalId__c = 'papirus';
        accounts.add(accNivaele);
        insert accounts;
        
        List<Opportunity> oppToInsert = new List<Opportunity>();
        Opportunity oppAtWork = OpportunitySetup.createOpportunity(acc.Id, 'AtWork');
        oppAtWork.ExternalId__c = 'OPPORTUNITY-VO-ID-6733';
        oppToInsert.add(oppAtWork);

        Opportunity oppHome = OpportunitySetup.createOpportunity(acc.Id, 'Home');
        oppHome.ExternalId__c = 'OPPORTUNITY-VO-HOME-666';
        oppToInsert.add(oppHome);

        Opportunity oppAuto = OpportunitySetup.createOpportunity(acc.Id, 'AutoFin');
        oppAuto.ExternalId__c = 'OPPORTUNITY-VO-AUTOFIN-2077';
        oppAuto.PartnerAccount__c = accOldPartner.Id;
        oppToInsert.add(oppAuto);
        insert oppToInsert;
        
    }
    @isTest
    private static void testGetValues(){
        String fiftyString = '50';
        Double fiftyDouble = Double.valueOf(fiftyString);
        Test.startTest();
        Decimal testStringInput = OpportunityIntegrationService.getDecimalValue(fiftyString);
        Decimal testDoubleInput = OpportunityIntegrationService.getDecimalValue(fiftyDouble);
        Decimal testIntegerInput = OpportunityIntegrationService.getDecimalValue(50);
        Test.stopTest();
        Decimal expectedResponse = Decimal.valueOf(fiftyString);
        System.assertEquals(expectedResponse, testStringInput, 'expected Decimal 50.0');
        System.assertEquals(expectedResponse, testDoubleInput, 'expected Decimal 50.0');
        System.assertEquals(expectedResponse, testIntegerInput, 'expected Decimal 50.0');
    }

    @isTest
    private static void upsertOpportunityRolestest(){
        
        Account acc = [SELECT Id FROM Account WHERE ExternalId__c = 'PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-ID-6733' LIMIT 1];

        OpportunityRole__c oppRole = new OpportunityRole__c (
            ExternalPersonId__c = acc.Id,
            Opportunity__c = opp.Id,
            Role__c = 'SOLIDARY_DEBTOR'
        );
        insert oppRole;
        OpportunityIntegrationService.opportunityId = opp.Id;
        Test.startTest();
            OpportunityIntegrationService.upsertOpportunityRoles( OpportunityIntegrationVO.parse(OpportunityIntegrationVO.opportunityMock()) );
        Test.stopTest();

        OpportunityRole__c oppRoleAfter = [SELECT Role__c FROM OpportunityRole__c LIMIT 1];
        System.assertEquals('PRINCIPAL', oppRoleAfter.Role__c, 'existing oppRole was not updated');

    }

    @isTest
    private static void testupdateOppHOME(){
        //query existing opportunity
        Opportunity oppHome = [SELECT Id,StageName FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-HOME-666'];
        String oppStageName = 'Protocolo';
        oppHome.StageName = oppStageName;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update oppHome;
        Test.startTest();
            Database.upsertResult oppUpsert = OpportunityIntegrationService.upsertOpportunity(OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','HOME_REFIN','','OPPORTUNITY-VO-HOME-666')));
        Test.stopTest();
        //query the same opportunity and check that StageName didn't change
        Opportunity oppHomeAfterUpdate = [SELECT Id,StageName FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-HOME-666'];
        System.assertEquals(oppStageName, oppHomeAfterUpdate.StageName, 'StageName should not have changed');
        System.assert(!oppUpsert.isCreated(), 'Opportunity should have been updated, not created');
    }

    @isTest
    private static void testupdateOppAUTO(){
        //query existing opportunity
        Opportunity oppHome = [SELECT Id,StageName FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-AUTOFIN-2077'];
        String oppStageName = 'Pendência OPS';
        oppHome.StageName = oppStageName;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update oppHome;
        Test.startTest();
            Database.upsertResult oppUpsert =OpportunityIntegrationService.upsertOpportunity(OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','AUTO_FIN','','OPPORTUNITY-VO-AUTOFIN-2077')));
        Test.stopTest();
        //query the same opportunity and check that StageName didn't change
        Opportunity oppHomeAfterUpdate = [SELECT Id,StageName FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-AUTOFIN-2077'];
        System.assertEquals(oppStageName, oppHomeAfterUpdate.StageName, 'StageName should not have changed');
        System.assert(!oppUpsert.isCreated(), 'Opportunity should have been updated, not created');
    }

    @isTest
    private static void createAndUpdateQuoteTest(){
        OpportunityIntegrationService.opportunityId = [SELECT Id FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-AUTOFIN-2077']?.Id;
        Test.startTest();
        Database.upsertResult quoteInsert = OpportunityIntegrationService.upsertQuote(OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','AUTO_FIN','','OPPORTUNITY-VO-AUTOFIN-2077')));
        System.assert(quoteInsert.isCreated() , 'Quote should have been created');
        System.assert(quoteInsert.isSuccess() , 'Operation should be sucessfull');
        Database.upsertResult quoteUpdate = OpportunityIntegrationService.upsertQuote(OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','AUTO_FIN','','OPPORTUNITY-VO-AUTOFIN-2077')));
        Test.stopTest();
        System.assert(!quoteUpdate.isCreated() , 'Quote should have been updated');
        System.assert(quoteUpdate.isSuccess() , 'Operation should be sucessfull');
    }
    
    @isTest
    private static void testCreateOppAutoFinPartner(){
        Account accPartner = [SELECT Id FROM Account WHERE ExternalId__c = '21b0f42e-f27d-4696-9cfe-2f4258e31164' LIMIT 1];
        Database.upsertResult oppUpsert;
        
        Test.startTest();
        OpportunityIntegrationVO payload = OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','AUTO_FIN','PENDING_SIGNATURE','AUTOFIN-PARTNER'));
        OpportunityIntegrationService.getPersonIdAndAccountName(payload.participants);
        oppUpsert = OpportunityIntegrationService.upsertOpportunity(payload);
        Test.stopTest();
        
        Opportunity oppHomeAfterUpdate = [SELECT Id,StageName, PartnerAccount__c FROM Opportunity WHERE ExternalId__c = 'AUTOFIN-PARTNER'];
        System.assertEquals(accPartner.Id, oppHomeAfterUpdate.PartnerAccount__c, 'Invalid Partner Account');
        System.assert(oppUpsert.isCreated(), 'Opportunity should have been created, not updated');
    }
    
    @isTest
    private static void testCreateOppAtWorkPartner(){
        Database.upsertResult oppUpsert;
        Test.startTest();
        OpportunityIntegrationVO payload = OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','HOME_REFIN','PENDING_SIGNATURE','ATWORK-PARTNER'));
        OpportunityIntegrationService.getPersonIdAndAccountName(payload.participants);
        oppUpsert = OpportunityIntegrationService.upsertOpportunity(payload);
        Test.stopTest();
        Opportunity oppHomeAfterUpdate = [SELECT Id, StageName, PartnerAccount__c FROM Opportunity WHERE ExternalId__c = 'ATWORK-PARTNER' LIMIT 1];
        System.assertEquals(null, oppHomeAfterUpdate.PartnerAccount__c, 'Partner Account should be null');
        System.assert(oppUpsert.isCreated(), 'Opportunity should have been created, not updated');
    }
    
    @isTest
    private static void testUpdateOppAutoFinPartner(){
        Database.upsertResult oppUpsert;
        
        Test.startTest();
        OpportunityIntegrationVO payload = OpportunityIntegrationVO.parse(OpportunityIntegrationControllerTest.payloadMock('success','AUTO_FIN','PENDING_SIGNATURE','OPPORTUNITY-VO-AUTOFIN-2077'));
        OpportunityIntegrationService.getPersonIdAndAccountName(payload.participants);
        oppUpsert = OpportunityIntegrationService.upsertOpportunity(payload);
        Test.stopTest();
 
        Account accNewPartner = [SELECT Id FROM Account WHERE ExternalId__c = '21b0f42e-f27d-4696-9cfe-2f4258e31164' LIMIT 1];
        Opportunity oppHomeAfterUpdate = [SELECT Id, StageName, PartnerAccount__c FROM Opportunity WHERE ExternalId__c = 'OPPORTUNITY-VO-AUTOFIN-2077'];
        
        System.assert(!oppUpsert.isCreated(), 'Opportunity should have been updated, not created');
        System.assertEquals(accNewPartner.Id, oppHomeAfterUpdate.PartnerAccount__c, 'Invalid Partner Account');
    }
}