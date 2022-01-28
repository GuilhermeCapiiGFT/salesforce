public class TaskDetailsVO {
    @AuraEnabled public String  Id;
    @AuraEnabled public String  fieldKey;
    @AuraEnabled public String  fieldName;
    @AuraEnabled public String  fieldValue;
    @AuraEnabled public String  fieldType;
    @AuraEnabled public String  fieldMask;
    @AuraEnabled public Boolean isCurrency = false;
    @AuraEnabled public Boolean isRelationship = false;
    @AuraEnabled public Boolean isMultiPicklist = false;
    @AuraEnabled public Boolean isPicklist = false;
    @AuraEnabled public Boolean isCheckbox = false;
    @AuraEnabled public Boolean isCheckboxGroup = false;
    @AuraEnabled public Boolean isRadioGroup = false;
    @AuraEnabled public Boolean isDefault = false;
    @AuraEnabled public Boolean isHeader = false;
    @AuraEnabled public Boolean isNumber = false;
    @AuraEnabled public String  fieldMappedKey;
    @AuraEnabled public String  relatedObject;
    @AuraEnabled public String  picklistValues;
    @AuraEnabled public String  checkboxGroupValues;
    @AuraEnabled public String  radioGroupValues;
    @AuraEnabled public String  numberPrecision;
    @AuraEnabled public Boolean  isReadOnly;
    @AuraEnabled public Boolean  isRequeried;
}