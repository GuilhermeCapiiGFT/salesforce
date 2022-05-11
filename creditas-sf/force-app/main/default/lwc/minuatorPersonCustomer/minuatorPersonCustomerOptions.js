/**
 * @author Nathalia Rosa - GFT Brasil
 */

export const participationOptions = [
    { label: 'Proprietário', value: 'owner' },
    { label: 'Compõe renda', value: 'incomeCompose' },
    { label: 'Anuente', value: 'consenting' }
];

export const genderOptions = [
    { label: 'Masculino', value: 'MALE' },
    { label: 'Feminino', value: 'FEMALE' }
];

export const documentTypeOptions = [
    { label: 'RG - Registro Geral', value: 'RG' },
    { label: 'CNH - Carteira Nacional de Habilitação', value: 'CNH' },
    { label: 'RNE - Registro Nacional de Estrangeiros', value: 'RNE	' },
    { label: 'Documento de Classe', value: 'CLASSDOCUMENT' }
];

export const relationshipDic = new Map([
    ['MARRIED','Casado'],
    ['SINGLE','Solteiro'],
    ['DIVORCED','Divorciado'],
    ['SEPARATED','Separado'],
    ['WIDOWER','Viúvo']
]);