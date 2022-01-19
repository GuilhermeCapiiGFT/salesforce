import { LightningElement, wire, track } from 'lwc';
import profiles from '@salesforce/apex/GetAllObjects.profiles';

export default class MultipickRequiredForTask extends LightningElement {

    
    @track allProfiles = [];
    @track values = [];
     
   
    @wire(profiles) oppData({error, data}){
        if(data){
             this.allProfiles = data;
        }else if(error){
            console.log('ERRO: ' + error);
        }
    };

    get options() {
        const items = [];
        this.allProfiles.forEach(element => {
            items.push({
                label: element,
                value: element,
            });
        })
        return items
    }

    handleChange(event) {
        this.values = event.detail.value;
    }
}