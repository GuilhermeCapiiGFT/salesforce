import { LightningElement, track, api} from 'lwc';

export default class MinuatorPersonAddresses extends LightningElement {
    @api index;
    @api person;
    @api marriage;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
	@track txtclassnameAddress = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';	
	@track ownerValue = false;
	@track consentingValue = false;
	@track incomeComposeValue = true;
	@track labelOption = 'Compõe renda';
    @track personObject = {};
	@track marriageObject = {};
	@track persons = [];	
	@track showSectionRelationshipInAddress = true;	
	@track relationshipInAddress = "";
	@track singlePerson = [];
	personString = '';
	showAddressSectionVar = false;
	showRelationshipSectionVar = false;	
	showNamePersonAddressVar = false;
	personRelationship = {};
	marriageRelationship = {};
	personProgressRingPercent = 0;
	personSectionIcon = "utility:chevronright";
	addressSectionIcon = "utility:chevronright";
	

	showAddressSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';		
		this.showAddressSectionVar = !this.showAddressSectionVar;
		this.addressSectionIcon = this.showAddressSectionVar ? "utility:chevrondown" : "utility:chevronright";	
	}

	showNamePersonAddress(){
		this.showNamePersonAddressVar = !this.showNamePersonAddressVar
	}

	showPersonDataSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
		let actualPerson = this.persons.filter(person => { return person.name === event.currentTarget.dataset.name});
		actualPerson[0].showSection = !actualPerson[0].showSection		
		event.stopPropagation();
	}

	showAddressDataSection(){
	    this.showAddressSectionVar = !this.showAddressSectionVar
	}   

    connectedCallback(){
        this.personString = 
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
        '           "address": { '+
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
        '           "address": { '+
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
        '               "zipcode": "13825-970", '+
        '               "city": "Holambra", '+
        '               "state": "SP", '+
        '               "neighborhood": "Jd. São Paulo", '+
        '               "street": "Rua Liziantus ", '+
        '               "number": "87", '+
        '               "complement": "fundos" '+
        '               }, '+
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
        '           "address": { '+
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
        '               "zipcode": "62602-974", '+
        '               "city": "Aguaí", '+
        '               "state": "CE", '+
        '               "neighborhood": "Centro", '+
        '               "street": "Rua Principal", '+
        '               "number": "85", '+
        '               "complement": "AP 32" '+
        '               }, '+
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
        '           "address": { '+
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
        '               "zipcode": "79990972", '+
        '               "city": "Amambaí", '+
        '               "state": "MS", '+
        '               "neighborhood": "Centro", '+
        '               "street": "Avenida Pedro Manvailler", '+
        '               "number": "3388", '+
        '               "complement": "casa 01" '+
        '               }, '+
		'          "propertyOwner": false, '+
		'          "consentingParticipant": null '+
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
	

        this.personObject = JSON.parse(this.personString);
		var i = 0;
		this.personObject.persons.forEach(person => {
			i++;
			var personId = 'person'+i;
			person.id = personId;
			person.showSection = false;						
	
			if(person.maritalStatus === "MARRIED"){
				person.maritalPersonStatus = "Casado";
			}else if(person.maritalStatus === "SINGLE"){
				person.maritalPersonStatus = "Solteiro";
				this.singlePerson.push(person);
			}else if(person.maritalStatus === "DIVORCED"){
				person.maritalPersonStatus = "Divorciado";
			}else if(person.maritalStatus === "SEPARATED"){
				person.maritalPersonStatus = "Separado";
			}else if(person.maritalStatus === "WIDOWER"){
				person.maritalPersonStatus = "Viúvo";
			}
             
            let listName = person.name.split(' ');
			person.formatedName = listName[0] + ' ' + listName[listName.length-1];
			
			this.persons.push(person);				
		});
		
        i = 0;
		this.personObject.marriages.forEach(marriage => {
			i++;	
			marriage.id = 'marriage'+i;
			marriage.index = i;
			marriage.showSection = false;

			this.persons.forEach(person => {
				if(person.mainDocument.number == marriage.participant1Cpf) {
					marriage.participant1Name = person.name;
					marriage.participant1Gender = person.gender;
                    marriage.participant1Street = person.address.street;
                    marriage.participant1Zipcode = person.address.zipcode;
                    marriage.participant1City = person.address.city;
                    marriage.participant1State = person.address.state;
                    marriage.participant1Neighborhood = person.address.neighborhood;
                    marriage.participant1Number = person.address.number;
                    marriage.participant1Complement = person.address.complement;

				}else if(person.mainDocument.number == marriage.participant2Cpf) {
					marriage.participant2Name = person.name;
				}

			});
			
			if(marriage.maritalStatus === "MARRIAGE" && marriage.participant1Gender === "FEMALE"){
				marriage.maritalStatus = "Casada com" ;
				marriage.maritalMarried = true;	
				marriage.maritalStable = false;			
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "MARRIAGE" && marriage.participant1Gender === "MALE"){
				marriage.maritalStatus = "Casado com" ;
				marriage.maritalMarried = true;
				marriage.maritalStable = false;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "STABLE_UNION"){
				marriage.maritalStatus = "União estável com ";
				marriage.maritalMarried = false;
				marriage.maritalStable = true;
				this.showMarriedSectionVar = false;
				this.showStableunionSectionVar = true;
				
			}else if(!marriage.maritalStatus){
				this.showSectionRelationshipInAddress = false;
				this.hideRelationshipSectionVar = false;
			} 		
			this.marriageObject = marriage;			
		});
    }	
}