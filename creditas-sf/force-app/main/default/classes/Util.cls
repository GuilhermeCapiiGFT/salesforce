/***********************************************************************************************************************************************
* Copyright © 2021 Creditas
* ==============================================================================================================================================
* Purpose: Prover métodos reutilizáveis para operações básicas
* ==============================================================================================================================================
* History
* -------
* VERSION 	AUTHOR 							DATE    		DETAIL 		Description
* 1.0 		Thales Yumiya 	                11/08/2021 		Created 	Prover métodos reutilizáveis para operações básicas
***********************************************************************************************************************************************/
public class Util {
    
    public class UtilException extends Exception {}

    
    /*****************************************************************************************************************************
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya 	    11/08/2021 			Created 		Retorna o RecordTypeId correspondente ao
     *                                                                          RecordTypeName 
	*****************************************************************************************************************************/    
    	private static Map<String, Map<String, Id>> lMapAllSobjRT = new Map<String, Map<String, Id>>();
    
		public static Id getRecordTypeIdbyName(String objType, String recordTypeName) {
            Map<String, Id> lMapSobjRT = lMapAllSobjRT.get(objType.toLowerCase());
            if (lMapSobjRT != null && !lMapSobjRT.isEmpty()) { return lMapSobjRT.get(recordTypeName); }
            
            Map<String, Schema.RecordTypeInfo> lMapRTInfo = Schema.getGlobalDescribe().get(objType).getDescribe().getRecordTypeInfosByDeveloperName();
            if (lMapRTInfo == null) { return null; }
            
            lMapSobjRT = new Map<String, Id>();
            for (String iRtDevName: lMapRTInfo.keyset())
            {
                lMapSobjRT.put(iRtDevName, lMapRTInfo.get(iRtDevName).getRecordTypeId());
            }
            lMapAllSobjRT.put(objType.toLowerCase(), lMapSobjRT);
            return lMapSobjRT.get(recordTypeName);
        }        
    
