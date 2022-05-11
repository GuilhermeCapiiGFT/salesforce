import { LightningElement, track, api} from 'lwc';

export default class MinuatorPersonAddresses extends LightningElement {

	@track singlePersons = [];
	showAddressSection = false;
	relationshipAddresses = [];
	customers = [];

	@api 
	get relationships(){}
	set relationships( data ) {

		if ( !data ) return;

		this.relationshipAddresses = JSON.parse(JSON.stringify(data));
		this.buildRelationshipAddresses();
	}

	@api 
	get persons(){}
	set persons( data ) {

		if ( !data ) return;

		this.customers = JSON.parse(JSON.stringify(data));
	}

	buildRelationshipAddresses() {

		let i = 0;

		this.relationshipAddresses = this.relationshipAddresses.map( relationship => {
			
			relationship.index = ++i;
			relationship.showSection = false;

			let participant1 = this.customers.find(person => person.mainDocument.number == relationship.participant1Cpf);
			let participant2 = this.customers.find(person => person.mainDocument.number == relationship.participant2Cpf);

			relationship.participant1Name = participant1.name;
			relationship.participant2Name = participant2.name;

			relationship.participant1Street = participant1.address.street;
			relationship.participant1Number = participant1.address.number;
			relationship.participant1Complement = participant1.address.complement;
			relationship.participant1Neighborhood = participant1.address.neighborhood;
			relationship.participant1City = participant1.address.city;
			relationship.participant1State = participant1.address.state;
			relationship.participant1Zipcode = participant1.address.zipcode;

			if ( relationship.type === "MARRIAGE") {

				relationship.typeScreen = (participant1.gender === "FEMALE") ? "Casada com" : "Casado com";
				relationship.maritalMarried = true;
				relationship.maritalStable = false;
				
			} else if(relationship.type === "STABLE_UNION") {
				
				relationship.typeScreen = "União estável com ";
				relationship.maritalMarried = false;
				relationship.maritalStable = true;

			}

			return relationship;
		});
	}

	showAddressSectionOn(event) {

		this.showAddressSection = ( this.showAddressSection ) ? false : true;
	}

}