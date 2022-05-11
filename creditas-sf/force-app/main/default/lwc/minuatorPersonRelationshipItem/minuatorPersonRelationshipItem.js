import { LightningElement, track, api } from 'lwc';
import { regimeOptions, typeOptions, enableOrDisableByRegimes } from './minuatorPersonRelationshipItemOptions';

export default class MinuatorPersonRelationshipItem extends LightningElement {

	@track showCertidao = false;
	@track showPactoAntenupcial = false;
	@track showRegistroPacto = false;
	@track showRegistroPactoSeparacao = false;
	@track showRegistroUniao = false;
	@track showSeparacao = false;
	@track separacaoPacto = false;
	@track showPactoAntenupcialSeparacao = false;
	@track showAlertPacto = false;
	@track vigenciaMarriedIsAfter77 = false;
	@track typeCertidao = "";
	@track disableBook = true;
	@track disableMatricula = true;	
	@track disableRegimeMarried = true;
	@track disableRegimeStableUnion = true;
	@track showCertidaoToggle = false;
	@track showPactoAntenupcialToggle = false;
	@track showSeparacaoToggle = false;
	@track showSeparacaoPactoAntenupcialToggle = false;
	showMarriedSectionVar = false;
	showStableunionSectionVar = false;
	hideRelationshipSectionVar = false;
    regimeOptions = regimeOptions;
    typeOptions = typeOptions;
	@api index;

	@api 
	get relationship(){}
	set relationship( data ) {

		if ( !data ) return;

		this.relationshipEdited = JSON.parse(JSON.stringify(data));
		this.disableOrEnableRegime();
	}

	showRelationshipSection(){
		this.showRelationshipSectionVar = !this.showRelationshipSectionVar;
	}
	showMarriedSection(){
		this.showMarriedSectionVar = !this.showMarriedSectionVar;
	}
	showStableunionSection(){
		this.showStableunionSectionVar = !this.showStableunionSectionVar;
	}

	handleCertidao(event){
		this.showCertidao = event.target.checked;	
	}

	handlePacto(event){
		this.showPactoAntenupcial = event.target.checked;
		if(!event.target.checked){
			this.showRegistroPacto = false;
		}
			this.showAlertPacto = event.target.checked;
	}
	handlePactoSeparacao(event){
		this.showPactoAntenupcialSeparacao = event.target.checked;
		if(!event.target.checked){
			this.showRegistroPactoSeparacao = false;
			this.showAlertPactoSeparacao = false;	
		}	
	}

	handleRegistroPacto(event){
		this.showRegistroPacto = event.target.checked;
		this.showAlertPacto = !event.target.checked;
	}

	handleRegistroPactoSeparacao(event){
		this.showRegistroPactoSeparacao = event.target.checked;
		this.showAlertPactoSeparacao = !event.target.checked;
	}

	handleSeparacao(event){
		this.showSeparacao = event.target.checked;
		if(!event.target.checked){
			this.showRegistroPactoSeparacao = false;
		}
		this.showAlertPactoSeparacao = !event.target.checked;
		this.showPactoAntenupcialSeparacao = !event.target.checked;
		this.showSeparacaoPactoAntenupcialToggle = !event.target.checked;
	}

	handleRegistroUniao(event){
		this.showRegistroUniao = event.target.checked;
	}

	handleDateMarried(event){

		let selectedDate = event.detail.value;
		this.disableRegimeMarried = false;

		let dateConvert = new Date( selectedDate.substring(0,4), (selectedDate.substring(5,7)-1), selectedDate.substring(8,10), );
		dateConvert.setHours( 0 );

		let dateVigente = new Date(1977,11,26);

		this.vigenciaMarriedIsAfter77 = ( dateConvert >= dateVigente ) ? true : false;

		this.relationshipEdited.marriageDate = selectedDate;
		this.updateRelationship();
	}

	handleDateStableUnion(event){

		let selectedDate = event.detail.value;

		this.disableRegimeStableUnion = ( !selectedDate ) ? false : true;
		
		this.relationshipEdited.stableUnionDeclarationDeed.date = selectedDate;
	}

	handleTypeCertidao(event) {

		let typeCertidao = event.detail.value;

		if ( typeCertidao === 'BOOK_DETAILS' ){

			this.disableMatricula = true;
			this.disableBook = false;	
			const elementMatricula = this.template.querySelector('[data-id="matriculaId"]'); 
			elementMatricula.value = "";
			
		}else if(typeCertidao === 'REGISTRATION') {

			this.disableBook = true;
			this.disableMatricula = false;
			const elementBook = this.template.querySelector('[data-id="bookId"]');
			elementBook.value = "";
			const elementSheet = this.template.querySelector('[data-id="sheetId"]');
			elementSheet.value = "";
		}

		this.relationshipEdited.weddingCertificate.type = typeCertidao;
	}

	handleRegimes(event) {

		this.relationshipEdited.regimen = event.detail.value;

		this.updateRelationship();
		this.enableOrDisableFields();
	}

	handleBookCertidao( event ) {

		this.relationshipEdited.weddingCertificate.entryBook = event.detail.value;
		this.updateRelationship();
	}

	handleSheetCertidao( event ) {

		this.relationshipEdited.weddingCertificate.entrySheet = event.detail.value;
		this.updateRelationship();
	}

	handleRegistrationNumber( event ) {

		this.relationshipEdited.weddingCertificate.registrationNumber = event.detail.value;
		this.updateRelationship();
	}

	handleRegistrationAt( event ) {

		this.relationshipEdited.weddingCertificate.cartorioName = event.detail.value;
		this.updateRelationship();
	}

	updateRelationship() {

		this.dispatchEvent(new CustomEvent('updaterelationship', { detail: { relationship : this.relationshipEdited,
																			 index : this.index } } ) );
	}

	disableOrEnableRegime() {

		this.disableRegimeMarried = ( this.relationshipEdited?.marriageDate != null ) ? false : true;
		this.disableRegimeStableUnion = ( this.relationshipEdited?.stableUnionDeclarationDeed?.date != null ) ? false : true;

	}

	enableOrDisableFields() {

		let actualRegimenToEnable = this.relationshipEdited.regimen + '_ENABLE' + ( this.vigenciaMarriedIsAfter77 ? '' : '_77');

		let fieldsToEnable = enableOrDisableByRegimes.get(actualRegimenToEnable);

		for ( let field of fieldsToEnable ) {

			this[field] = true;
		}

		let actualRegimenToDisable = this.relationshipEdited.regimen + '_DISABLE' + ( this.vigenciaMarriedIsAfter77 ? '' : '_77');

		let fieldsToDisable = enableOrDisableByRegimes.get(actualRegimenToDisable);

		for ( let field of fieldsToDisable ) {

			this[field] = false;
		}

		this.resetToggles();
	}

	resetToggles() {

		if ( this.showCertidaoToggle ) {

			const elementCertidao = this.template.querySelector('[data-id="certidaoToggleId"]'); 
			if ( elementCertidao ) elementCertidao.checked = false;
		}

		if ( this.showPactoAntenupcialToggle ) {

			const elementPacto = this.template.querySelector('[data-id="pactoToggleId"]'); 
			if ( elementPacto ) elementPacto.checked = false;
		}
		if ( this.showSeparacaoPactoAntenupcialToggle ) {

			const elementPactoSeparacao = this.template.querySelector('[data-id="separacaoPactoToggleId"]'); 
			if ( elementPactoSeparacao ) elementPactoSeparacao.checked = true;
		}
	}

}