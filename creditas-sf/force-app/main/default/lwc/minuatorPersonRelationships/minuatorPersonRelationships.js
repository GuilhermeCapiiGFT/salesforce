import { LightningElement, track, api} from 'lwc';
export default class MinuatorPersonRelationships extends LightningElement {

	customers;
	relationshipsEdited;
	@api showSection = false;

	@api 
	get relationships(){}
	set relationships( data ) {

		if ( !data ) return;

		this.relationshipsEdited = JSON.parse(JSON.stringify(data));
		this.buildRelationships();
	}

	@api 
	get persons(){}
	set persons( data ) {

		if ( !data ) return;

		this.customers = JSON.parse(JSON.stringify(data));
	}	

	buildRelationships() {

		let i = 0;

		this.relationshipsEdited = this.relationshipsEdited.map(relationship => {
			
			relationship.index = ++i;
			relationship.showSection = false;
			let participant1 = this.customers.find(person => person.mainDocument.number == relationship.participant1Cpf);
			let participant2 = this.customers.find(person => person.mainDocument.number == relationship.participant2Cpf);

			relationship.participant1Name = participant1.name;
			relationship.participant2Name = participant2.name;
				
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

	showRelationshipSection() {

		this.showSection = ( this.showSection == false ) ? true : false; 
	}

	handleUpdateRelationship( event ) {

		let index = event.detail.index;
		let relationship = event.detail.relationship;

		this.relationshipsEdited[index] = relationship;
		this.relationshipsEdited = [...this.relationshipsEdited];

		this.updateOnPersons();
	}

	updateOnPersons() {

		this.dispatchEvent(new CustomEvent('updaterelationships', { detail: { relationships: this.relationshipsEdited } } ) );
	}

}