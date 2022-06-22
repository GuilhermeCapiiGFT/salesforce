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
    get sobjectName(){
        return super.sobjectName;
    }
    set sobjectName(data){
        super.sobjectName = data;
    }
    @api
    get fields(){
        return super.fields;
    }
    set fields(fields){
        if(!fields) return;
        super.fields = JSON.parse(JSON.stringify(fields));
    }

}