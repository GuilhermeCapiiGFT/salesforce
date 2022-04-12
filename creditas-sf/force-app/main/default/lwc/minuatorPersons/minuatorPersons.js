import { LightningElement, track, api } from 'lwc';

export default class MinuatorPersons extends LightningElement {

    @track customers = [];
    personSectionIcon = "utility:chevronright";
	addressSectionIcon = "utility:chevronright";
    txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    showPersonSectionVar = false;
    personSectionIcon = "utility:chevronright";

	@api
	get persons(){}
	set persons( data ) {

		if ( !data ) return;

		this.setCustomers(data);
	}

	setCustomers( data ) {

		if(!data) return;

		this.customers = JSON.parse(JSON.stringify(data.persons));

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

	}

}