import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityInfo from '@salesforce/apex/formalizationAnalysisController.getOpportunnityInfo';

//CONSTANTS
const CHEVRON_RIGHT = 'utility:chevronright';
const CHEVRON_DOWN = 'utility:chevrondown';
const VARIANT_BASE = 'base-autocomplete';
class eventResponseWrapper {
    constructor(key,value){
        this.key = key,
        this.value = value
    }
}
export default class FormalizationAnalysis extends LightningElement {
    @api recordId;
    opportunity;
    error;
    //ProgressRing Variables
    p0Progress = 0;
    p1Progress = 0;
    p2Progress = 0;
    p0Variant = VARIANT_BASE;
    p1Variant = VARIANT_BASE;
    p2Variant = VARIANT_BASE;
    //Accordeon Variables
    iconName0 = CHEVRON_DOWN;
    iconName1 = CHEVRON_RIGHT;
    iconName2 = CHEVRON_RIGHT;
    //EventResponses
    eventResponses = new Map();
    
    items = [ 
        {id: 1, inputValue: "Joao", inputLabel: "Nome do Pai", inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 2, inputValue: "Maria", inputLabel: "Nome da Mãe", inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 3, inputValue: "111.222.333-44", inputLabel: "CPF",inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 4, inputValue: "33.452.132-12", inputLabel: "RG", inputDisabled: false, inputType: 'text', inputSection: 'Geral'}];

    items2 = [ 
        {id: 1, inputValue: "Centro", inputLabel: "Bairro", inputDisabled: true, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 2, inputValue: "SP", inputLabel: "Estado", inputDisabled: true, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 3, inputValue: "Brasil", inputLabel: "País",inputDisabled: true, inputType: 'text', inputSection: 'Endereço'},
        {id: 4, inputValue: "Rua Jose Garcia, 246", inputLabel: "Rua",inputDisabled: false, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 5, inputValue: "34", inputLabel: "Numero", inputDisabled: false, inputType: 'text', inputSection: 'Endereço'}];

    @wire (getOpportunityInfo, {aOpportunityId : '$recordId'} )
    opportunity({error,data}){
        if(data){
            this.opportunity = data;
            this.error = undefined
        } else if (error){
            this.opportunity = undefined;
            this.error = error;
        }
    }
    
    handleProgress(event){
        if(event.detail.section === 'Geral'){
       
            if(event.detail.variant === 'reject'){
                
                this.showToast('Aviso!','Ao rejeitar o campo, a proposta inteira será rejeitada.','warning');
            }
            this.eventResponses.set(event.detail.position, event.detail.variant );
            this.readEventResponses();
        }
        
    }

    readEventResponses(){
        let value = 100/this.items.length;
        
        this.p1Progress = this.eventResponses.size * value;
       
        let values = Array.from(this.eventResponses.values()) ;
        
        if(values.includes('reject')) { 
            this.p1Variant = 'expired';
        } else if(values.includes('pendency')) { 
            this.p1Variant = 'warning';
        } else {
            this.p1Variant = VARIANT_BASE;
        }
        
    }

    handleAccordeon(event){         
        let elementValue;
        if(event.target.value === undefined || event.target.localName === 'lightning-progress-ring'){
            elementValue = event.target.parentElement.value;
        } else {
            elementValue = event.target.value;
        }
        let elemControls = this.getElementsByClassName('slds-accordion__section');
        let ariaControls = this.getElementsByClassName('slds-accordion__summary-action');
        let i;     
        for(i = 0;  i < elemControls.length; i++){
            elemControls[i].classList.remove('slds-is-open');
            ariaControls[i].setAttribute('aria-expanded','false');
        }
        elemControls[elementValue].classList.add('slds-is-open');
        ariaControls[elementValue].setAttribute('aria-expanded','true');
        this.changeIcon(elementValue);

      }
      changeIcon(stringPos){
        if(stringPos === '0') {  
            this.iconName0 = CHEVRON_DOWN;
            this.iconName1 = CHEVRON_RIGHT;
            this.iconName2 = CHEVRON_RIGHT;
        }
        if(stringPos === '1') {  
            this.iconName0 = CHEVRON_RIGHT;
            this.iconName1 = CHEVRON_DOWN;
            this.iconName2 = CHEVRON_RIGHT;
         }
        if(stringPos === '2') {  
            this.iconName0 = CHEVRON_RIGHT;
            this.iconName1 = CHEVRON_RIGHT;
            this.iconName2 = CHEVRON_DOWN; 
        }
      }

    showToast(title, message, variant){
        const event = new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    
}