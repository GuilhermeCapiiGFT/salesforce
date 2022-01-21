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

    public static Opportunity createOpportunity(Id aAccountId, String aRecordTypeDevName){
        String lOppRT = Util.getRecordTypeIdbyName('Opportunity', aRecordTypeDevName);
        return new Opportunity(
            Name = 'Opp Test 1',
            CloseDate = Date.today().addDays(30),
            RecordTypeId = lOppRT,
            AccountId = aAccountId,
            ExternalTenant__c = 'creditasbr',
            ExternalVersion__c = 1,
            StageName = 'Emissão e Pré-Assinatura'
        );
    }

}