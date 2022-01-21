public with sharing class TriggerHelper {

	private static void assert(sObject aObject, String aField)
	{
		if(!Trigger.isExecuting){
			throw new TriggerHelperException('This method must be called only in trigger context.');
		}
		if(aObject == null){
			throw new TriggerHelperException('This method requires a valid sObject');
		}
		if(String.isBlank( aField )){
			throw new TriggerHelperException('This method requires a Field to compare.');
			
		}
	}

	private static void assert(sObject aObject, List<String> aFields)
	{
		if(!Trigger.isExecuting){
			throw new TriggerHelperException('This method must be called only in trigger context.');
		}
		if(aObject == null){
			throw new TriggerHelperException('This method requires a valid sObject');
		}
		if(aFields.isEmpty() && aFields == null){
			throw new TriggerHelperException('This method requires a Field to compare.');
			
		}
	}

	/* 
		Método para retornar se o campo aField foi alterado 
		aObject => Objeto de Comparação (Trigger.New)
		aField => Campo de Comparação (API)
	*/
	public static Boolean changedField(sObject aObject, String aField)
	{
		assert(aObject, aField);
		Object lOldObject = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(aField) : null;
		return ((Trigger.isInsert && aObject.get(aField) != null) || aObject.get(aField) != lOldObject);
	}
    
    /*
		Método para retornar se algum dos campos em aFields foi alterado
		aObject => Objeto de Comparação (Trigger.New)
		aFields => Lista de Campos de Comparação (API)
	*/
	public static Boolean changedField(sObject aObject, List<String> aFields)
	{
		assert(aObject, aFields);
		for (String iField : aFields)
		{	
			Object lOldObject = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(iField) : null;
			if ((Trigger.isInsert && aObject.get(iField) != null) || (aObject.get(iField) != lOldObject))
			{ return true; }
		}
		return false;
	}

	/* 
		Método para retornar se o campo aField não foi alterado 
		aObject => Objeto de Comparação (Trigger.New)
		aField => Campo de Comparação (API)
	*/
	public static Boolean notChangedField(sObject aObject, String aField)
	{
		assert(aObject, aField);
		Object lOldObject = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(aField) : null;
		return ((Trigger.isInsert && aObject.get(aField) == null) || aObject.get(aField) == lOldObject);
	}
    
  	/*
		Método para retornar se nenhum dos campos em aFields foi alterado
		aObject => Objeto de Comparação (Trigger.New)
		aFields => Lista de Campos de Comparação (API)
	*/
	public static Boolean notChangedField(sObject aObject, List<String> aFields)
	{
		assert(aObject, aFields);
		for (String iField : aFields)
		{
			Object lOldObject = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(iField) : null;
			if ((Trigger.isInsert && aObject.get(iField) == null) || (aObject.get(iField) == lOldObject))
			{ return true; }
		}
		return false;
	}

	/* 
		Método para retornar se determinado campo foi alterado para o valor esperado 
		aObject => Objeto de Comparação (Trigger.New)
		aField => Campo de Comparação (API)
		aValue => Valor novo esperado no campo especificado
	*/
	public static Boolean changedToExpectedValue(sObject aObject, String aField, Object aValue)
	{	
		assert(aObject, aField);
		Object cValue = aObject.get(aField);
		Object cOldValue = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(aField) : null;
		return (Trigger.isInsert && cValue != null) || (cValue != cOldValue && cValue == aValue); 
	}

	/* 
		Método para retornar se determinado campo foi alterado do valor esperado 
		aObject => Objeto de Comparação (Trigger.New)
		aField => Campo de Comparação (API)
		aValue => Valor antigo esperado no campo especificado
	*/
	public static Boolean changedFrom(sObject aObject, String aField, Object aValue)
	{	
		assert(aObject, aField);
		if ((Trigger.isInsert ||Trigger.isUpdate) && aValue == null) { return true; } //aValue = null significa que o valor era nulo (criação)
		Object cOldValue = (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(aField) : null;
		return (aObject.get(aField) != cOldValue && cOldValue == aValue); 
	}

	/* 
		Método para retornar se determinado campo foi alterado do valor esperado para valor esperado 
		aObject => Objeto de Comparação (Trigger.New)
		aField => Campo de Comparação (API)
		aOldValue => Valor antigo esperado no campo especificado
		aNewValue => Valor novo esperado no campo especificado
	*/
	public static Boolean changedFromTo(sObject aObject, String aField, Object aOldValue, Object aNewValue)
	{	
		assert(aObject, aField);
		Object cOldValue =  (Trigger.isUpdate) ? Trigger.oldMap.get(aObject.Id).get(aField) : null, cNewValue = aObject.get(aField);
		return (cOldValue != cNewValue && cOldValue == aOldValue && cNewValue == aNewValue); 
	}

}