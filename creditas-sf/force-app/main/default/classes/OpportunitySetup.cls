/*******************************************************************************************************************************
 * Copyright © 2021 Creditas
 * =============================================================================================================================
 * Purpose: Classe para criação de Opportunity para classe de teste
 * =============================================================================================================================
 * History
 * -------
 * VERSION  AUTHOR                          DATE        DETAIL      Description
 * 1.0      Guilherme Sampaio               19/01/2022  Created     Classe para criação de Opportunity para classe de teste
********************************************************************************************************************************/
@isTest
public with sharing class OpportunitySetup {

    public static Opportunity createOpportunity(Id accountId, String recordTypeDevName){
        Map<String,String> mapStageName = new Map<String,String>{'AtWork' => 'Novo','AutoFin' => 'Crédito', 'Home' => 'Emissão e Pré-Assinatura'};
        String oppRT = Util.getRecordTypeIdbyName('Opportunity', recordTypeDevName);
        String randomString = Util.generateRandomString(15);
        return new Opportunity(
            Name = 'Opp Test 1',
            CloseDate = Date.today().addDays(30),
            RecordTypeId = oppRT,
            AccountId = accountId,
            ExternalId__c = randomString,
            ExternalTenant__c = 'creditasbr',
            ExternalVersion__c = 1,
            StageName = mapStageName.get(recordTypeDevName)
        );
    }

}