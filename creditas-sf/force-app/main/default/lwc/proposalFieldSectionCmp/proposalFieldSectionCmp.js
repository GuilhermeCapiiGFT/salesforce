import { LightningElement, track } from 'lwc';

export default class ProposalFieldSectionCmp extends LightningElement {
    
    @track field;

    onFieldApproval = (event) => {
        console.log('field section onApprove');
        console.log(event);
    }
    onFieldPendency = (event) => {
        console.log('field section pendencies')
        console.log(event);
    }
    onFieldReproval = (event) => {
        console.log('field section reproved')
        console.log(event);
    }
}