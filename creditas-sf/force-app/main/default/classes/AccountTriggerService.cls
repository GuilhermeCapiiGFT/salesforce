public with sharing class AccountTriggerService {
    private static final string PF_ACCOUNT_RT = Util.getRecordTypeIdbyName('Account', 'Pessoa_Fisica');
    private static final string PJ_ACCOUNT_RT = Util.getRecordTypeIdbyName('Account', 'Pessoa_Juridica');
    private static final string CPF_ERROR_MESSAGE = 'O CPF não é válido.';
    private static final string CNPJ_ERROR_MESSAGE = 'O CNPJ não é válido.';

    public static void verifyValidDocument(List<Account> lstNewAccount)
    {
        for(Account varAccount : lstNewAccount)
        {
            if(String.isBlank(varAccount.DocumentNumber__c)) { continue; }

            verifyDocument(varAccount);
            if(PF_ACCOUNT_RT.equals(varAccount.RecordTypeId))
            {
                varAccount.DocumentNumber__c = Util.getMaskedCPF(varAccount.DocumentNumber__c);
                
            } else if(PJ_ACCOUNT_RT.equals(varaccount.RecordTypeId))
            {
                varAccount.DocumentNumber__c = Util.getMaskedCNPJ(varAccount.DocumentNumber__c);
            }
            
        }
    }

    private static void verifyDocument(Account varAccount)
    {
        if(!Util.isValidDocumentNumber(varAccount.DocumentNumber__c) && varAccount.DocumentType__c.equals('CPF'))
        {
            varAccount.DocumentNumber__c.addError(CPF_ERROR_MESSAGE);
        } else if(!Util.isValidDocumentNumber(varAccount.DocumentNumber__c) && varAccount.DocumentType__c.equals('CNPJ'))
        {
            varAccount.DocumentNumber__c.addError(CNPJ_ERROR_MESSAGE);
        }
    }

    public static void updateExternallySynced(List<Account> lstNewAccount){
        List<String> trackedFields = Util.returnCustomMetadaDataFieldApiName('Account');
        for(Account iAccount : lstNewAccount){
            if(TriggerHelper.changedField(iAccount, trackedFields)){
                iAccount.IsExternallySynched__c = false;
            }
        }
    }

    public static void firePlatformEventSynchAccount(List<Account> lstNewAccount){
        for(Account iAccount : lstNewAccount){
            if (iAccount.IsSynchEnabled__c == 'ENABLED') {               
                SynchAccount__e synch = new SynchAccount__e(); 
                EventBus.publish(synch);
            }
        }
    }
}