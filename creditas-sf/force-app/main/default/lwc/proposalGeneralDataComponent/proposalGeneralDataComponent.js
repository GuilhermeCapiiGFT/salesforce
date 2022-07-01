import ProposalBaseComponent from 'c/proposalBaseComponent'
import getBiometry from '@salesforce/apex/GeneralDataController.updateCrivoQuery'
import updateCrivoQuery from '@salesforce/apex/GeneralDataController.updateCrivoQuery'
export default class ProposalGeneralDataComponent extends ProposalBaseComponent {
    
    constructor(){
        super();
        this.uniquekey='general-section'
        this.fields = [{
            'Label' : 'Biometria',
            'SObject' : 'GeneralSection__c',
            'ApiFieldName' : 'Biometric__c',
            'StatusField' : 'BiometricStatus__c',
            'ObservationField' : 'BiometricObservation__c',
            'hidden' : true,
            'PendingStatus' : {
                'Label' : 'Motivo de falha da Biometria',
                'SObject' : 'GeneralSection__c',
                'ApiFieldName' : 'BiometricPendingReason__c',
            },
            'RejectStatus' : {
                'Label' : 'Motivo de falha da Biometria',
                'SObject' : 'GeneralSection__c',
                'ApiFieldName' : 'BiometricRejectReason__c',
            },
            'actions' : ['APPROVE', 'PENDING', 'REJECT']
        },{
            'Label' : 'Consultas na Crivo',
            'SObject' : 'GeneralSection__c',
            'ApiFieldName' : 'CrivoQuery__c',
            'StatusField' : 'CrivoQueryStatus__c',
            'actions' : ['READONLY', 'NO_VALIDATION']
        }];
        this.apiCount = this.fields.length;
    }
    
    biometryValidation = (event) => {
        getBiometry({opportunityid : this.parentid, sectionId : this.sectionId}).then( (event) => {
            let result = JSON.parse(event);
            this.sectionId = result.GeneralSection__c.Id;
            this.setRecord(result, true);
            this.pushHistory(this.currentState);
            this.recalculateProgress();
        });
    }
    getCrivoQuery = (event) => {
        updateCrivoQuery({opportunityid : this.parentid, sectionId : this.sectionId}).then( (event) => {
            let result = JSON.parse(event);
            this.reload();
        });
    }
    
}