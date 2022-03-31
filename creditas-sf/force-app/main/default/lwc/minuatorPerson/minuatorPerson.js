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
	@track vigenciaMarried = false;
	@track typeCertidao = "";
	@track disableBook = true;
	@track disableMatricula = true;
	@track showSectionRelationshipInAddress = true;
	@track disableRegimeMarried = true;
	@track disableRegimeStableUnion = true;
	@track regimeAfter77 = false;
	@track regimeBefore77 = false;
	@track certidaoToggle = false;
	@track pactoAntenupcialToggle = false;
	@track separacaoToggle = false;
	@track separacaoPactoAntenupcialToggle = false;		
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
	showMarriedSectionVar = false;
	showStableunionSectionVar = false;
	hideRelationshipSectionVar = false;
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

	  handleChange(event) {
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
    }

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

	signControlsExibitionList(){
		if ( this.txtclassname == 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click')
        {            
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
        else{
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
	showMarriedSection(){
		this.showMarriedSectionVar = !this.showMarriedSectionVar
	}
	showStableunionSection(){
		this.showStableunionSectionVar = !this.showStableunionSectionVar
	}

	hideRelationshipSection(){
		this.hideRelationshipSectionVar = !this.hideRelationshipSectionVar
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
			this.alertPactoSeparacao = false;	
		}	
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
			this.registroPactoSeparacao = false;			
		}
		this.alertPactoSeparacao = !event.target.checked;
		this.pactoAntenupcialSeparacao = !event.target.checked;
		this.separacaoPactoAntenupcialToggle = !event.target.checked;
	}

	onchangeRegistroUniao(event){
		this.registroUniao = event.target.checked;
	}

	onchangeDataMarried(event){		
		let selectedDate = event.detail.value;				
		if(!selectedDate){ 
			this.disableRegimeMarried = true;
		}else{
			this.disableRegimeMarried = false;
			let dateConvert = new Date( selectedDate.substring(0,4), (selectedDate.substring(5,7)-1), selectedDate.substring(8,10), ); 
			dateConvert.setHours( 0 );
			let dateVigente = new Date(1977,11,26);		
			if(dateConvert >= dateVigente){
				this.vigenciaMarried = true;
			}else{
				this.vigenciaMarried = false;
			}	
		}		
	}

	onchangeDataStableUnion(event){		
		let selectedDate = event.detail.value;				
		if(!selectedDate){ 
			this.disableRegimeStableUnion = true;
		}else{
			this.disableRegimeStableUnion = false;			
		}		
	}

	onchangeTypeCertidao(event){
		let typeCertidao = event.detail.value;	
		if(typeCertidao === 'livroFolha'){
			this.disableMatricula = true;
			this.disableBook = false;	
			const elementMatricula = this.template.querySelector('[data-id="matriculaId"]'); 
			elementMatricula.value = "";				
			
		}else if(typeCertidao === 'matricula'){
			this.disableBook = true;
			this.disableMatricula = false;
			const elementBook = this.template.querySelector('[data-id="bookId"]'); 
			elementBook.value = "";	
			const elementSheet = this.template.querySelector('[data-id="sheetId"]'); 
			elementSheet.value = "";
		}
	}

	onchangeBefore77(event){
		if(this.certidaoToggle){
		const elementCertidao = this.template.querySelector('[data-id="certidaoToggleId"]'); 
		elementCertidao.checked = false;				
		}
		if(this.pactoAntenupcialToggle){
		const elementPacto = this.template.querySelector('[data-id="pactoToggleId"]'); 
		elementPacto.checked = false;
		}
		if(this.separacaoPactoAntenupcialToggle){
			const elementPactoSeparacao = this.template.querySelector('[data-id="separacaoPactoToggleId"]'); 
			elementPactoSeparacao.checked = true;
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
			this.alertPactoSeparacao = true;

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
		const elementPacto = this.template.querySelector('[data-id="pactoToggleId"]'); 
		elementPacto.checked = false;
		}
		if(this.separacaoPactoAntenupcialToggle){
			const elementPactoSeparacao = this.template.querySelector('[data-id="separacaoPactoToggleId"]'); 
			elementPactoSeparacao.checked = true;			
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
			this.alertPactoSeparacao = true;

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
	

        this.personObject = JSON.parse(this.personString);
		var i = 0;
		this.personObject.persons.forEach(person => {
			i++;
			var personId = 'person'+i;
			person.id = personId;
			person.showSection = false;	
				
			//person.cpf = person.documents.filter(doc => { return doc.type == 'CPF'})[0]?.number;
			person.cpf = person.mainDocument.number;

			//person.cpf = person.cpf.substring(0,3) + '.' + person.cpf.substring(3,6) + '.' + person.cpf.substring(6,9) + '-' + person.cpf.substring(9,11);
			person.cpf = person.cpf.substring(0,3) + '.' + person.cpf.substring(3,6) + '.' + person.cpf.substring(6,9) + '-' + person.cpf.substring(9,11);
			//person.address.zipcode = person.address.zipcode.substring(0,5) + '-' + person.address.zipcode.substring(5,8);
			person.cellPhone = '(' + person.cellPhone.substring(0,2) + ') ' + person.cellPhone.substring(2,3) + ' ' + person.cellPhone.substring(3,7) + '-' + person.cellPhone.substring(7,11);
			
			person.nameId = personId+"name";
			person.cpfId = personId+"CPF";			
			person.nationalityId = personId+"nationality";
			person.birthdateId = personId+"birthdate";
			person.maritalStatusId = personId+"maritalStatus";
			person.motherNameId = personId+"motherName";
			person.fatherNameId = personId+"fatherName";
			person.professionId = personId+ "profession";
			person.cellPhoneId = personId+"cellPhone";
			person.emailId = personId+"email";

			
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