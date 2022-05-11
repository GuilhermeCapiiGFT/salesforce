import { LightningElement, track, api } from 'lwc';
import { participationOptions, genderOptions, documentTypeOptions, relationshipDic} from './minuatorPersonCustomerOptions';

/**
 * @author Nathalia Rosa - GFT Brasil
 */
export default class MinuatorPersonCustomer extends LightningElement {
	@api tabName;
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
	maritalStatus = '';
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
		this.personEdited = JSON.parse(JSON.stringify(data));
		this.showParticipation()
		this.masksFields();
		this.personEdited.sources.fullName = 'Origem: ' + this.personEdited.sources.name;
	}

	showParticipation() {		
		if(this.personEdited.consentingParticipant && this.personEdited.propertyOwner){
			this.labelOption = '3 selecionados';
		} else if(this.personEdited.propertyOwner || this.personEdited.consentingParticipant){
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

	updateCustomer(){
		this.dispatchEvent(new CustomEvent('updatecustomer', { detail: { customer : this.personEdited } } ) );
	}

	handleChangeGender(event){
        this.personEdited.gender = event.target.value;   
		this.updateCustomer();    
    }	

	handleDocumentType(event){
        this.personEdited.identityDocument.type = event.target.value;
        this.updateCustomer();
    }	

	handleDocumentNumber(event){
        this.personEdited.identityDocument.number = event.target.value;
        this.updateCustomer();
    }
	
	handleDocumentIssuingBody(event){
        this.personEdited.identityDocument.issuingBody = event.target.value;
		this.updateCustomer();
    }

	handleDocumentExpeditionDate(event){
        this.personEdited.identityDocument.expeditionDate = event.target.value;
        this.updateCustomer();
    }		

	handleConsentingParticipant(event){
        this.personEdited.consentingParticipant = event.target.checked;
		this.showParticipation();
        this.updateCustomer();
    }	

	handlePropertyOwner(event){
        this.personEdited.propertyOwner = event.target.checked;
		this.showParticipation();
        this.updateCustomer();
    }	

	masksFields(){
		let cpf = this.personEdited.mainDocument.number;
		let listName = this.personEdited.name.split(' ');
		this.formatedName = listName[0] + ' ' + listName[listName.length-1]; 
		this.cellPhone = '(' + this.personEdited.cellPhone.substring(0,2) + ') ' + this.personEdited.cellPhone.substring(2,3) + ' ' + this.personEdited.cellPhone.substring(3,7) + '-' + this.personEdited.cellPhone.substring(7,11);
        this.cpf = cpf.substring(0,3) + '.' + cpf.substring(3,6) + '.' + cpf.substring(6,9) + '-' + cpf.substring(9,11);
		this.maritalStatus = relationshipDic.get(this.personEdited.maritalStatus);
		
	}
	handleGetNameTab(event){	
		this.tabName = event.target.name;			
		this.dispatchEvent(new CustomEvent('handlegetnametab', { detail: { namePersonTab : this.formatedName } } ) );	
		
    }
	
    connectedCallback(){

   }
}