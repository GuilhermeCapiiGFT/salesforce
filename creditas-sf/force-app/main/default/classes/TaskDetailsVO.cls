public class TaskDetailsVO {
    @AuraEnabled public String  Id;
    @AuraEnabled public String  fieldKey;
    @AuraEnabled public String  fieldName;
    @AuraEnabled public String  fieldValue;
    @AuraEnabled public String  fieldType;
    @AuraEnabled public Boolean isCurrency = false;
    @AuraEnabled public Boolean isRelationShip = false;
    @AuraEnabled public Boolean isMultiPicklist = false;
    @AuraEnabled public Boolean isPicklist = false;
    @AuraEnabled public Boolean isDefault = false;
    @AuraEnabled public String  fieldMappedKey;
    @AuraEnabled public String  relatedObject;
   // @AuraEnabled public List<multPicklistValues> ListmultPicklistValues {get;set;}
    //@AuraEnabled public List<PicklistDetailVO> listPicklistValues;
    @AuraEnabled public String picklistValues;

    public class multPicklistValues {
        public String label;
        public String value;
    }
}