import { api } from 'lwc'
import ProposalBaseComponent from 'c/proposalBaseComponent'
export default class ProposalSectionComponent extends ProposalBaseComponent {
    
    constructor(){
        super();
    }
    @api 
    get uniquekey(){
        return super.uniquekey;
    }
    set uniquekey(uniquekey) {
        super.uniquekey = uniquekey;
    }
    @api
    get fields(){
        return super.fields;
    }
    set fields(fields){
        super.fields = JSON.parse(JSON.stringify(fields));
    }

}