    /*****************************************************************************************************************************
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya 	    11/08/2021 			Created 		Retorna o RecordTypeName correspondente ao
     *                                                                          RecordTypeId 
	*****************************************************************************************************************************/    
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }   
            
    /*****************************************************************************************************************************
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                11/08/2021 		Created 	Retorna Time com horas, minutos, segundos e
     *                                                                          milisegundos correspondentes ao tempo decorrido
     *                                                                          entre os intervalos startTime e endTime.
	*****************************************************************************************************************************/
    public static Time getElapsedTime(Time startTime, Time endTime) {
        
        if(startTime == null || endTime == null) {
            return Time.newInstance(0, 0, 0, 0);
        }
        
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
        
        return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
    }
    
    /*****************************************************************************************************************************
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                11/08/2021 		Created 	Chama Utils.GetElapsedTime; retorna tempo
     *                                                                          decorrido entre startTime e endTime em
     *                                                                          segundos.
	*****************************************************************************************************************************/
    public static Integer getSecondsElapsed(Time startTime, Time endTime) {
        return GetElapsedTime(startTime, endTime).second();
    }
    

    /*****************************************************************************************************************************
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya					11/08/2021 		Created 	getPicklistValues - Obter valores de picklist
	*****************************************************************************************************************************/
    public static List<Schema.PicklistEntry> getPicklistValues(String objectApiName,String fieldName){ 
        
        List<Schema.PicklistEntry> lstPickvals = new List<Schema.PicklistEntry>();
        try {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);//From the Object Api name retrieving the SObject
            Sobject objectName = targetType.newSObject();
            Schema.sObjectType varSObjectType = objectName.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult varSObjectDescribe = varSObjectType.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> mapFields = varSObjectDescribe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> listPicklistValues = mapFields.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : listPicklistValues) 
            { 
                lstPickvals.add(a);
            }
        }catch(Exception ex){
            System.debug('invalid ObjectApi_name or Field_name. Details: ' + ex.getMessage());
        }
        
        return lstPickvals;
    }
    
    /*****************************************************************************************************************************
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya					11/08/2021 		Created 	Method generateRandomString
	*****************************************************************************************************************************/
    public static String generateRandomString(Integer strLength) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < strLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém o valor do campo do objeto
     *****************************************************************************************************************************/
    public static Object getSObjectFieldValueByFieldName(SObject sObj, String fieldReference)
    {
        if(String.isBlank(fieldReference))
        {
            return null;
        }
        
        Object fieldValue;
        Map<String, Object> mapSObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
        
        if(fieldReference.contains('.'))
        {
            String prefix = fieldReference.substringBefore('.');
            String sufix = fieldReference.substringAfter('.');
            
            fieldValue = mapSObject.containsKey(prefix) ? Util.getSObjectFieldValueByFieldName(sObj.getSObject(prefix), sufix) : null;
        } else
        {
            fieldValue = mapSObject.containsKey(fieldReference) ? sObj.get(fieldReference) : null;
        }
        
        return fieldValue;
    }
    
        
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    private static List<String> selectAllFields(String varSObjectName, Id varSObjectId)
    {
        List<String> lstSObjectField = new List<String>();
        Map<String, Schema.SObjectField> mapSObjectField;
        
        if(String.isNotBlank(varSObjectName))
        {
            mapSObjectField = Schema.getGlobalDescribe().get(varSObjectName).getDescribe().fields.getMap();
        } else
        {
            mapSObjectField = varSObjectId.getSObjectType().getDescribe().fields.getMap();
        }
        
        if(mapSObjectField != null && !mapSObjectField.isEmpty())
        {
            for(Schema.SObjectField varSObjectField : mapSObjectField.values())
            {
                Schema.DescribeFieldResult varDescribeFieldResult = varSObjectField.getDescribe();
                
                lstSObjectField.add(varDescribeFieldResult.getName());
            }
        }
        
        return lstSObjectField;
    }
    
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    public static List<String> selectAllFields(String varSObjectName)
    {
        return selectAllFields(varSObjectName, null);
    }
    
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    public static List<String> selectAllFields(Id varSObjectId)
    {
        return selectAllFields(null, varSObjectId);
    }
    
    /*****************************************************************************************************************************
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya    	11/08/2021 			Created 		Retorna do Map com os RecordTypeIds do Objeto
	*****************************************************************************************************************************/    
    public static Map<Id, Schema.RecordTypeInfo> getRecordTypesBySObject(String objectName)
    {
        Map<Id, Schema.RecordTypeInfo> mapRecTypeSObject = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById();
    	return mapRecTypeSObject;
    }
    
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Atualiza o campo do objeto com o valor informado
     *****************************************************************************************************************************/
    public static void updateSObjectField(SObject varSObject, String varFieldName, Object varFieldValue)
    {
        Schema.DisplayType varSObjectFieldType = varSObject.getSObjectType().getDescribe().fields.getMap().get(varFieldName).getDescribe().getType();
        
        if(varFieldValue != null)
        {
            if(varSObjectFieldType == Schema.DisplayType.BOOLEAN)
            {
                varSObject.put(varFieldName, Boolean.valueOf(varFieldValue));
            } else if(varSObjectFieldType == Schema.DisplayType.DOUBLE || varSObjectFieldType == Schema.DisplayType.CURRENCY || varSObjectFieldType == Schema.DisplayType.LONG || varSObjectFieldType == Schema.DisplayType.PERCENT)
            {
                varSObject.put(varFieldName, Double.valueOf(varFieldValue));
            } else
            {
                varSObject.put(varFieldName, String.valueOf(varFieldValue));
            }
        }
    }
    
    /*****************************************************************************************************************************
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Busca o mapeamento de campos do custom metadata type
     *****************************************************************************************************************************/
    // public static void syncSObjectFields(SObject varSObjectOrigin, SObject varSObjectDestination)
    // {
    //     String varSObjectOriginApiName = varSObjectOrigin.getSObjectType().getDescribe().Name;
    //     String varSObjectDestinationApiName = varSObjectDestination.getSObjectType().getDescribe().Name;
        
    //     for(Custom_Field_Sync_Map__mdt varCustomFieldSyncMap : [SELECT CampoOrigem__r.QualifiedApiName, CampoDestino__r.QualifiedApiName 
    //                                                             FROM Custom_Field_Sync_Map__mdt 
    //                                                             WHERE ObjetoOrigem__r.QualifiedApiName = :varSObjectOriginApiName 
    //                                                               AND ObjetoDestino__r.QualifiedApiName = :varSObjectDestinationApiName])
    //     {
            
    //         Schema.SObjectType obj = Schema.getGlobalDescribe().get(varSObjectDestinationApiName);
    //         Schema.DescribeSObjectResult resObj = obj.getDescribe();
    //         Schema.DescribeFieldResult field = resObj.fields.getMap().get(varCustomFieldSyncMap.CampoDestino__r.QualifiedApiName).getDescribe();
            
    //         if (field.getType() == Schema.DisplayType.Boolean && varSObjectOrigin.get(varCustomFieldSyncMap.CampoOrigem__r.QualifiedApiName) == null) {
    //             varSObjectDestination.put(varCustomFieldSyncMap.CampoDestino__r.QualifiedApiName, false);    
    //         } else {
    //         	varSObjectDestination.put(varCustomFieldSyncMap.CampoDestino__r.QualifiedApiName, varSObjectOrigin.get(varCustomFieldSyncMap.CampoOrigem__r.QualifiedApiName));    
    //         }
    //     }
    // }
    
    /*****************************************************************************************************************************
    * VERSION      AUTHOR                            DATE            DETAIL      Description
    * 1.0          Thales Yumiya                     13/11/2021      Created     Retorna Datetime em String conforme a 
    *                                                                            ISO 8601; recupera fuso horário de acordo
    *                                                                            com o local do usuário que o executa.
    *****************************************************************************************************************************/
    public static String dateTimeToString(Datetime dt) {

        TimeZone timeZone = UserInfo.getTimeZone();

        Integer offset = timeZone.getOffset(dt) / 3600000;

        Boolean isNegative = false;
        if(offset < 0)
        {
            offset *= (-1);
            isNegative = true;
        }

        String stringOffset = String.valueOf(offset).leftPad(2, '0');

        if(isNegative)
        {
            stringOffset = stringOffset.leftPad(stringOffset.length() + 1, '-');
        }
        else
        {
            stringOffset = stringOffset.leftPad(stringOffset.length() + 1, '+');
        }

        return dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') + stringOffset;
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description atualizar campo isExternallySynced da Conta quando for PF
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           13/08/21                    Atualizar o campo isExternallySynched na Account para os objetos
                                                                      relacionados
    **********************************************************************************************************************************/
    public static void updateIsExternallySynced(String varSObjectApiName, List<SObject> lstNewRecord, Map<Id, SObject> mapOldRecord)
    {
        Set<Id> setAccountIds = new Set<Id>();
        List<Account> listAccountToUpdate = new List<Account>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();  
        Map<Account, SObject> mapAccountSObject = new Map<Account, SObject>();  

        for(SObject newSObject : lstNewRecord)
        {   
            setAccountIds.add((Id) newSObject.get('Account__c'));
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, isExternallySynched__c FROM Account WHERE Id IN: setAccountIds]); 
        
        for(SObject newSObject : lstNewRecord)
        {
            SObject oldSObject = mapOldRecord.get(newSObject.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newSObject.get(trackedField) != oldSObject.get(trackedField))
                {     
                    mapAccountSObject.put(mapAccounts.get((Id) oldSObject.get('Account__c')), oldSObject);
                }
            }
        }

        if(!mapAccountSObject.isEmpty())
        {
            for(Account varAccount : mapAccountSObject.keySet())
            {
                varAccount.IsExternallySynched__c = false;
                listAccountToUpdate.add(varAccount);
            }
        }

        TriggerHandler.bypass('AccountTriggerHandler');
        if(!listAccountToUpdate.isEmpty())
        {
            update listAccountToUpdate;
        }
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }

    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description atualizar campo isExternallySynced de Oportunidade
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa           17/12/2021                  Atualizar o campo isExternallySynched em Opportunity para os objetos
                                                                      relacionados
    **********************************************************************************************************************************/
    public static void updateIsExternallySyncedOpportunity(String varSObjectApiName, List<SObject> lstNewRecord, Map<Id, SObject> mapOldRecord)
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();  
        Map<Opportunity, SObject> mapOpportunitySObject = new Map<Opportunity, SObject>();  

        for(SObject newSObject : lstNewRecord)
        {   
            setOpportunityIds.add((Id) newSObject.get('Opportunity__c'));
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, IsExternallySynched__c FROM Opportunity WHERE Id IN: setOpportunityIds]); 
        
        for(SObject newSObject : lstNewRecord)
        {
            SObject oldSObject = mapOldRecord.get(newSObject.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newSObject.get(trackedField) != oldSObject.get(trackedField))
                {     
                    mapOpportunitySObject.put(mapOpportunity.get((Id) oldSObject.get('Opportunity__c')), oldSObject);
                }
            }
        }

        if(!mapOpportunitySObject.isEmpty())
        {
            for(Opportunity varOpportunity : mapOpportunitySObject.keySet())
            {
                varOpportunity.IsExternallySynched__c = false;
                listOpportunityToUpdate.add(varOpportunity);
            }
        }

        TriggerHandler.bypass('OpportunityTriggerHandler');
        if(!listOpportunityToUpdate.isEmpty())
        {
            update listOpportunityToUpdate;
        }
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    /**********************************************************************************************************************************
    * ================================================================================================================================
    * @description Atualizar o campo isExternallySynched em Opportunity para o objeto Quote
    * ================================================================================================================================
    * History
    * -------
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Nathalia Rosa           17/12/2021                  Atualizar o campo isExternallySynched em Opportunity para o objeto Quote
    **********************************************************************************************************************************/
    public static void updateIsExternallySyncedQuoteOpportunity(String varSObjectApiName, List<SObject> lstNewRecord, Map<Id, SObject> mapOldRecord)
    {
        Set<Id> setOpportunityIds = new Set<Id>();
        List<Opportunity> listOpportunityQuoteToUpdate = new List<Opportunity>();
        Map<String, Custom_Field_Tracking_Map__mdt> mapTrackedFields = new Map<String, Custom_Field_Tracking_Map__mdt>();  
        Map<Opportunity, SObject> mapOpportunitySObject = new Map<Opportunity, SObject>();  

        for(SObject newSObject : lstNewRecord)
        {   
            setOpportunityIds.add((Id) newSObject.get('OpportunityId'));
        }

        for(Custom_Field_Tracking_Map__mdt varCustomTrackedField : [SELECT CampoRastreado__r.QualifiedApiName 
                                                                    FROM Custom_Field_Tracking_Map__mdt
                                                                    WHERE ObjetoRastreado__r.QualifiedApiName =: varSObjectApiName])
        {
            mapTrackedFields.put(varCustomTrackedField.CampoRastreado__r.QualifiedApiName, varCustomTrackedField);   
        }

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, IsExternallySynched__c FROM Opportunity WHERE Id IN: setOpportunityIds]); 
        
        for(SObject newSObject : lstNewRecord)
        {
            SObject oldSObject = mapOldRecord.get(newSObject.Id);
            
            for(String trackedField : mapTrackedFields.keySet())
            {
                if(newSObject.get(trackedField) != oldSObject.get(trackedField))
                {     
                    mapOpportunitySObject.put(mapOpportunity.get((Id) oldSObject.get('OpportunityId')), oldSObject);
                }
            }
        }

        if(!mapOpportunitySObject.isEmpty())
        {
            for(Opportunity varOpportunity : mapOpportunitySObject.keySet())
            {
                varOpportunity.IsExternallySynched__c = false;
                listOpportunityQuoteToUpdate.add(varOpportunity);
            }
        }

        TriggerHandler.bypass('OpportunityTriggerHandler');
        if(!listOpportunityQuoteToUpdate.isEmpty())
        {
            update listOpportunityQuoteToUpdate;
        }
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    
    

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    
    **********************************************************************************************************************************/
    private static Integer calcularDigito(String str, List<Integer> peso) 
    {
        Integer soma = 0;
        Integer digito;
        
        for (Integer indice = str.length()-1; indice >= 0; indice--) 
        {
            digito = Integer.valueOf(str.substring(indice,indice+1));
            soma += digito * peso.get(peso.size() - str.length() + indice);
        }   
        soma = math.mod(soma*10, 11);
        return soma > 9 ? 0 : soma;
    }

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    verifica se o cpf é válido
    **********************************************************************************************************************************/
    public static boolean isValidCPF(String cpf) 
    {
        List<Integer> pesoCPF = new List<Integer>{11, 10, 9, 8, 7, 6, 5, 4, 3, 2};
    
        if ((cpf==null) || (cpf.length()!=11))
        {
            return false;

        }
        else
        {
            Integer digito1 = calcularDigito(cpf.substring(0,9), pesoCPF);
            Integer digito2 = calcularDigito(cpf.substring(0,9) + digito1, pesoCPF);
            return cpf.equals(cpf.substring(0,9) + digito1 + digito2) && !(isAllTheSameCaracter(cpf)); 
        }
    }

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    verifica se o cnpj é válido
    **********************************************************************************************************************************/
    public static boolean isValidCNPJ(String cnpj) 
    {
        List<Integer> pesoCNPJ = new List<Integer>{6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
    
        if ((cnpj==null)||(cnpj.length()!=14))
        {
           return false; 
        }
        Integer digito1 = calcularDigito(cnpj.substring(0,12), pesoCNPJ);
        Integer digito2 = calcularDigito(cnpj.substring(0,12) + digito1, pesoCNPJ);
        return cnpj.equals(cnpj.substring(0,12) + digito1 + digito2) && !(isAllTheSameCaracter(cnpj));
    }

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    gera a string do documento com a máscara
    **********************************************************************************************************************************/
    public static String getMaskedCPF(String cpf){
        String p1;
        String p2;
        String p3;
        String p4;
        
        String cleanedStr = getNumbersOnly(cpf);
        String maskedStr;
        if(isValidCPF(cleanedStr)){
            p1 = cleanedStr.substring(0, 3);
            p2 = cleanedStr.substring(3, 6);
            p3 = cleanedStr.substring(6, 9);
            p4 = cleanedStr.substring(9, 11);
            maskedStr = p1 + '.' + p2 + '.' + p3 + '-' + p4;
        }
        return maskedStr;
    }

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    gera a string do documento com a máscara
    **********************************************************************************************************************************/
    public static String getMaskedCNPJ(String cnpj){
        String p1;
        String p2;
        String p3; 
        String p4;
        String p5;
            
        String cleanedStr = getNumbersOnly(cnpj);
        String maskedStr;
        if(isValidCNPJ(cleanedStr)){
            p1 = cleanedStr.substring(0, 2);
            p2 = cleanedStr.substring(2, 5);
            p3 = cleanedStr.substring(5, 8);
            p4 = cleanedStr.substring(8, 12);
            p5 = cleanedStr.substring(12, 14);
            maskedStr = p1 + '.' + p2 + '.' + p3 + '/' + p4 + '-' + p5;
        }
        return maskedStr;
    }

    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    verifica se o documento contém números iguais
    **********************************************************************************************************************************/
    public static boolean isAllTheSameCaracter(String numDoc)
    {
        if(numDoc.length() == 11)
        {
            if(numDoc == '00000000000' || numDoc == '11111111111' || numDoc == '22222222222' || numDoc == '33333333333' || 
               numDoc == '44444444444' || numDoc == '55555555555' || numDoc == '66666666666' || numDoc == '77777777777' || 
               numDoc == '88888888888' || numDoc == '99999999999')
            {
                return true;
            } else {
                return false;  
            } 
        } else if(numDoc.length() == 14) {
            if(numDoc == '00000000000000' || numDoc == '11111111111111' || numDoc == '22222222222222' || numDoc == '33333333333333' || 
               numDoc == '44444444444444' || numDoc == '55555555555555' || numDoc == '66666666666666' || numDoc == '77777777777777' || 
               numDoc == '88888888888888' || numDoc == '99999999999999')
            {
                return true;
            } else {
                return false;  
            }             
        } else { 
            return false; 
        }
    }
    
    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    método para retornar apenas números
    **********************************************************************************************************************************/
    public static String getNumbersOnly(String varString)
    {
        Pattern varPattern = Pattern.compile('[^0-9]');
        String formattedString = varPattern.matcher(varString).replaceAll('');
        return formattedString;
    }
    
    /**********************************************************************************************************************************
    * VERSION     AUTHOR                  DATE            DETAIL      Description
    * 1.0         Thales Yumiya           28/09/21                    verifica se o documento é válido
    **********************************************************************************************************************************/
    public static Boolean isValidDocumentNumber(String documentNumber)
    {
        String formattedDocument = getNumbersOnly(documentNumber); 

        if(formattedDocument.isNumeric())        
        {           
            if(formattedDocument.length() == 11)
            {               
                return Util.isValidCPF(formattedDocument);
            } else
                if(formattedDocument.length() == 14)
                {
                    return Util.isValidCNPJ(formattedDocument);
                } else
                {
                    return false;
                }
        }else
        {
            return false;
        }
    }

    /*****************************************************************************************************************************
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya 	    23/12/2021 			Created 		Retorna o nome do sObject a partir do record id                                                                        
	*****************************************************************************************************************************/    
    public static String getSObjectNameById(Id recordId)
    {
        return recordId.getSObjectType().getDescribe().getName();
    }   
}