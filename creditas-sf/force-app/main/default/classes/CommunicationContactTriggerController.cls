public with sharing class CommunicationContactTriggerController extends TriggerHandler{
    private List<CommunicationContacts__c> lstNewCommunicationContact;
    private List<CommunicationContacts__c> lstOldCommunicationContact;
    private Map<Id, CommunicationContacts__c> mapNewCommunicationContact;
    private Map<Id, CommunicationContacts__c> mapOldCommunicationContact;
    
    public CommunicationContactTriggerController()
    {
        this.lstNewCommunicationContact = (List<CommunicationContacts__c>) Trigger.new;
        this.lstOldCommunicationContact = (List<CommunicationContacts__c>) Trigger.old;
        this.mapNewCommunicationContact = (Map<Id, CommunicationContacts__c>) Trigger.newMap;
        this.mapOldCommunicationContact = (Map<Id, CommunicationContacts__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert()
    {
        CommunicationContactTriggerService.updateAccountExternalFields(lstNewCommunicationContact);
    }
    
    public override void afterInsert() {}
    
    public override void beforeUpdate()
    {
        CommunicationContactTriggerService.updateIsExternallySynced(lstNewCommunicationContact, mapOldCommunicationContact);
        CommunicationContactTriggerService.updateAccountExternalFields(lstNewCommunicationContact);
    }
    
    public override void afterUpdate() {}

}