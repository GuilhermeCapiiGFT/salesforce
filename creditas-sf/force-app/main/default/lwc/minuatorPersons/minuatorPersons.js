import { LightningElement, track, api } from 'lwc';

const PERSONS_PROPERTY = 'persons';
const RELATIONSHIPS_PROPERTY = 'relationships';
export default class MinuatorPersons extends LightningElement {

    customers;	
    personSectionIcon = "utility:chevronright";
	addressSectionIcon = "utility:chevronright";
    txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    showPersonSectionVar = false;
    personSectionIcon = "utility:chevronright";
    relationships;
	selectedTab;
	@track currentTab = [];

	@api
	get persons(){}
	set persons( data ) {

		if ( !data ) return;		
		this.customers = JSON.parse(JSON.stringify(data.persons));
		this.personEdited = JSON.parse(JSON.stringify(data));
		this.relationships = JSON.parse(JSON.stringify(data.relationships));
		
	}
	
    connectedCallback() {

    }

    showPersonSection(event){
		this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';		
		this.showPersonSectionVar = !this.showPersonSectionVar;
		this.personSectionIcon = this.showPersonSectionVar ? "utility:chevrondown" : "utility:chevronright";			
	}

	handleShowCustomer( event ) {

		let customerSelected = event.detail.mainDocumentNumber;

		this.customers = this.customers.map( customer => { customer.showSection = ( customerSelected == customer.mainDocument.number) ? true : false;
													 	   return customer });
		this.customers = JSON.parse(JSON.stringify(this.customers));												
	}

	handleUpdateCustomer( event ) {

		let customerEdited = event.detail.customer;

		let customerIndex = this.customers.findIndex( customer => customer.mainDocument.number == customerEdited.mainDocument.number);

		this.customers[customerIndex] = customerEdited;

		this.updateOnContainer(PERSONS_PROPERTY);
	
	}

	handleUpdateRelationships( event ) {

		this.relationships = event.detail.relationships;

		this.updateOnContainer(RELATIONSHIPS_PROPERTY);
	}

	handleTabNameSelected( event ){

		this.selectedTab = event.detail.namePersonTab;
	}

	updateOnContainer( property) {

		let propertyName = ( property == RELATIONSHIPS_PROPERTY ) ? RELATIONSHIPS_PROPERTY : PERSONS_PROPERTY;

		let propertyToUpdate = ( property == RELATIONSHIPS_PROPERTY ) ? this.relationships : this.customers;

		this.dispatchEvent(new CustomEvent('updatepersons', { detail: { property : propertyToUpdate,
																		propertyName : propertyName } } ) );
	}
}