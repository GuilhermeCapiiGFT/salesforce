/*******************************************************************************************************************************************************
* Copyright © 2021 Creditas
* ======================================================================================================================================================
* Purpose: Prover dados de teste para os métodos reutilizáveis para operações básicas
* ======================================================================================================================================================
* History
* -------
* VERSION 	AUTHOR 							DATE    		DETAIL 		Description
* 1.0 		Thales Yumiya 	                10/07/2021 		Created 	Prover dados de teste para os métodos reutilizáveis para operações básicas
*******************************************************************************************************************************************************/
@isTest
private class UtilTest {
    
    /**************************************************************************************************************************************
	 * Purpose: Método de teste de auxílio para cálculo de tempo decorrido entre dois intervalos.
	 * Parameters: Time startTime, Time endTime
	 * Returns: Time
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                17/08/2021 		Created 	Testa o retorno do Time com horas, minutos, segundos e
     *                                                                          milisegundos correspondentes ao tempo decorrido
     *                                                                          entre os intervalos startTime e endTime (testa a hora).
	**************************************************************************************************************************************/    
    @isTest
    static void getElapsedTimeTest() {
        
        Time time1 = Time.newInstance(00, 00, 00, 00);
        Time time2 = Time.newInstance(01, 00, 00, 00);
        
        Time elapsedTime = Util.getElapsedTime(time1, time2);
        
        System.assertEquals(elapsedTime.hour(), 1);
        System.assertEquals(elapsedTime.minute(), 0);
        System.assertEquals(elapsedTime.second(), 0);
        System.assertEquals(elapsedTime.millisecond(), 0);
        
    }

    /**************************************************************************************************************************************
	 * Purpose: Método de teste de auxílio para cálculo de tempo decorrido entre dois intervalos.
	 * Parameters: Time startTime, Time endTime
	 * Returns: Time
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                17/08/2021 		Created 	Testa o retorno do Time com horas, minutos, segundos e
     *                                                                          milisegundos correspondentes ao tempo decorrido
     *                                                                          entre os intervalos startTime e endTime, com o segundo 
     * 																			parâmetro igual a null.
	**************************************************************************************************************************************/            
    @isTest
    static void getElapsedTimeNullTest() {
        
        Time time1 = Time.newInstance(00, 00, 00, 00);
        
        Time elapsedTime = Util.getElapsedTime(time1, null);
        
        System.assertEquals(elapsedTime.hour(), 0);
        System.assertEquals(elapsedTime.minute(), 0);
        System.assertEquals(elapsedTime.second(), 0);
        System.assertEquals(elapsedTime.millisecond(), 0);
        
    }    
    
    /***************************************************************************************************************************************
	 * Purpose: Método de teste de auxílio para cálculo de tempo decorrido entre dois intervalos.
	 * Parameters: Time startTime, Time endTime
	 * Returns: Time
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                17/08/2021 		Created 	Testa o retorno do Time com horas, minutos, segundos e
     *                                                                          milisegundos correspondentes ao tempo decorrido
     *                                                                          entre os intervalos startTime e endTime (testa o segundos)
	****************************************************************************************************************************************/       
    @isTest
    static void getSecondsElapsedTest() {
        
        Time time1 = Time.newInstance(00, 00, 00, 00);
        Time time2 = Time.newInstance(00, 00, 31, 00);
        
        Integer secondsElapsed = Util.getSecondsElapsed(time1, time2);
        
        System.assertEquals(secondsElapsed, 31);
    }
    
    @isTest
    static void testGetRecordType()
    {
        Id recordTypeId = Util.getRecordTypeIdbyName('Account', 'Mestre');
        String recordTypeName = Util.getRecordTypeNameById('Account', recordTypeId);
        
    }
    
    /*****************************************************************************************************************************
     * Purpose: Obter os campos do field set
     * Parameters: SObject varSObject
     *             String varSObjectField
     * Returns: Object
     * Throws -
     * 
     * History
     * --------
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém o valor do campo do objeto
     *****************************************************************************************************************************/
    @isTest
    static void testGetSObjectFieldValueByFieldName()
    {
        Account varAccount = new Account(Name='Test');
        Contact varContact = new Contact(Account=varAccount);
        Object varAccountName = Util.getSObjectFieldValueByFieldName(varAccount, 'Name');
        Object varContactAccountName = Util.getSObjectFieldValueByFieldName(varContact, 'Account.Name');
        
        // Assertions
        System.assertEquals(varAccount.Name, String.valueOf(varAccountName));
        System.assertEquals(varcontact.Account.Name, String.valueOf(varContactAccountName));
    }
    
    /*****************************************************************************************************************************
     * Purpose: Obter todos os campos do objeto informado
     * Parameters: String varSObjectName
     *             Id varSObjectId
     * Returns: String
     * Throws -
     * 
     * History
     * --------
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    @isTest
    static void testSelectAllFields()
    {
        Task varTask = new Task();
        varTask.Subject = 'Test';
        varTask.OwnerId = UserInfo.getUserId();
        insert varTask;
        
        List<String> lstAllFieldsByName = Util.selectAllFields('Task');
        List<String> lstAllFieldsByObject = Util.selectAllFields(varTask.Id);
        
        // Assertions
        System.assertEquals(false, lstAllFieldsByName.isEmpty());
        System.assertEquals(false, lstAllFieldsByObject.isEmpty());
    }
    
    /*****************************************************************************************************************************
     * Purpose: Atualizar o campo do objeto com o valor informado
     * Parameters: SObject varSObject
     *             String varFieldName
     *             Object varFieldValue
     * Returns: void
     * Throws -
     * 
     * History
     * --------
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Atualiza o campo do objeto com o valor informado
     *****************************************************************************************************************************/
    @isTest
    static void testUpdateSObjectField()
    {
        QuoteLineItem varQuoteLineItem = new QuoteLineItem();
        Util.updateSObjectField(varQuoteLineItem, 'Description', 'Test');
        //Util.updateSObjectField(varQuoteLineItem, 'Desconto__c', 50);
        //Util.updateSObjectField(varQuoteLineItem, 'NEG_Desconto__c', true);
        
        // Assertions
        System.assertEquals('Test', varQuoteLineItem.Description, 'Deveria ter preenchido o campo');
    }
    
    @isTest
    static void testGetPicklistValues()
    {
        List<Schema.PicklistEntry> lstPicklistEntry = Util.getPicklistValues('Opportunity', 'StageName');
        System.assertEquals(false, lstPicklistEntry.isEmpty(), 'Deveria ter retornado a lista com os valores da picklist');
    }
    
    @isTest
    static void testGenerateRandomString()
    {
        String randomStr = Util.generateRandomString(10);
        System.assertEquals(10, randomStr.length());
    }
     
    @isTest
    static void testGetRecordTypesBySObject()
    {
        System.assertEquals(false, Util.getRecordTypesBySObject('Account').isEmpty(), 'Nenhum record type retornado');
    }
    
    @isTest
    static void testDateTimeToString()
    {
        String dttime = Util.dateTimeToString(Datetime.now());
        System.assertEquals(false, String.isBlank(dttime), 'Não retornou data');
    }
    
}