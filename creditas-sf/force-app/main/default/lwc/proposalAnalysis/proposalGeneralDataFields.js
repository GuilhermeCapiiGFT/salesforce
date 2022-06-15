export const GENERAL_DATA_FIELD = [{
    'Label' : 'Analise Biometria Facial',
    'SObject' : 'GeneralSection__c',
    'StatusField' : 'FacialBiometricAnalysisStatus__c',
    'ApiFieldName' : 'FacialBiometricAnalysis__c'
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
    'ApiFieldName' : 'BiometricFailReason__c'
},{
    'Label' : 'Consultas na Crivo',
    'SObject' : 'GeneralSection__c',
    'ApiFieldName' : 'CrivoQuery__c',
    'StatusField' : 'CrivoQueryStatus__c',
    'required' : true,
    'actions' : ['EDIT', 'APPROVE', 'PENDING', 'REJECT']
}];