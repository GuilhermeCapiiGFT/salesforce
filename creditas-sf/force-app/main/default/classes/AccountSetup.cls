/*******************************************************************************************************************************
 * Copyright © 2021 Creditas
 * =============================================================================================================================
 * Purpose: Classe para criação de Account para classe de teste
 * =============================================================================================================================
 * History
 * -------
 * VERSION  AUTHOR                          DATE        DETAIL      Description
 * 1.0      Guilherme Sampaio               19/01/2022  Created     Classe para criação de Account para classe de teste
********************************************************************************************************************************/
@isTest
public with sharing class AccountSetup {

    public static Account createAccount(String aName, String aRecordTypeDevName){
        String lAccRT = Util.getRecordTypeIdbyName('Account', aRecordTypeDevName);
        String lDocumentNumber;
        if(aRecordTypeDevName == 'Pessoa_Fisica'){
            lDocumentNumber = DocumentGenerator.generateCPF();
        }else {
            lDocumentNumber = DocumentGenerator.generateCNPJ();
        }
        return new Account(
            Name = aName,
            RecordTypeId = lAccRT,
            DocumentNumber__c = lDocumentNumber,
            IsExternallySynched__c = true
        );
    }

}