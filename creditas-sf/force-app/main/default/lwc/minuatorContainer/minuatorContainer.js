import { LightningElement } from 'lwc';

export default class MinuatorContainer extends LightningElement {

    data;

    connectedCallback() {

       let payload = 
		'{ '+ 
		'   "id": "3a808db8-3898-11eb-af30-77acf07e4bfa",'+
		'   "applicationId": "3a808db8-3898-11eb-af30-77acf07e4bfa",'+
		'   "persons": [ ' +
		'       { '+ 
		'           "sources": { '+ 
		'               "name": "MDO",'+
		'               "gender": null, '+
		'               "nationality": "MDO",'+
		'               "cellPhone": "MDO",'+
		'               "birthdate": "MDO",'+
		'               "email": "MDO",'+
		'               "profession": "MDO",'+
		'               "fatherName": "MDO",'+
		'               "motherName": "MDO",'+
		'               "composeIncome": "Analisador",'+
		'               "isPropertyOwner": "Analisador" '+
		'           }, '+
		'           "validation": { '+ 
		'               "isValidated": false, '+
		'               "validatedAt": null, '+
		'               "validatorEmail": null '+
		'          }, '+
		'           "pendingValidation": [], '+
		'           "name": "ANNA CARLA GONÇALVES",'+
		'           "composeIncome": true, '+
		'           "maritalStatus": "DIVORCED",'+
		'           "mainDocument": { '+ 
		'               "sources": { '+ 
		'                   "number": "MDO" '+
		'               }, '+
		'               "validation": { '+ 
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "04243545782",'+
		'               "type": "CPF",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": null '+
		'           }, '+
		'           "gender": "FEMALE", '+
		'           "cellPhone": "21981073069",'+ 
		'           "birthdate": "1974-10-03",'+
		'           "nationality": "brasileira",'+
		'           "email": "konig_1@hotmail.com",'+
		'           "profession": "Assistente Social",'+
		'           "fatherName": "CARLOS GONÇALVES FILHO",'+
		'           "motherName": "MERY LUCY FRANCISCO GONÇALVES",'+
		'           "identityDocument": { '+ 
		'               "sources": { '+ 
		'                   "type": "MDO",'+
		'                   "number": "MDO",'+
		'                   "expeditionDate": null, '+
		'                   "issuingBody": "MDO" '+
		'               }, '+
		'               "validation": { '+  
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "10.136.068-3",'+
		'               "type": "RG",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": "DETRAN/RJ" '+
		'           }, '+
		'           "propertyOwner": false, '+
		'           "consentingParticipant": null '+
		'       }, '+ 
		'       { '+ 
		'           "sources": { '+ 
		'               "name": "MDO",'+
		'               "gender": null, '+
		'               "nationality": "MDO",'+
		'               "cellPhone": "MDO",'+
		'               "birthdate": "MDO",'+
		'               "email": "MDO",'+
		'               "profession": "MDO",'+
		'               "fatherName": "MDO",'+
		'               "motherName": "MDO",'+
		'               "composeIncome": "Analisador",'+
		'               "isPropertyOwner": "Analisador" '+
		'           }, '+
		'           "validation": { '+ 
		'               "isValidated": false, '+
		'               "validatedAt": null, '+
		'               "validatorEmail": null '+
		'           }, '+
		'           "pendingValidation": [], '+
		'           "name": "ANDRÉ BOECHAT KÖNIG",'+
		'           "composeIncome": true, '+
		'           "maritalStatus": "SINGLE",'+
		'           "mainDocument": { '+ 
		'               "sources": { '+ 
		'                   "number": "MDO" '+
		'               }, '+
		'               "validation": { '+ 
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "09370233709",'+
		'               "type": "CPF",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": null '+
		'           }, '+
		'           "gender": "MALE", '+
		'           "cellPhone": "21981073069",'+
		'           "birthdate": "1982-01-11",'+
		'           "nationality": "brasileiro",'+
		'           "email": "konig_1@hotmail.com",'+
		'           "profession": "Advogado",'+
		'           "fatherName": "EDUARDO JOSÉ COSTA KÖNIG DA SILVA",'+
		'           "motherName": "VÂNIA MARIA BOECHAT KÖNIG",'+
		'           "identityDocument": { '+ 
		'               "sources": { '+ 
		'                   "type": "MDO",'+
		'                   "number": "MDO",'+
		'                   "expeditionDate": null, '+
		'                   "issuingBody": "MDO" '+
		'               }, '+
		'               "validation": { '+ 
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "155591",'+
		'               "type": "RG",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": "OAB/RJ" '+
		'           }, '+
		'           "propertyOwner": true, '+
		'           "consentingParticipant": null '+
		'       }, '+	
		'       { '+ 	
		'           "sources": { '+ 
		'               "name": "MDO",'+
		'               "gender": null, '+
		'               "nationality": "MDO",'+
		'               "cellPhone": "MDO",'+
		'               "birthdate": "MDO",'+
		'               "email": "MDO",'+
		'               "profession": "MDO",'+
		'               "fatherName": "MDO",'+
		'               "motherName": "MDO",'+
		'               "composeIncome": "Analisador",'+
		'               "isPropertyOwner": "Analisador" '+
		'           }, '+
		'           "validation": { '+ 
		'               "isValidated": false, '+
		'               "validatedAt": null, '+
		'               "validatorEmail": null '+
		'          }, '+
		'           "pendingValidation": [], '+
		'           "name": "BIANCA GONÇALVES",'+
		'           "composeIncome": true, '+
		'           "maritalStatus": "DIVORCED",'+
		'           "mainDocument": { '+ 
		'               "sources": { '+ 
		'                   "number": "MDO" '+
		'               }, '+
		'               "validation": { '+ 
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "50043545782",'+
		'               "type": "CPF",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": null '+
		'           }, '+
		'           "gender": "FEMALE", '+
		'           "cellPhone": "21981073069",'+ 
		'           "birthdate": "1974-25-03",'+
		'           "nationality": "brasileira",'+
		'           "email": "konig_1@hotmail.com",'+
		'           "profession": "Assistente Social",'+
		'           "fatherName": "CARLOS GONÇALVES FILHO",'+
		'           "motherName": "MERY LUCY FRANCISCO GONÇALVES",'+
		'           "identityDocument": { '+ 
		'               "sources": { '+ 
		'                   "type": "MDO",'+
		'                   "number": "MDO",'+
		'                   "expeditionDate": null, '+
		'                   "issuingBody": "MDO" '+
		'               }, '+
		'               "validation": { '+  
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "10.136.068-3",'+
		'               "type": "RG",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": "DETRAN/RJ" '+
		'           }, '+
		'           "propertyOwner": false, '+
		'           "consentingParticipant": null '+
		'       }, '+
		'        { '+  
		'           "sources": { '+ 
		'               "name": "MDO",'+
		'               "gender": null, '+
		'               "nationality": "MDO",'+
		'               "cellPhone": "MDO",'+
		'               "birthdate": "MDO",'+
		'               "email": "MDO",'+
		'               "profession": "MDO",'+
		'               "fatherName": "MDO",'+
		'               "motherName": "MDO",'+
		'               "composeIncome": "Analisador",'+
		'               "isPropertyOwner": "Analisador" '+
		'           }, '+
		'           "validation": { '+ 
		'               "isValidated": false, '+
		'               "validatedAt": null, '+
		'               "validatorEmail": null '+
		'          }, '+
		'           "pendingValidation": [], '+
		'           "name": "HEITOR SILVA",'+
		'           "composeIncome": true, '+
		'           "maritalStatus": "DIVORCED",'+
		'           "mainDocument": { '+ 
		'               "sources": { '+ 
		'                   "number": "MDO" '+
		'               }, '+
		'               "validation": { '+ 
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "77743545782",'+
		'               "type": "CPF",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": null '+
		'           }, '+
		'           "gender": "MALE", '+
		'           "cellPhone": "21981073069",'+ 
		'           "birthdate": "1974-25-03",'+
		'           "nationality": "brasileira",'+
		'           "email": "konig_1@hotmail.com",'+
		'           "profession": "Assistente Social",'+
		'           "fatherName": "CARLOS GONÇALVES FILHO",'+
		'           "motherName": "MERY LUCY FRANCISCO GONÇALVES",'+
		'           "identityDocument": { '+ 
		'               "sources": { '+ 
		'                   "type": "MDO",'+
		'                   "number": "MDO",'+
		'                   "expeditionDate": null, '+
		'                   "issuingBody": "MDO" '+
		'               }, '+
		'               "validation": { '+  
		'                   "isValidated": false, '+
		'                   "validatedAt": null, '+
		'                   "validatorEmail": null '+
		'               }, '+
		'               "number": "10.136.068-3",'+
		'               "type": "RG",'+
		'               "expeditionDate": null, '+
		'               "issuingBody": "DETRAN/RJ" '+
		'           }, '+
		'           "propertyOwner": false, '+
		'           "consentingParticipant": null '+
		'       } '+ 
		'   ], '+
		'   "marriages": [ '+
		'       { '+ 
		'           "regimen": null, '+
		'           "marriageDate": null, '+
		'           "compulsorySeparation": null, '+
		'           "weddingCertificate": null, '+
		'           "prenuptialAgreementData": null,'+
		'           "hasPrenuptialAgreement": null, '+
		'           "maritalStatus": "MARRIAGE",'+
		'           "participant1Cpf": "04243545782",'+
		'           "participant2Cpf": "09370233709" '+
		'       }, '+
		'       { '+ 
		'           "regimen": null, '+
		'           "marriageDate": null, '+
		'           "compulsorySeparation": null, '+
		'           "weddingCertificate": null, '+
		'           "prenuptialAgreementData": null,'+
		'           "hasPrenuptialAgreement": null, '+
		'           "maritalStatus": "STABLE_UNION",'+
		'           "participant1Cpf": "50043545782",'+
		'           "participant2Cpf": "77743545782" '+
		'       } '+
		'   ], '+
		'   "lastUpdated": "2022-03-28T20:24:25",'+
		'   "providerContractId": "3a808db8-3898-11eb-af30-77acf07e4bfa1648499069345",'+
		'   "cciNumber": null, '+ 
		'   "cciSeries": null, '+
		'   "creditor": null, '+
		'   "underwriter": null '+
		' } ';

        this.data = JSON.parse( payload);
    }
}