import { LightningElement, track, api} from 'lwc';
import modal from "@salesforce/resourceUrl/customSyncModal";
import { loadStyle } from "lightning/platformResourceLoader";

export default class MinuatorPerson extends LightningElement {    
	@track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
	@track txtclassnameAddress = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';	
	@track ownerValue = false;
	@track consentingValue = false;
	@track incomeComposeValue = true;
	@track labelOption = 'Compõe renda';
    @track personObject = {};
	@track marriageObject = {};
	@track persons = [];	
	@track syncFieldsMap = {};
	@track certidao = false;
	@track pactoAntenupcial = false;
	@track registroPacto = false;
	@track registroUniao = false;
	@track separacao = false;
	@track alertPacto = false;
	@track vigencia = false;
	@track typeCertidao = "";
	@track disableBook = true;
	@track disableMatricula = true;
	@track showSectionRelationshipInAddress = true;
	@track disableRegime = true;
	@track regimeAfter77 = false;
	@track regimeBefore77 = false;
	@track certidaoToggle = false;
	@track pactoAntenupcialToggle = false;
	@track separacaoToggle = false;
	@track showMarriedSectionVar = false;
	@track showStableunionSectionVar = false;	
	@track checkProprietario = false;
	@track checkCompoeRenda = true;
	@track isModalOpen = false;
	@track relationshipInAddress = "";
	@track singlePerson = [];
	personString = '';
	telefone;
	value = ['Compõe renda'];
	showPersonSectionVar = false;
	showAddressSectionVar = false;
	showRelationshipSectionVar = false;
	hideRelationshipSectionVar = false;
	showNamePersonAddressVar = false;
	personRelationship = {};
	marriageRelationship = {};
	personProgressRingPercent = 0;
	personProgressRingVariant = "base";
	personSectionIcon = "utility:chevronright";
	addressSectionIcon = "utility:chevronright";

	participationOptions = [
		{ label: 'Proprietário', value: 'owner' },
		{ label: 'Compõe renda', value: 'incomeCompose' },
		{ label: 'Anuente', value: 'consenting' }
	];
	genderOptions = [
		{ label: 'Masculino', value: 'male' },
		{ label: 'Feminino', value: 'female' }
	];
	documentTypeOptions = [
		{ label: 'RG - Registro Geral', value: 'rg' },
		{ label: 'CNH - Carteira Nacional de Habilitação', value: 'cnh' },
		{ label: 'RNE - Registro Nacional de Estrangeiros', value: 'rne	' },
		{ label: 'Documento de Classe', value: 'classDocument' }
	];

	regimeOptions = [
		{ label: 'Comunhao parcial de bens', value: 'comunhaoParcial' },
		{ label: 'Comunhão universal de bens', value: 'comunhaoUniversal' },
		{ label: 'Separação total de bens', value: 'separacaoTotal' },
		{ label: 'Participação final nos aquestos', value: 'participacaoAquestos' }	
	];
	
	regimeOptionsBefore77 = [
		
		{ label: 'Comunhão parcial de bens', value: 'comParcialBefore77' },
		{ label: 'Comunhão universal de bens', value: 'comunhaoUniversalBefore77'},
		{ label: 'Separação total de bens', value: 'sepTotalBefore77' },
		{ label: 'Participação final nos aquestos', value: 'aquestosBefore77'}	
				
	];

	regimeOptionsAfter = [			
		{ label: 'Comunhão parcial de bens', value: 'comParcialAfter77' },
		{ label: 'Comunhão universal de bens', value: 'comunhaoUniversalAfter77'},
		{ label: 'Separação total de bens', value: 'separationTotalAfter77' },		
		{ label: 'Participação final nos aquestos', value: 'aquestosAfter77' },

	];

	typeOptions = [
		{ label: 'Livro e folha', value: 'livroFolha' },
		{ label: 'Matrícula', value: 'matricula' }
	]	

	closeSyncModal(){
		this.isModalOpen = false;
	}

	handleChange(event) {
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
    }

	handleChangeOwner(e) {
        this.ownerValue = !this.ownerValue;
		if(this.consentingValue && this.ownerValue && this.incomeComposeValue){
			this.labelOption = '3 selecionados';
		} else if(this.consentingValue || this.ownerValue){
				this.labelOption = '2 selecionados';
		}else{
			this.labelOption = 'Compõe renda';
		}
    }

