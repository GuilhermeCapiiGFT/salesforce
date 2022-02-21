import { LightningElement, track} from 'lwc';
import getLead from '@salesforce/apex/MinuatorSearchController.getLead';

export default class MinuatorSearchLookup extends LightningElement {   
    @track showIconClean = false;
    @track showIconSearch = true;
    @track data;
    @track error;
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
            let userId = event.detail.value.toUpperCase();
            event.detail.value = userId
          
            getLead({friendlyId: userId})
            .then((result) => {
                if(result.error){
                    this.error = result.message;                
                    if(result.message == 'Lead not found'){
                        this.dispatchEvent(new CustomEvent('notfound'));
                    }else if(result.message == 'Lead does not have credit analysis yet'){
                        this.dispatchEvent(new CustomEvent('nothavecredit')); 
                    }else{
                        this.dispatchEvent(new CustomEvent('genericerror'));
                    }
                    this.showList = false;
                } else {                    
                    this.data = result.infos;            
                    this.name = this.data.persons[0].name;
                    this.friendlyId = userId;                    
                    this.showList = true;               
                }              
            })
            .catch((error) => {             

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