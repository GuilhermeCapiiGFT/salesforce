public without sharing class DocumentsTriggerController extends TriggerHandler
{
    private List<Documents__c> lstNewDocuments;
    private List<Documents__c> lstOldDocuments;
    private Map<Id, Documents__c> mapNewDocuments;
    private Map<Id, Documents__c> mapOldDocuments;
    
    public DocumentsTriggerController()
    {
        this.lstNewDocuments = (List<Documents__c>) Trigger.new;
        this.lstOldDocuments = (List<Documents__c>) Trigger.old;
        this.mapNewDocuments = (Map<Id, Documents__c>) Trigger.newMap;
        this.mapOldDocuments = (Map<Id, Documents__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert(){
        DocumentsTriggerService.updateAccountExternalFields(lstNewDocuments);
    }
    
    public override void afterInsert(){
    }
    
    public override void beforeUpdate()
    {
        DocumentsTriggerService.updateAccountExternalFields(lstNewDocuments);
        DocumentsTriggerService.updateIsExternallySynced(lstNewDocuments, mapOldDocuments);
    }
    
    public override void afterUpdate(){
        
    }
}