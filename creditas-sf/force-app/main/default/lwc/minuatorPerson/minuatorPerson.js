import { LightningElement, track, api} from 'lwc';

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
	@track certidao = false;
	@track pactoAntenupcial = false;
	@track registroPacto = false;
	@track registroPactoSeparacao = false;
	@track registroUniao = false;
	@track separacao = false;
	@track separacaoPacto = false;
	@track pactoAntenupcialSeparacao = false;
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
	@track separacaoPactoAntenupcialToggle = false;
	@track showMarriedSectionVar = false;
	@track showStableunionSectionVar = false;	
	@track checkProprietario = false;
	@track checkCompoeRenda = true;
	@track relationshipInAddress = "";
	@track singlePerson = [];
	personString = '';
	telefone;
	value = ['Compõe renda'];
	showPersonSectionVar = false;
	showAddressSectionVar = false;
	showRelationshipSectionVar = false;
	showNamePersonAddressVar = false;
	personRelationship = {};
	marriageRelationship = {};
	personProgressRingPercent = 0;
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

	handleChangeOwner(event) {		
		let participacao = this.template.querySelectorAll('[data-participacao="' + event.currentTarget.dataset.id + '"]')
		let consentingChecked = this.template.querySelectorAll('[data-checkbox="' + event.currentTarget.dataset.id + '"]')				

		if(event.target.checked){
			participacao[0].classList.add('participacao');
			participacao[0].classList.remove('participacaoHidden');
		}else{
			participacao[0].classList.remove('participacao');
			participacao[0].classList.add('participacaoHidden');
		}		
		
		if(event.target.checked && consentingChecked[2].checked && this.incomeComposeValue){
			this.labelOption = '3 selecionados';
		} else if(event.target.checked || consentingChecked[2].checked){
				this.labelOption = '2 selecionados';
		}else{
			this.labelOption = 'Compõe renda';
		}
    }

	handleChangeConsenting(event) {		
		let participacao = this.template.querySelectorAll('[data-participacao="' + event.currentTarget.dataset.id + '"]')
		let ownerChecked = this.template.querySelectorAll('[data-checkbox="' + event.currentTarget.dataset.id + '"]')
		
		if(event.target.checked){
			participacao[2].classList.add('participacao');
			participacao[2].classList.remove('participacaoHidden');
		}else{
			participacao[2].classList.remove('participacao');
			participacao[2].classList.add('participacaoHidden');
		}
		if(event.target.checked && ownerChecked[0].checked && this.incomeComposeValue){
			this.labelOption = '3 selecionados';
		} else if(event.target.checked || ownerChecked[0].checked){
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
	onchangePactoSeparacao(event){		
		this.pactoAntenupcialSeparacao = event.target.checked;
		if(!event.target.checked){
			this.registroPactoSeparacao = false;
		}
			this.alertPactoSeparacao = event.target.checked;
	}

	onchangeRegistroPacto(event){	
		this.registroPacto = event.target.checked;
		this.alertPacto = !event.target.checked;

	}
	onchangeRegistroPactoSeparacao(event){	
		this.registroPactoSeparacao = event.target.checked;
		this.alertPactoSeparacao = !event.target.checked;

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
		if(this.certidaoToggle){
		const elementCertidao = this.template.querySelector('[data-id="certidaoToggleId"]'); 
		elementCertidao.checked = false;				
		}
		if(this.pactoAntenupcialToggle){
		const elementPacto = this.template.querySelector('[data-id="pactoToggle"]'); 
		elementPacto.checked = false;
		}
		if(this.separacaoPactoAntenupcialToggle){
			const elementPactoSeparacao = this.template.querySelector('[data-id="separacaoPactoToggleId"]'); 
			elementPactoSeparacao.checked = false;
		}
		let regimeSelecionado = event.detail.value;		

		if(regimeSelecionado === 'comParcialBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;
		
			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;

		}else if(regimeSelecionado === 'sepTotalBefore77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = true;
			this.separacaoPactoAntenupcialToggle = true;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = true;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;		
			this.alertPacto = false;
			this.alertPactoSeparacao = false;

		}else if( regimeSelecionado === 'comunhaoUniversalBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;
		
		}else if( regimeSelecionado === 'aquestosBefore77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;
		}
	}

	onchangeAfter77(event){	
		if(this.certidaoToggle){
		const elementCertidao = this.template.querySelector('[data-id="certidaoToggleId"]'); 
		elementCertidao.checked = false;				
		}
		if(this.pactoAntenupcialToggle){
		const elementPacto = this.template.querySelector('[data-id="pactoToggle"]'); 
		elementPacto.checked = false;
		}
		if(this.separacaoPactoAntenupcialToggle){
			const elementPactoSeparacao = this.template.querySelector('[data-id="separacaoPactoToggleId"]'); 
			elementPactoSeparacao.checked = false;
		}
			
		let regimeSelecionado = event.detail.value;

		if(regimeSelecionado === 'comParcialAfter77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;
		
			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;

		}else if(regimeSelecionado === 'comunhaoUniversalAfter77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;

		}else if(regimeSelecionado === 'separationTotalAfter77' ){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = false;
			this.separacaoToggle = true;
			this.separacaoPactoAntenupcialToggle = true;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = true;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;	
			this.alertPacto = false;
			this.alertPactoSeparacao = false;

		}else if( regimeSelecionado === 'aquestosAfter77'){
			this.certidaoToggle = true;
			this.pactoAntenupcialToggle = true;
			this.separacaoToggle = false;
			this.separacaoPactoAntenupcialToggle = false;

			this.certidao = false;
			this.pactoAntenupcial = false;
			this.pactoAntenupcialSeparacao = false;
			this.registroPacto = false;
			this.registroPactoSeparacao = false;
			this.registroUniao = false;
			this.separacao = false;
			this.alertPacto = false;
			this.alertPactoSeparacao = false;
		}
	}

    connectedCallback(){
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
		'            "maritalStatus": "stable_union",'+
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
			person.id = 'person'+i;
			person.showSection = false;	
				
			person.cpf = person.documents.filter(doc => { return doc.type == 'CPF'})[0]?.number;
			person.cpf = person.cpf.substring(0,3) + '.' + person.cpf.substring(3,6) + '.' + person.cpf.substring(6,9) + '-' + person.cpf.substring(9,11);
			person.address.zipcode = person.address.zipcode.substring(0,5) + '-' + person.address.zipcode.substring(5,8);
			person.cellPhone = '(' + person.cellPhone.substring(0,2) + ') ' + person.cellPhone.substring(2,3) + ' ' + person.cellPhone.substring(3,7) + '-' + person.cellPhone.substring(7,11);
			
			if(person.maritalStatus === "single"){
				this.singlePerson.push(person);
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
			if(marriage.maritalStatus === "married" && marriage.participant1.gender === "female"){
				marriage.maritalStatus = "Casada com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "married" && marriage.participant1.gender === "male"){
				marriage.maritalStatus = "Casado com" ;
				this.showMarriedSectionVar = true;
				this.showStableunionSectionVar = false;	
			}else if(marriage.maritalStatus === "stable_union"){
				marriage.maritalStatus = "União estável com ";
				this.showMarriedSectionVar = false;
				this.showStableunionSectionVar = true;				
			}else if(!marriage.maritalStatus){
				this.showSectionRelationshipInAddress = false;
							}			
			this.marriageObject = marriage;			
		});
    }
	
}