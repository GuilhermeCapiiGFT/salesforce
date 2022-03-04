public without sharing class AddressesTriggerController extends TriggerHandler{

    private List<Addresses__c> lstNewAddresses;
    private List<Addresses__c> lstOldAddresses;
    private Map<Id, Addresses__c> mapNewAddresses;
    private Map<Id, Addresses__c> mapOldAddresses;    

    public AddressesTriggerController()
    {
        this.lstNewAddresses = (List<Addresses__c>) Trigger.new;
        this.lstOldAddresses = (List<Addresses__c>) Trigger.old;
        this.mapNewAddresses = (Map<Id, Addresses__c>) Trigger.newMap;
        this.mapOldAddresses = (Map<Id, Addresses__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert()
    {
        AddressesTriggerService.updateAccountExternalFields(lstNewAddresses);
    }
    
    public override void afterInsert() {}
    
    public override void beforeUpdate()
    {
        AddressesTriggerService.updateMethod(lstNewAddresses, mapOldAddresses);
        AddressesTriggerService.updateAccountExternalFields(lstNewAddresses);
    }
    
    public override void afterUpdate() {}

}
