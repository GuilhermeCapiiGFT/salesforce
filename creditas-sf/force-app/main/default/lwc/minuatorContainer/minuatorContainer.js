import { LightningElement } from 'lwc';

export default class MinuatorContainer extends LightningElement {

    data;
	dataEdited;

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
		'			"address": { '+
        '               "sources": { '+
        '                   "zipcode": "MDO", '+ 
        '                   "city": "MDO", '+
        '                   "state": "MDO", '+
        '                   "neighborhood": "MDO", '+
        '                   "street": "MDO", '+
        '                   "number": "MDO", '+
        '                   "complement": "MDO" '+
        '               }, '+
        '               "validation": { '+
        '                   "isValidated": false, '+
        '                   "validatedAt": null, '+
        '                   "validatorEmail": null '+
        '               }, '+
        '               "pendingValidation": [], '+
        '               "zipcode": "27660-971", '+
        '               "city": "Rio das Ostras", '+
        '               "state": "RJ", '+
        '               "neighborhood": "Formoso", '+
        '               "street": "Rua Doutor João Garcia da Fonseca", '+
        '               "number": "2209", '+
        '               "complement": "casa 1" '+
        '               }, '+
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
		'			"address": { '+
        '               "sources": { '+
        '                   "zipcode": "MDO", '+ 
        '                   "city": "MDO", '+
        '                   "state": "MDO", '+
        '                   "neighborhood": "MDO", '+
        '                   "street": "MDO", '+
        '                   "number": "MDO", '+
        '                   "complement": "MDO" '+
        '               }, '+
        '               "validation": { '+
        '                   "isValidated": false, '+
        '                   "validatedAt": null, '+
        '                   "validatorEmail": null '+
        '               }, '+
        '               "pendingValidation": [], '+
        '               "zipcode": "27660-971", '+
        '               "city": "Rio das Ostras", '+
        '               "state": "RJ", '+
        '               "neighborhood": "Formoso", '+
        '               "street": "Rua Doutor João Garcia da Fonseca", '+
        '               "number": "2209", '+
        '               "complement": "casa 1" '+
        '               }, '+
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
		'               "name": "Analisador",'+
		'               "gender": null, '+
		'               "nationality": "Analisador",'+
		'               "cellPhone": "Analisador",'+
		'               "birthdate": "Analisador",'+
		'               "email": "Analisador",'+
		'               "profession": "Analisador",'+
		'               "fatherName": "Analisador",'+
		'               "motherName": "Analisador",'+
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
		'                   "number": "Analisador" '+
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
		'			"address": { '+
        '               "sources": { '+
        '                   "zipcode": "Analisador", '+ 
        '                   "city": "Analisador", '+
        '                   "state": "Analisador", '+
        '                   "neighborhood": "Analisador", '+
        '                   "street": "Analisador", '+
        '                   "number": "Analisador", '+
        '                   "complement": "Analisador" '+
        '               }, '+
        '               "validation": { '+
        '                   "isValidated": false, '+
        '                   "validatedAt": null, '+
        '                   "validatorEmail": null '+
        '               }, '+
        '               "pendingValidation": [], '+
        '               "zipcode": "27660-971", '+
        '               "city": "Rio das Ostras", '+
        '               "state": "RJ", '+
        '               "neighborhood": "Formoso", '+
        '               "street": "Rua Doutor João Garcia da Fonseca", '+
        '               "number": "2209", '+
        '               "complement": "casa 1" '+
        '               }, '+
		'           "identityDocument": { '+ 
		'               "sources": { '+ 
		'                   "type": "MDO",'+
		'                   "number": "MDO",'+
		'                   "expeditionDate": null, '+
		'                   "issuingBody": "Analisador" '+
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
		'			"address": { '+
        '               "sources": { '+
        '                   "zipcode": "MDO", '+ 
        '                   "city": "MDO", '+
        '                   "state": "MDO", '+
        '                   "neighborhood": "MDO", '+
        '                   "street": "MDO", '+
        '                   "number": "MDO", '+
        '                   "complement": "MDO" '+
        '               }, '+
        '               "validation": { '+
        '                   "isValidated": false, '+
        '                   "validatedAt": null, '+
        '                   "validatorEmail": null '+
        '               }, '+
        '               "pendingValidation": [], '+
        '               "zipcode": "27660-971", '+
        '               "city": "Rio das Flores", '+
        '               "state": "RJ", '+
        '               "neighborhood": "Formoso", '+
        '               "street": "Rua Doutor Gilberto Garcia da Fonseca", '+
        '               "number": "2209", '+
        '               "complement": "casa 1" '+
        '               }, '+
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
		'   "relationships": [ '+
		'       { '+ 
		'           "regimen": null, '+
		'           "marriageDate": null, '+
		'           "compulsorySeparation": null, '+
		'           "weddingCertificate": { "entryBook" : null }, '+
		'           "prenuptialAgreementData": null,'+
		'           "hasPrenuptialAgreement": null, '+
		'           "type": "MARRIAGE",'+
		'           "participant1Cpf": "04243545782",'+
		'           "participant2Cpf": "09370233709",'+
		'           "id" : "3fa85f64-5717-4562-b3fc-2c963f66afa6" '+
		'       }, '+
		'       { '+ 
		'           "regimen": null, '+
		'           "marriageDate": null, '+
		'           "compulsorySeparation": null, '+
		'           "prenuptialAgreementData": null,'+
		'           "hasPrenuptialAgreement": null, '+
		'           "type": "STABLE_UNION",'+
		'           "participant1Cpf": "50043545782",'+
		'           "participant2Cpf": "77743545782", '+
		'           "id" : "3fa85f64-5717-4562-b3fc-2c963f66afa2" '+
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

	handleUpdatePersons( event ) {

		let propertyName = event.detail.propertyName;
		let property = event.detail.property;

		this.data[propertyName] = property;

		console.log( 'container -> ' +JSON.stringify( this.data ) );

	}

}