import { LightningElement, track, api } from 'lwc';
const PERSONS_PROPERTY = 'persons';

export default class MinuatorPersonPageHeader extends LightningElement {
    namePageHeader;

    @api
	get persons() {}
	set persons( data ){
		this.namePageHeader = JSON.parse( JSON.stringify(data.persons) );
        this.participant1Name = this.namePageHeader[0].name;
        
        this.participant1CPF = this.namePageHeader[0].mainDocument.number;
        this.participant1CPF = this.participant1CPF.substring(0,3) + '.' + this.participant1CPF.substring(3,6) + '.' + this.participant1CPF.substring(6,9) + '-' + this.participant1CPF.substring(9,11);
	}
    
    connectedCallback(){

    }
}