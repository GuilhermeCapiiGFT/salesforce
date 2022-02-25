public with sharing class PicklistUtils {

    private static List<Schema.PicklistEntry> getPickListValuesList(String objApiName, String fieldApiName){
                
        return Schema.getGlobalDescribe().get(objApiName)?.getDescribe().fields.getMap().get(fieldApiName)?.getDescribe()?.getPicklistValues();
    }  

    public static List<PicklistWrapper> getPickListValuesWrapped(String objApiName, String fieldApiName){
            
            List<pickListWrapper> picklist = new List<pickListWrapper>();

            if(getPickListValuesList(objApiName,fieldApiName) == null){ return picklist; }
            
            for(Schema.PicklistEntry picklistEntry : getPickListValuesList(objApiName,fieldApiName)){
    
                picklist.add(new pickListWrapper((String) picklistEntry.getLabel(), (String) picklistEntry.getValue()));
            }
            return picklist;
    }

    public class PicklistWrapper{
        public String label;
        public String value;
        public PicklistWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}