import { LightningElement, track, api} from 'lwc';
import modal from "@salesforce/resourceUrl/customSyncModal";
import { loadStyle } from "lightning/platformResourceLoader";

export default class CopiaMinutadorPerson extends LightningElement {
    personString = '';
    @track personObject = {};
	@track persons = [];
	showPersonSectionVar = false;
	showRelationshipSectionVar = false;
	isModalOpen = false;
	personProgressRingPercent = 0;
	personSectionIcon = "utility:chevronright";
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
		{ label: 'Comunhão total de bens', value: 'total' }
	];
	

	openSyncModal(){
		this.isModalOpen = true;
	}

	closeSyncModal(){
		this.isModalOpen = false;
	}

	showPersonSection(){
		this.showPersonSectionVar = !this.showPersonSectionVar;
		this.personSectionIcon = this.showPersonSectionVar ? "utility:chevrondown" : "utility:chevronright";
	}

	showRelationshipSection(){
		this.showRelationshipSectionVar = !this.showRelationshipSectionVar
	}

	showPersonDataSection(event){
		let actualPerson = this.persons.filter(person => { return person.name === event.currentTarget.textContent });
		actualPerson[0].showSection = !actualPerson[0].showSection
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
		'            "gender": null,'+
		'            "cellPhone": "45999416710",'+
		'            "birthdate": "1973-03-03",'+
		'            "nationality": null,'+
		'            "email": "meri_ferronato@hotmail.com",'+
		'            "profession": "sócia de empresa",'+
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
		'            "gender": null,'+
		'            "cellPhone": "45999416710",'+
		'            "birthdate": "1969-01-18",'+
		'            "nationality": null,'+
		'            "email": "meri_ferronato@hotmail.com",'+
		'            "profession": "sócio de empresa",'+
		'            "fatherName": "OCTAVIO PAGANINI",'+
		'            "motherName": "ORLANDINA NECKEL PAGANINI",'+
		'            "documents": ['+
		'                {'+
		'                    "type": "RG",'+
		'                    "expeditionDate": null,'+
		'                    "number": "4.257.811-8",'+
		'                    "issuingBody": "SESP/PR",'+
		'                    "isMainDocument": false'+
		'                },'+
		'                {'+
		'                    "type": "CPF",'+
		'                    "expeditionDate": null,'+
		'                    "number": "66283019900",'+
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
		'            "regime": null,'+
		'            "marriageDate": null,'+
		'            "compulsorySeparation": null,'+
		'            "registerPrenuptialAgreement": null,'+
		'            "prenuptialAgreement": null,'+
		'            "maritalStatus": "married",'+
		'            "cohabitant": false,'+
		'            "participant1": {'+
		'                "name": "MÉRI TERESINHA FERRONATO PAGANINI",'+
		'                "gender": null,'+
		'                "cellPhone": "45999416710",'+
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
		'                "name": "NERO PAGANINI",'+
		'                "gender": null,'+
		'                "cellPhone": "45999416710",'+
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
			this.persons.push(person);	
		});
		



        /*
        ({
    // Create SVG, path, populate with default values from controller
    render: function(component, helper) {
        var result = this.superRender(),
            xmlns = "http://www.w3.org/2000/svg",
            updateContainer = result[0].querySelector("#progressContainer"),
            value = component.get("v.value"),
            dValue = "M 1 0 A 1 1 0 "+Math.floor(value / 50)+" 1 "+
                Math.cos(2 * Math.PI * value / 100)+" "+
                Math.sin(2 * Math.PI * value / 100)+" L 0 0",
            svg = document.createElementNS(xmlns,"svg"),
            path = document.createElementNS(xmlns,"path");
        svg.setAttributeNS(null,"viewBox", "-1 -1 2 2");
        path.setAttributeNS(null, "class", "slds-progress-ring__path");
        path.setAttributeNS(null, "d", dValue);
        svg.appendChild(path);
        updateContainer.appendChild(svg);
        return result;
    },
    // Update the progress bar on a rerender event
    rerender: function(component, helper) {
        var value = component.get("v.value"),
            dValue = "M 1 0 A 1 1 0 "+Math.floor(value / 50)+" 1 "+
                Math.cos(2 * Math.PI * value / 100)+" "+
                Math.sin(2 * Math.PI * value / 100)+" L 0 0",
            svg = component.getElement().querySelector("svg"),
            path = svg.childNodes[0];
        this.superRerender();
        path.setAttributeNS(null, "d", dValue);
    }
})
        */
    }
}