	handleChangeConsenting(e) {
        this.consentingValue = !this.consentingValue;
		if(this.consentingValue && this.ownerValue && this.incomeComposeValue){
			this.labelOption = '3 selecionados';
		} else if(this.consentingValue || this.ownerValue){
				this.labelOption = '2 selecionados';
		}else{
			this.labelOption = 'Compõe renda';
		}
    }

	atribuirControlesApresentacaoLista(){
		if ( this.txtclassname == 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click')
        {            
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
        else
        {
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        }
	}

	showPersonSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';		
		this.showPersonSectionVar = !this.showPersonSectionVar;
		this.personSectionIcon = this.showPersonSectionVar ? "utility:chevrondown" : "utility:chevronright";			
	}

	showAddressSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';		
		this.showAddressSectionVar = !this.showAddressSectionVar;
		this.addressSectionIcon = this.showAddressSectionVar ? "utility:chevrondown" : "utility:chevronright";	
	}

	showRelationshipSection(){
		this.showRelationshipSectionVar = !this.showRelationshipSectionVar
	}
	hideRelationshipSection(){
		this.hideRelationshipSectionVar = !this.hideRelationshipSectionVar
	}

	showNamePersonAddress(){
		this.showNamePersonAddressVar = !this.showNamePersonAddressVar
	}

	openSyncModal(){
		this.isModalOpen = true;
		this.personProgressRingVariant = 'warning';
		this.personProgressRingPercent = 25;
		//result
		let sectionId = 'person1';
		var person = this.persons.filter(function(person) {
			return person.id == sectionId;
		});
		person[0].isWarningSection = true;
		person[0].isActiveSection = false;
		let fieldsList = ['cellPhone', 'email'];
		let fieldsString = '';
		fieldsList.forEach(field => {
			fieldsString += field + ',';
		});
		fieldsString.slice(0, -1);
		this.syncFieldsMap[sectionId] = fieldsString;
		this.setSyncFields(sectionId);
	}

	setSyncFields(sectionId){
		let fieldsList = this.syncFieldsMap[sectionId]?.split(',');
		if(fieldsList){
			fieldsList.forEach(field => {
				setTimeout(() => this.template.querySelector('[data-id="'+sectionId+field+'"]')?.classList.add("yellow-icon"));
				//this.template.content.querySelector('[data-id="'+sectionId+field+'"]')?.classList.add("yellow-icon");			
			});
		}

		//this.template.querySelector('[data-id="person1email"]').classList.add("yellow-icon");
	}

	showPersonDataSection(event){
		var personId = event.currentTarget.dataset.id;
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
		let actualPerson = this.persons.filter(person => { return person.name === event.currentTarget.dataset.name});
		actualPerson[0].showSection = !actualPerson[0].showSection;
		this.setSyncFields(personId);	
		event.stopPropagation();
	}

	showAddressDataSection(){
	    this.showAddressSectionVar = !this.showAddressSectionVar
	}

	onchangeCertidao(event){		
		this.certidao = event.target.checked;	

	}

	onchangePacto(event){		
		this.pactoAntenupcial = event.target.checked;
		if(!event.target.checked){
			this.registroPacto = false;
		}
			this.alertPacto = event.target.checked;
	}

	onchangeRegistroPacto(event){	
		this.registroPacto = event.target.checked;
		this.alertPacto = !event.target.checked;

	}

	onchangeSeparacao(event){
		this.separacao = event.target.checked;
		if(!event.target.checked){
			
		}
	}

	onchangeRegistroUniao(event){
		this.registroUniao = event.target.checked;
	}

	onchangeData(event){		
		let selectedDate = event.detail.value;				
		if(!selectedDate){ 
			this.disableRegime = true;
		}else{
			this.disableRegime = false;
			let dateConvert = new Date( selectedDate.substring(0,4), (selectedDate.substring(5,7)-1), selectedDate.substring(8,10), ); 
			dateConvert.setHours( 0 );
			let dateVigente = new Date(1977,11,26);		
			if(dateConvert >= dateVigente){
				this.vigencia = true;
			}else{
				this.vigencia = false;
			}	
		}		
	}

	onchangeTypeCertidao(event){
		let typeCertidao = event.detail.value;	
		if(typeCertidao === 'livroFolha'){
			this.disableMatricula = true;
			this.disableBook = false;
		}else if(typeCertidao === 'matricula'){
			this.disableBook = true;
			this.disableMatricula = false;
		}
	}

