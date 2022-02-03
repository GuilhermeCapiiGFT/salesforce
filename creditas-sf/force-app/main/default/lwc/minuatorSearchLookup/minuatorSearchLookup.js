import { LightningElement, track, api } from 'lwc';
import getLead from '@salesforce/apex/MinuatorSearchController.getLead';

export default class MinuatorSearchLookup extends LightningElement {   
    @track showIconClean = false;
    @track showIconSearch = true;
    @track data;
    @track name = '';
    @track friendlyId = '';
    @track showList = false;
    @track selectedOption = '';
    @track showSpinner = false;
    searchText;

    getLeads(event){
        this.showIconClean = false;
        this.showIconSearch = true;
        this.showList = false;
        this.name = '';
        this.selectedOption = '';
        this.data = '';

        if(event.detail.value.length == 7){
            this.showSpinner = true;
            this.showList = true;
            
            getLead({friendlyId: event.detail.value})
            .then((result) => {
                console.log(result);
                this.data = JSON.parse(result);            
                this.name = this.data.persons[0].name;
                this.friendlyId = event.detail.value;
                console.log(event.detail.value);
                this.showList = true;                
                
            })
            .catch((error) => {
                           
                console.log(error.body.message);
                if(error.body.message == 'no content to map to Object due to end of input'){
                    this.dispatchEvent(new CustomEvent('notfound'));
                }else{
                    this.dispatchEvent(new CustomEvent('genericerror'));
                }
                this.showList = false;
            })
            .finally(() => {                
                this.showSpinner = false;
            });

            }  
        }

    onclickOption(event){
        console.log(event.currentTarget.dataset.id);
        this.selectedOption = event.currentTarget.dataset.id;
        this.showList = false;
        this.showIconSearch = false;
        this.showIconClean = true;        
    }

    removeSelectedOption(){
        this.showIconClean = false;
        this.showIconSearch = true;
        this.showList = false;
        this.name = '';
        this.selectedOption = '';
        this.data = '';
    }        
}