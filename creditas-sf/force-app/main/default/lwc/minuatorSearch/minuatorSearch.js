import { LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLead from '@salesforce/apex/MinuatorSearchController.getLead';

const DELAY = 300;


export default class MinuatorSearch extends LightningElement {
    @track idRecord;
    searchValue = '';
    

    // update searchValue var when input field value change
    searchKeyword(event) {
        this.searchValue = event.target.value;
    }
 
    // call apex method on button click 
    handleSearchKeyword(event) {
        
        if (event.target.lenth == 7) {
            getLead({
                friendlyId: this.searchValue
                })
                .then(result => {
                    // set @track contacts variable with return contact list from server  
                    this.idRecord = result;
                })
                .catch(error => {
                   
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.idRecord = null;
                });
        } 
          
        }

        handleInputChange(event){
            window.clearTimeout(this.delayTimeout);
            const searchKey = event.target.value;
    
            //valida se o valor informado não é composto apenas por espaço.
            if(!/^ *$/.test(searchKey)){
                this.delayTimeout = setTimeout(() => {
                    if(searchKey.length >= 2){
                        search({ 
                            objectName : this.objName,
                            searchTerm : searchKey 
                        })
                        .then(result => {
                            this.searchRecords = JSON.parse(JSON.stringify(result));
                        })
                        .catch(error => {
                            console.error('Error:', error);
                        })
                        .finally( ()=>{
                            //this.isLoading = false;
                        });
                    }
                }, DELAY);
            }
        }

    
    

   /* @track error;    
    @track opps = [];
    @track showOppLookup = false;   
    @track selectedOppId;
    @track disabledLeadInput= false;
    @track leadObj = {};
    @track varLead = '';

    connectedCallback(){
        this.searchLead()

    }

    searchLead(){          
        var formattedId = this.varLead.replace(/[`qwertyuiopasdfghjklçzxcvbnm~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
        if (!formattedId.length){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'preencha o campo Lead Id.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);           
            return;
        }
        if (formattedId.length != 7){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'Lead inválido.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);            
            return;
        }    

        getLead({friendlyId: formattedId}) 
            .then(result => { 
                let friendlyIdResult = JSON.parse(result)
                if(!friendlyIdResult.erro){
                    this.disabledLeadInput = true;
                    this.leadObj = friendlyIdResult
                    this.name = friendlyIdResult.cls_persons.name
                    this.friendlyId = friendlyIdResult.friendlyId

                    this.varLead = formattedId.charAt(0)+formattedId.charAt(1)+'.'+
                    formattedId.charAt(2)+formattedId.charAt(3)+formattedId.charAt(4)+'-'+
                    formattedId.charAt(5)+formattedId.charAt(6)+formattedId.charAt(7); 
                } else {
                    const event = new ShowToastEvent({
                        title: 'Erro',
                        message: 'Lead inválido.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
                
            })
            .catch(error => {
                this.disabledLeadInput = false;                
            });
    }

    handleInputChange(event){
        let inputName = event.target.name;
        let inputValue = event.target.value;
        if(inputName == 'lead'){
            this.varLead = inputValue;
        } else if(inputName == 'name'){
            this.name = this.leadObj.cls_persons.name = inputValue;
        } else if(inputName == 'id'){
            this.friendlyId = this.leadObj.friendlyId = inputValue;         
        }
    } 
    handleSelect(event){
        let recordId = event.currentTarget.dataset.recordId;     
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    recordId : recordId,
                    mappedId: this.mappedField
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }    
 
 //On Opportunity lookup change
    handleOppSelection(event){
        let selectedOption = event.detail;
        this.selectedOppId = selectedOption.value;
    }*/


}