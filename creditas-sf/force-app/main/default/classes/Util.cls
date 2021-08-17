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
	 * Purpose: Método de auxílio para a obtenção do RecordTypeId através do nome.
	 * Parameters: String objectName, String strRecordTypeName
	 * Returns: RecordTypeId
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya 	    11/08/2021 			Created 		Retorna o RecordTypeId correspondente ao
     *                                                                          RecordTypeName 
	*****************************************************************************************************************************/    
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName)
    {
    	return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(strRecordTypeName).getRecordTypeId();
    }        
    
    /*****************************************************************************************************************************
	 * Purpose: Método de auxílio para obtenção do  RecordTypeName através do Id.
	 * Parameters: String objectName, Id strRecordTypeId
	 * Returns: RecordTypeName
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya 	    11/08/2021 			Created 		Retorna o RecordTypeName correspondente ao
     *                                                                          RecordTypeId 
	*****************************************************************************************************************************/    
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }   
            
    /*****************************************************************************************************************************
	 * Purpose: Método de auxílio para cálculo de tempo decorrido entre dois intervalos.
	 * Parameters: Time startTime, Time endTime
	 * Returns: Time
	 * Throws -
	 * 
	 * History
	 * --------
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
	 * Purpose: Método de auxílio para cálculo de tempo decorrido entre dois intervalos em segundos.
	 * Parameters: Time startTime, Time endTime
	 * Returns: Integer
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                11/08/2021 		Created 	Chama Utils.GetElapsedTime; retorna tempo
     *                                                                          decorrido entre startTime e endTime em
     *                                                                          segundos.
	*****************************************************************************************************************************/
    public static Integer getSecondsElapsed(Time startTime, Time endTime) {
        return GetElapsedTime(startTime, endTime).second();
    }
    
    /*****************************************************************************************************************************
	 * Purpose: Atualização de associação de contas a territórios
	 * Parameters: String, Account
	 * Returns: Account
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                11/08/2021 		Created 	Adiciona o território territoryName de
     *                                                                          Account__r.Territorios__c e retorna a
     *                                                                          conta.
	*****************************************************************************************************************************/
    // public static void addTerritoryToAccountField(String territoryName, Account account) {

    //     try{

    //         List<String> accountTerritories = new List<String>();

    //         if(String.isNotBlank(account.Territorios__c)) {
    //             accountTerritories.addAll(account.Territorios__c.split('\\|'));
    //         }
            
    //         if(!accountTerritories.contains(territoryName)) {
    //             accountTerritories.add(territoryName);
    //         }
            
    //         account.Territorios__c = '';
    //         for(Integer i = 0; i < accountTerritories.size(); ++i) {
    //             if(i == accountTerritories.size() - 1) {
    //                 account.Territorios__c += accountTerritories.get(i);
    //             } else {
    //                 account.Territorios__c += accountTerritories.get(i) + '|';
    //             }
    //         }

    //     } catch(QueryException e) {
    //         System.debug(e.getMessage());
    //         System.debug(e.getStackTraceString());
    //     }
        
    // }
    
    /*****************************************************************************************************************************
	 * Purpose: Atualização de associação de contas a territórios
	 * Parameters: String, Account
	 * Returns: Account
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION 		AUTHOR 							DATE 			DETAIL 		Description
	 * 1.0 			Thales Yumiya 	                31/07/2021 		Created 	Remove o território territoryName de
     *                                                                          Account__r.Territorios__c e retorna a
     *                                                                          conta.
	*****************************************************************************************************************************/
    // public static void removeTerritoryToAccountField(String territoryName, Account account) {
        
    //     try {

    //         List<String> accountTerritories = new List<String>();

    //         if(String.isNotEmpty(account.Territorios__c)) {
    //             accountTerritories.addAll(account.Territorios__c.split('\\|'));
    //         }
        
    //         while(accountTerritories.contains(territoryName)) {
    //             accountTerritories.remove(accountTerritories.indexOf(territoryName));
    //         }
            
    //         account.Territorios__c = '';
    //         for(Integer i = 0; i < accountTerritories.size(); ++i) {
    //             if(i == accountTerritories.size() - 1) {
    //                 account.Territorios__c += accountTerritories.get(i);
    //             } else {
    //                 account.Territorios__c += accountTerritories.get(i) + '|';
    //             }
    //         }
            
    //     } catch(QueryException e) {
    //         System.debug(e.getMessage());
    //         System.debug(e.getStackTraceString());
    //     }

    // }
    
    /*****************************************************************************************************************************
	 * Purpose: Obtem valores de picklist por apIObjeto e apiCampo
	 * Parameters: String ObjectApi_name, String Field_name
	 * Returns: List<String>
	 * Throws -
	 * 
	 * History
	 * --------
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
	 * Purpose: Gerar string randomica. 
	 * Parameters: strLength (Integer)
	 * Returns: string
	 * Throws -
	 * 
	 * History
	 * --------
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
     * Purpose: Obter todos os campos do objeto informado pelo nome
     * Parameters: String varSObjectName
     * Returns: String
     * Throws -
     * 
     * History
     * --------
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    public static List<String> selectAllFields(String varSObjectName)
    {
        return selectAllFields(varSObjectName, null);
    }
    
    /*****************************************************************************************************************************
     * Purpose: Obter todos os campos do objeto informado pelo ID
     * Parameters: Id varSObjectId
     * Returns: String
     * Throws -
     * 
     * History
     * --------
     * VERSION      AUTHOR          DATE            DETAIL      Description
     * 1.0          Thales Yumiya   11/08/2021      Created     Obtém todos os campos do objeto informado
     *****************************************************************************************************************************/
    public static List<String> selectAllFields(Id varSObjectId)
    {
        return selectAllFields(null, varSObjectId);
    }
    
    /*****************************************************************************************************************************
	 * Purpose: Método de auxílio para a obtenção de todos os RecordTypeId através de um objeto específico.
	 * Parameters: String objectName, String strRecordTypeName
	 * Returns:  Map<Id, Schema.RecordTypeInfo>
	 * Throws -
	 * 
	 * History
	 * --------
	 * VERSION			AUTHOR				DATE				DETAIL 			Description
	 * 1.0 				Thales Yumiya    	11/08/2021 			Created 		Retorna do Map com os RecordTypeIds do Objeto
	*****************************************************************************************************************************/    
    public static Map<Id, Schema.RecordTypeInfo> getRecordTypesBySObject(String objectName)
    {
        Map<Id, Schema.RecordTypeInfo> mapRecTypeSObject = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById();
    	return mapRecTypeSObject;
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
     * Purpose: Buscar o mapeamento de campos do custom metadata type
     * Parameters: String varObjetoOrigem, String varObjetoDestino
     * Returns: Map<String, String>
     * Throws -
     * 
     * History
     * --------
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
    * Purpose: 
    * Parameters: Datetime
    * Returns: void
    * Throws -
    * 
    * History
    * --------
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
}