	onchangeBefore77(event){		
		let regimeSelecionado = event.detail.value;		

		if(regimeSelecionado === 'comParcialBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;
		
			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;

		}else if(regimeSelecionado === 'sepTotalBefore77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = true;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
		}else if( regimeSelecionado === 'comunhaoUniversalBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
		
		}else if( regimeSelecionado === 'aquestosBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
		}
	}

	onChangePersonInput(event){
		let splittedId =  event.currentTarget.dataset.id.split('_');
		let actualPersonId = splittedId[0];
		let actualFieldName = splittedId[1];
		let actualPerson = this.persons.filter(person => { return person.id === actualPersonId })[0];
		actualPerson[actualFieldName] = event.target.value;
		this.getPersonObject(actualPersonId);
	}

	onchangeAfter77(event){		
		let regimeSelecionado = event.detail.value;

		if(regimeSelecionado === 'comParcialAfter77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = false;
		
			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;

		}else if(regimeSelecionado === 'comunhaoUniversalAfter77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;

		}else if(regimeSelecionado === 'separationTotalAfter77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = true;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
		}else if( regimeSelecionado === 'aquestosAfter77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.registroPacto = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
		}
	}

	getPersonObject(personId){
		debugger
		let actualPerson = this.persons.filter(person => { return person.id === personId})[0];

		return '{'+
					'"mainDocument": {'+
						'"type": '+actualPerson.mainDocument?.type+ ','+
						'"code": '+actualPerson.mainDocument?.code+
					'},'+
					'"fullName": '+actualPerson.name+','+
					'"gender": '+actualPerson.gender+','+
					'"birthDate": {},'+ //Why is this an Object?
					'"civilStatus":'+actualPerson.maritalStatus+','+
					'"cityOfBirth":'+ "value here" +','+ //Where does this come from?
					'"countryOfBirth":'+ "value here" +','+
					'"nationality":'+actualPerson.nationality+','+
					'"filiation": ['+
					actualPerson.motherName ? (
						'{'+
							'"type": "MOTHER",'+
							'"name":'+actualPerson.motherName+
						'}'
					) : ''+
					actualPerson.fatherName ? (
						actualPerson.motherName ? ',' : ''+
						'{'+
							'"type": "FATHER",'+
							'"name":'+actualPerson.fatherName+
						'}'
					) : ''+
					'],'+
					'"currentVersion": 1'+ //Where does this come from?
				'}';
	}

	getAddressObject(personId){
		let actualPerson = this.persons.filter(person => { return person.id === personId})[0];
		let address = actualPerson.address;

		return 	'{'+
					'"type": "BILLING",'+ //Where does this come from?
					'"country": "BR",'+ //Where does this come from?
					'"administrativeAreaLevel1": "Administrative level 1",'+ //what is this
					'"administrativeAreaLevel2": "Administrative level 2",'+ //what is this
					'"administrativeAreaLevel3": "Administrative level 3",'+ //what is this
					'"administrativeAreaLevel4": "Administrative level 4",'+ //what is this
					'"administrativeAreaLevel5": "Administrative level 5",'+ //what is this
					'"neighborhood":'+address.neighborhood+','+ 
					'"street":'+address.street+','+
					'"number":'+address.number+','+
					'"complement":'+address.complement+','+
					'"zipCode":'+address.zipcode+','+
					'"personCurrentVersion": 0'+ //Where does this come from?
		  		'}';
	}

