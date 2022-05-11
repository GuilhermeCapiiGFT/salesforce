/**
 * @author Nathalia Rosa - GFT Brasil
 */

export const regimeOptions = [
    { label: 'Comunhao parcial de bens', value: 'PARTIAL_COMMUNION' },
    { label: 'Comunhão universal de bens', value: 'UNIVERSAL_COMMUNION' },
    { label: 'Separação total de bens', value: 'TOTAL_SEPARATION' },
    { label: 'Participação final nos aquestos', value: 'PARTNERSHIP_OF_ACQUESTS'}	
];

export const typeOptions = [
    { label: 'Livro e folha', value: 'BOOK_DETAILS' },
    { label: 'Matrícula', value: 'REGISTRATION' }
];

/**
 * @description The suffix 77 means the law before the 1977' years
 */
export const enableOrDisableByRegimes = new Map([


    ['PARTIAL_COMMUNION_ENABLE_77',['showCertidaoToggle','showPactoAntenupcialToggle']],

    ['PARTIAL_COMMUNION_DISABLE_77',['showSeparacaoToggle','showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showPactoAntenupcialSeparacao', 'showRegistroPacto',
                                    'showRegistroPactoSeparacao', 'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],
    
    ['PARTIAL_COMMUNION_ENABLE',['showCertidaoToggle']],

    ['PARTIAL_COMMUNION_DISABLE',['showPactoAntenupcialToggle','showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 
                                  'showPactoAntenupcialSeparacao', 'showRegistroPacto', 'showRegistroPactoSeparacao', 'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],

    ['TOTAL_SEPARATION_ENABLE_77', ['showCertidaoToggle', 'showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showPactoAntenupcialSeparacao', 'showAlertPactoSeparacao']],

    ['TOTAL_SEPARATION_DISABLE_77', ['showPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showRegistroPacto', 'showRegistroPactoSeparacao', 'showRegistroUniao', 'showSeparacao', 'showAlertPacto']],

    ['TOTAL_SEPARATION_ENABLE', ['showCertidaoToggle', 'showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showPactoAntenupcialSeparacao', 'showAlertPactoSeparacao']],

    ['TOTAL_SEPARATION_DISABLE', ['showPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showRegistroPacto', 'showRegistroPactoSeparacao', 'showRegistroUniao', 'showSeparacao', 'showAlertPacto']],
    
    ['UNIVERSAL_COMMUNION_ENABLE_77', ['showCertidaoToggle']],

    ['UNIVERSAL_COMMUNION_DISABLE_77', ['showPactoAntenupcialToggle', 'showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showPactoAntenupcialSeparacao',
                                        'showRegistroPacto', 'showRegistroPactoSeparacao', 'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],
    
    ['UNIVERSAL_COMMUNION_ENABLE', ['showCertidaoToggle', 'showPactoAntenupcialToggle']],

    ['UNIVERSAL_COMMUNION_DISABLE', ['showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showPactoAntenupcialSeparacao', 'showRegistroPacto', 'showRegistroPactoSeparacao',
                                     'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],

    ['PARTNERSHIP_OF_ACQUESTS_ENABLE_77', ['showCertidaoToggle', 'showPactoAntenupcialToggle']],

    ['PARTNERSHIP_OF_ACQUESTS_DISABLE_77', ['showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showPactoAntenupcialSeparacao', 'showRegistroPacto', 'showRegistroPactoSeparacao',
                                             'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],
    ['PARTNERSHIP_OF_ACQUESTS_ENABLE', ['showCertidaoToggle', 'showPactoAntenupcialToggle']],

    ['PARTNERSHIP_OF_ACQUESTS_DISABLE', ['showSeparacaoToggle', 'showSeparacaoPactoAntenupcialToggle', 'showCertidao', 'showPactoAntenupcial', 'showPactoAntenupcialSeparacao', 'showRegistroPacto', 'showRegistroPactoSeparacao',
                                             'showRegistroUniao', 'showSeparacao', 'showAlertPacto', 'showAlertPactoSeparacao']],
]);