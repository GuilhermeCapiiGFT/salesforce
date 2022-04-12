import { LightningElement, track, api } from 'lwc';
import { participationOptions, genderOptions, documentTypeOptions } from './minuatorPersonCustomerOptions';

/**
 * @author Nathalia Rosa - GFT Brasil
 */
export default class MinuatorPersonCustomer extends LightningElement {

    @api index;
   	personEdited;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
	@track txtclassnameAddress = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';	
	@track ownerValue = false;
	@track consentingValue = false;
	@track incomeComposeValue = true;
	@track labelOption = 'Compõe renda';
    @track personObject = {};
	@track marriageObject = {};
	@track persons = [];	
	@track checkProprietario = false;
	@track checkCompoeRenda = true;	
	@track singlePerson = [];

	personString = '';	
	value = ['Compõe renda'];
	showPersonSectionVar = true;	
	personRelationship = {};
	marriageRelationship = {};
	personProgressRingPercent = 0;
	personSectionIcon = "utility:chevronright";

	participationOptions = participationOptions;
	genderOptions = genderOptions;
	documentTypeOptions = documentTypeOptions;

	@api
	get person() {}
	set person( data ){
		this.personEdited = JSON.parse( JSON.stringify( data ) );
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

	showPersonDataSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
		let mainDocumentNumber = this.personEdited.mainDocument.number;		
		this.dispatchEvent(new CustomEvent('showcustomer', { detail: { mainDocumentNumber : mainDocumentNumber } } ) );
	}

	
	onChangePersonInput(event){
        let splittedId =  event.currentTarget.dataset.id.split('_');
        let actualPersonId = splittedId[0];
        let actualFieldName = splittedId[1];
        let actualPerson = this.persons.filter(person => { return person.id === actualPersonId })[0];
        actualPerson[actualFieldName] = event.target.value;	
    }

	handleChangeGender(event){
        this.person.gender =  event.target.detail;
        this.dispatchEvent(new CustomEvent('onupdatecustomer', { detail: { customer : this.person } } ) );
    }	

	handleDocumentType(event){
        this.person.identityDocument.type =  event.target.detail;
        this.dispatchEvent(new CustomEvent('onupdatetypedocument', { detail: { customer : this.person } } ) );
    }	

	handleDocumentNumber(event){
        this.person.identityDocument.number =  event.target.detail;
        this.dispatchEvent(new CustomEvent('onupdatenumberdocument', { detail: { customer : this.person } } ) );
    }
	
	handleDocumentIssuingBody(event){
        this.person.identityDocument.issuingBody =  event.target.detail;
        this.dispatchEvent(new CustomEvent('onupdateissuingbody', { detail: { customer : this.person } } ) );
    }
	handleDocumentExpeditionDate(event){
        this.person.identityDocument.expeditionDate =  event.target.detail;
        this.dispatchEvent(new CustomEvent('onupdatedocumentexpeditiondate', { detail: { customer : this.person } } ) );
    }
	

   connectedCallback(){

   }
}