    connectedCallback(){
		loadStyle(this, modal);

        this.personString = '{'+
		'    "cciNumber": null,'+
		'    "cciSeries": null,'+
		'    "creditor": null,'+
		'    "underwriter": null,'+
		'    "contractNumber": null,'+
		'    "applicationId": "924e5c90-bfe9-11eb-81f3-cf498ce92fad",'+
		'    "providerContractId": "924e5c90-bfe9-11eb-81f3-cf498ce92fad1642535156319",'+
		'    "leadId": null,'+
		'    "checkedByOne": null,'+
		'    "checkedByTwo": null,'+
		'    "emittedBy": null,'+
		'    "forcedBy": false,'+
		'    "lastUpdated": "2022-01-18T19:45:52",'+
		'    "isCreditas": true,'+
		'    "persons": ['+
		'        {'+
		'            "name": "MÉRI TERESINHA FERRONATO PAGANINI",'+
		'            "gender": "female",'+
		'            "cellPhone": "45999416710",'+
		'            "birthdate": "1973-03-03",'+
		'            "nationality": "Brasileira",'+
		'            "email": "meri_ferronato@hotmail.com",'+
		'            "profession": "sócia de empresa",'+
		'            "maritalStatus": "married",'+
		'            "fatherName": "JOÃO ADELINO FERRONATO",'+
		'            "motherName": "AMABILE ABATI FERRONATO",'+
		'            "documents": ['+
		'                {'+
		'                    "type": "RG",'+
		'                    "expeditionDate": null,'+
		'                    "number": "6.872.171-7",'+
		'                    "issuingBody": "SESP/PR",'+
		'                    "isMainDocument": false'+
		'                },'+
		'                {'+
		'                    "type": "CPF",'+
		'                    "expeditionDate": null,'+
		'                    "number": "71133500110",'+
		'                    "issuingBody": null,'+
		'                    "isMainDocument": false'+
		'                }'+
		'            ],'+
		'            "banking": null,'+
		'            "identityDocument": null,'+
		'            "address": {'+
		'                "zipcode": "85808452",'+
		'                "city": "Cascavel",'+
		'                "state": "PR",'+
		'                "neighborhood": "FAG",'+
		'                "street": "Rua Áscole",'+
		'                "number": "657",'+
		'                "complement": "Residencial Treviso"'+
		'            }'+
		'        },'+	
		'        {'+
		'            "name": "NERO PAGANINI",'+
		'            "gender": "male",'+
		'            "cellPhone": "45999416710",'+
		'            "birthdate": "1973-03-03",'+
		'            "nationality": "Brasileira",'+
		'            "email": "meri_ferronato@hotmail.com",'+
		'            "profession": "sócia de empresa",'+
		'            "maritalStatus": "married",'+
		'            "fatherName": "JOÃO ADELINO FERRONATO",'+
		'            "motherName": "AMABILE ABATI FERRONATO",'+
		'            "documents": ['+
		'                {'+
		'                    "type": "RG",'+
		'                    "expeditionDate": null,'+
		'                    "number": "6.872.171-7",'+
		'                    "issuingBody": "SESP/PR",'+
		'                    "isMainDocument": false'+
		'                },'+
		'                {'+
		'                    "type": "CPF",'+
		'                    "expeditionDate": null,'+
		'                    "number": "45533500110",'+
		'                    "issuingBody": null,'+
		'                    "isMainDocument": false'+
		'                }'+
		'            ],'+
		'            "banking": null,'+
		'            "identityDocument": null,'+
		'            "address": {'+
		'                "zipcode": "85808452",'+
		'                "city": "Cascavel",'+
		'                "state": "PR",'+
		'                "neighborhood": "FAG",'+
		'                "street": "Rua Áscole",'+
		'                "number": "657",'+
		'                "complement": "Residencial Treviso"'+
		'            }'+
		'        },'+	      
		'        {'+
		'            "name": "MARIANA FERRONATO PAGANINI",'+
		'            "gender": "female",'+
		'            "cellPhone": "45999416710",'+
		'            "birthdate": "1973-03-03",'+
		'            "nationality": "Brasileira",'+
		'            "email": "meri_ferronato@hotmail.com",'+
		'            "profession": "sócia de empresa",'+
		'            "maritalStatus": "single",'+
		'            "fatherName": "JOÃO ADELINO FERRONATO",'+
		'            "motherName": "AMABILE ABATI FERRONATO",'+
		'            "documents": ['+
		'                {'+
		'                    "type": "RG",'+
		'                    "expeditionDate": null,'+
		'                    "number": "7.872.171-7",'+
		'                    "issuingBody": "SESP/PR",'+
		'                    "isMainDocument": false'+
		'                },'+
		'                {'+
		'                    "type": "CPF",'+
		'                    "expeditionDate": null,'+
		'                    "number": "48833500110",'+
		'                    "issuingBody": null,'+
		'                    "isMainDocument": false'+
		'                }'+
		'            ],'+
		'            "banking": null,'+
		'            "identityDocument": null,'+
		'            "address": {'+
		'                "zipcode": "85808452",'+
		'                "city": "Cascavel",'+
		'                "state": "PR",'+
		'                "neighborhood": "FAG",'+
		'                "street": "Rua Áscole",'+
		'                "number": "657",'+
		'                "complement": "Residencial Treviso"'+
		'            }'+
		'        }'+        
		'    ],'+
		'    "marriages": ['+
		'        {'+
		'            "regime": "Comunhão total de bens",'+
		'            "marriageDate": null,'+
		'            "compulsorySeparation": null,'+
		'            "registerPrenuptialAgreement": null,'+
		'            "prenuptialAgreement": null,'+
		'            "maritalStatus": "married",'+
		'            "cohabitant": false,'+
		'            "participant1": {'+
		'                "name": "MÉRI TERESINHA FERRONATO PAGANINI",'+
		'                "gender": "female",'+
		'                "cellPhone": "459994167101",'+
		'                "birthdate": "1973-03-03",'+
		'                "nationality": null,'+
		'                "email": "meri_ferronato@hotmail.com",'+
		'                "profession": "sócia de empresa",'+
		'                "fatherName": "JOÃO ADELINO FERRONATO",'+
		'                "motherName": "AMABILE ABATI FERRONATO",'+
		'                "documents": ['+
		'                    {'+
		'                        "type": "RG",'+
		'                        "expeditionDate": null,'+
		'                        "number": "6.872.171-7",'+
		'                        "issuingBody": "SESP/PR",'+
		'                        "isMainDocument": false'+
		'                    },'+
		'                    {'+
		'                        "type": "CPF",'+
		'                        "expeditionDate": null,'+
		'                        "number": "71133500110",'+
		'                        "issuingBody": null,'+
		'                        "isMainDocument": false'+
		'                    }'+
		'                ],'+
		'                "banking": null,'+
		'                "identityDocument": null,'+
		'                "address": {'+
		'                    "zipcode": "85808452",'+
		'                    "city": "Cascavel",'+
		'                    "state": "PR",'+
		'                    "neighborhood": "FAG",'+
		'                    "street": "Rua Áscole",'+
		'                    "number": "657",'+
		'                    "complement": "Residencial Treviso"'+
		'                }'+
		'            },'+
		'            "participant2": {'+
		'                "name": "NERO SILVA PAGANINI",'+
		'                "gender": "male",'+
		'                "cellPhone": "459994167101",'+
		'                "birthdate": "1969-01-18",'+
		'                "nationality": null,'+
		'                "email": "meri_ferronato@hotmail.com",'+
		'                "profession": "sócio de empresa",'+
		'                "fatherName": "OCTAVIO PAGANINI",'+
		'                "motherName": "ORLANDINA NECKEL PAGANINI",'+
		'                "documents": ['+
		'                    {'+
		'                        "type": "RG",'+
		'                        "expeditionDate": null,'+
		'                        "number": "4.257.811-8",'+
		'                        "issuingBody": "SESP/PR",'+
		'                        "isMainDocument": false'+
		'                    },'+
		'                    {'+
		'                        "type": "CPF",'+
		'                        "expeditionDate": null,'+
		'                        "number": "66283019900",'+
		'                        "issuingBody": null,'+
		'                        "isMainDocument": false'+
		'                    }'+
		'                ],'+
		'                "banking": null,'+
		'                "identityDocument": null,'+
		'                "address": {'+
		'                    "zipcode": "85808452",'+
		'                    "city": "Cascavel",'+
		'                    "state": "PR",'+
		'                    "neighborhood": "FAG",'+
		'                    "street": "Rua Áscole",'+
		'                    "number": "657",'+
		'                    "complement": "Residencial Treviso"'+
		'                }'+
		'            }'+
		'        },'+
		'        {'+
		'            "regime": "Comunhão total de bens",'+
		'            "marriageDate": null,'+
		'            "compulsorySeparation": null,'+
		'            "registerPrenuptialAgreement": null,'+
		'            "prenuptialAgreement": null,'+
		'            "maritalStatus": "married",'+
		'            "cohabitant": false,'+
		'            "participant1": {'+
		'                "name": "TERESINHA FERRONATO PAGANINI",'+
		'                "gender": "female",'+
		'                "cellPhone": "459994167101",'+
		'                "birthdate": "1973-03-03",'+
		'                "nationality": null,'+
		'                "email": "meri_ferronato@hotmail.com",'+
		'                "profession": "sócia de empresa",'+
		'                "fatherName": "JOÃO ADELINO FERRONATO",'+
		'                "motherName": "AMABILE ABATI FERRONATO",'+
		'                "documents": ['+
		'                    {'+
		'                        "type": "RG",'+
		'                        "expeditionDate": null,'+
		'                        "number": "6.872.171-7",'+
		'                        "issuingBody": "SESP/PR",'+
		'                        "isMainDocument": false'+
		'                    },'+
		'                    {'+
		'                        "type": "CPF",'+
		'                        "expeditionDate": null,'+
		'                        "number": "71133500110",'+
		'                        "issuingBody": null,'+
		'                        "isMainDocument": false'+
		'                    }'+
		'                ],'+
		'                "banking": null,'+
		'                "identityDocument": null,'+
		'                "address": {'+
		'                    "zipcode": "85808452",'+
		'                    "city": "Cascavel",'+
		'                    "state": "PR",'+
		'                    "neighborhood": "FAG",'+
		'                    "street": "Rua Áscole",'+
		'                    "number": "657",'+
		'                    "complement": "Residencial Treviso"'+
		'                }'+
		'            },'+
		'            "participant2": {'+
		'                "name": "PEDRO SILVA PAGANINI",'+
		'                "gender": "male",'+
		'                "cellPhone": "459994167101",'+
		'                "birthdate": "1969-01-18",'+
		'                "nationality": null,'+
		'                "email": "meri_ferronato@hotmail.com",'+
		'                "profession": "sócio de empresa",'+
		'                "fatherName": "OCTAVIO PAGANINI",'+
		'                "motherName": "ORLANDINA NECKEL PAGANINI",'+
		'                "documents": ['+
		'                    {'+
		'                        "type": "RG",'+
		'                        "expeditionDate": null,'+
		'                        "number": "4.257.811-8",'+
		'                        "issuingBody": "SESP/PR",'+
		'                        "isMainDocument": false'+
		'                    },'+
		'                    {'+
		'                        "type": "CPF",'+
		'                        "expeditionDate": null,'+
		'                        "number": "66283019900",'+
		'                        "issuingBody": null,'+
		'                        "isMainDocument": false'+
		'                    }'+
		'                ],'+
		'                "banking": null,'+
		'                "identityDocument": null,'+
		'                "address": {'+
		'                    "zipcode": "85808452",'+
		'                    "city": "Cascavel",'+
		'                    "state": "PR",'+
		'                    "neighborhood": "FAG",'+
		'                    "street": "Rua Áscole",'+
		'                    "number": "657",'+
		'                    "complement": "Residencial Treviso"'+
		'                }'+
		'            }'+
		'        }'+
		'    ]'+
		'}'+
		'';

        this.personObject = JSON.parse(this.personString);
		var i = 0;
		this.personObject.persons.forEach(person => {
			i++;
			var personId = 'person'+i;
			person.id = personId;
			person.cellPhoneId = personId+"cellPhone";
			person.emailId = personId+"email";
			person.genderInputId = personId+'_gender';
			person.isActiveSection = true;
			person.isWarningSection = false;
			person.showSection = false;				
			person.cpf = person.documents.filter(doc => { return doc.type == 'CPF'})[0]?.number;
			person.cpf = person.cpf.substring(0,3) + '.' + person.cpf.substring(3,6) + '.' + person.cpf.substring(6,9) + '-' + person.cpf.substring(9,11);
			person.address.zipcode = person.address.zipcode.substring(0,5) + '-' + person.address.zipcode.substring(5,8);
			person.cellPhone = '(' + person.cellPhone.substring(0,2) + ') ' + person.cellPhone.substring(2,3) + ' ' + person.cellPhone.substring(3,7) + '-' + person.cellPhone.substring(7,11);
			
			if(person.maritalStatus === "single"){
				this.singlePerson.push(person);
			}
			this.persons.push(person);				
		});
		
        i = 0;
		this.personObject.marriages.forEach(marriage => {
			i++;	
			marriage.id = 'marriage'+i;
			marriage.index = i;
			marriage.showSection = false;
			if(marriage.maritalStatus === "married" && marriage.participant1.gender == "female"){
				marriage.maritalStatus = "Casada com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "married" && marriage.participant1.gender == "male"){
				marriage.maritalStatus = "Casado com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "married" && marriage.participant2.gender == "male"){
				marriage.maritalStatus = "Casado com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "married" && marriage.participant2.gender == "female"){
				marriage.maritalStatus = "Casada com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "stable_union"){
				marriage.maritalStatus = "União estável com ";
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