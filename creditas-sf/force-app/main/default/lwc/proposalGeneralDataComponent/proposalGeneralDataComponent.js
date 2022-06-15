import ProposalBaseComponent from 'c/proposalBaseComponent'
import getBiometry from '@salesforce/apex/GeneralDataController.getBiometry'
export default class ProposalGeneralDataComponent extends ProposalBaseComponent {
    
    constructor(){
        super();
        this.uniquekey='general-section'
        this.fields = [{
            'Label' : 'Analise Biometria Facial',
            'SObject' : 'GeneralSection__c',
            'StatusField' : 'FacialBiometricAnalysisStatus__c',
            'ApiFieldName' : 'FacialBiometricAnalysis__c',
        },{
            'Label' : 'Biometria',
            'SObject' : 'GeneralSection__c',
            'ApiFieldName' : 'Biometric__c',
            'StatusField' : 'BiometricStatus__c',
            'ObservationField' : 'BiometricObservation__c',
            'PendingStatus' : {
                'Label' : 'Motivo de falha da Biometria',
                'SObject' : 'GeneralSection__c',
                'ApiFieldName' : 'BiometricPendingReason__c',
                'actions' : ['EDIT', 'APPROVE', 'PENDING', 'REJECT']
            },
            'RejectStatus' : {
                'Label' : 'Motivo de falha da Biometria',
                'SObject' : 'GeneralSection__c',
                'ApiFieldName' : 'BiometricRejectReason__c',
            },
            'actions' : ['APPROVE', 'PENDING', 'REJECT']
        },{
            'Label' : 'Motivo de falha da Biometria',
            'SObject' : 'GeneralSection__c',
            'ApiFieldName' : 'BiometricFailReason__c',
            'actions' : ['EDIT', 'NO_VALIDATION']
        },{
            'Label' : 'Consultas na Crivo',
            'SObject' : 'GeneralSection__c',
            'ApiFieldName' : 'CrivoQuery__c',
            'StatusField' : 'CrivoQueryStatus__c',
            'required' : true,
            'actions' : ['EDIT', 'NO_VALIDATION']
        }];
        this.apiCount = this.fields.length;
    }
    
    biometryValidation = (event) => {
        console.log('opportunity id: ' + this.parentid);
        getBiometry({opportunityid : this.parentid, sectionId : this.sectionId}).then( (event) => {
            let result = JSON.parse(event);
            this.sectionId = result.GeneralSection__c.Id;
            this.setRecord(result, true);
            console.log(result);
            console.log('sectionId' + this.sectionId );
            this.pushHistory(this.shaddowObject);
            this.recalculateProgress();
        });
    }
    
}