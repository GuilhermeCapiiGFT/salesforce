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
    public static Map<String, String> getPickListValuesByAPIName(String objApiName, String fieldApiName){
        List<Schema.PicklistEntry> picklistEntries = getPickListValuesList(objApiName,fieldApiName);
        if( picklistEntries == null ) { return null; }
        Map<String, String> entriesByApiName = new Map<String, String>();
        for(Schema.PicklistEntry picklistEntry : getPickListValuesList(objApiName,fieldApiName)){
            entriesByApiName.put((String) picklistEntry.getValue(), (String) picklistEntry.getLabel());
        }
        return entriesByApiName;
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