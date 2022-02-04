import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityInfo from '@salesforce/apex/formalizationAnalysisController.getOpportunnityInfo';

//CONSTANTS
const CHEVRON_RIGHT = 'utility:chevronright';
const CHEVRON_DOWN = 'utility:chevrondown';
const VARIANT_BASE = 'base-autocomplete';
const VARIANT_EXPIRED = 'expired';
const VARIANT_WARNING = 'warning';
export default class FormalizationAnalysis extends LightningElement {
    @api recordId;
    opportunity;
    error;
    //ProgressRing Variables
    p0Progress = 0;
    p1Progress = 0;
    p2Progress = 0;
    p3Progress = 0;
    p4Progress = 0;
    p5Progress = 0;
    p6Progress = 0;
    p0Variant = VARIANT_BASE;
    p1Variant = VARIANT_BASE;
    p2Variant = VARIANT_BASE;
    p3Variant = VARIANT_BASE;
    p4Variant = VARIANT_BASE;
    p5Variant = VARIANT_BASE;
    p6Variant = VARIANT_BASE;
    //Save button Variables
    p0Disabled = true;
    p1Disabled = true;
    //Accordeon Variables
    iconName0 = CHEVRON_DOWN;
    iconName1 = CHEVRON_RIGHT;
    iconName2 = CHEVRON_RIGHT;
    //eventResponses
    eventResponsesGeral = new Map();
    eventResponsesAddress = new Map();
    
    items = [ 
        {id: 1, inputValue: "Joao", inputLabel: "Nome do Pai", inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 2, inputValue: "Maria", inputLabel: "Nome da Mãe", inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 3, inputValue: "111.222.333-44", inputLabel: "CPF",inputDisabled: true, inputType: 'text', inputSection: 'Geral'}, 
        {id: 4, inputValue: "33.452.132-12", inputLabel: "RG", inputDisabled: false, inputType: 'text', inputSection: 'Geral'}];

    items2 = [ 
        {id: 1, inputValue: "99.040-420", inputLabel: "CEP", inputDisabled: false, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 2, inputValue: "Centro", inputLabel: "Bairro", inputDisabled: true, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 3, inputValue: "SP", inputLabel: "Estado", inputDisabled: true, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 4, inputValue: "Brasil", inputLabel: "País",inputDisabled: true, inputType: 'text', inputSection: 'Endereço'},
        {id: 5, inputValue: "Rua Jose Garcia, 246", inputLabel: "Rua",inputDisabled: false, inputType: 'text', inputSection: 'Endereço'}, 
        {id: 6, inputValue: "34", inputLabel: "Numero", inputDisabled: false, inputType: 'number', inputSection: 'Endereço'}];

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
        if(event.detail.variant === 'reject'){
            
            this.showToast('Aviso!','Ao rejeitar o campo, a proposta inteira será rejeitada.','warning');
        }

        if(event.detail.section === 'Geral'){
       
            this.eventResponsesGeral.set(event.detail.position, event.detail.variant );
            this.readEventResponsesGeral();

        } else if(event.detail.section === 'Endereço'){
            this.eventResponsesAddress.set(event.detail.position, event.detail.variant );
            this.readEventResponsesAddress();

        }
        
    }

    readEventResponsesGeral(){
        let value = 100/this.items.length;
        
        this.p0Progress = this.eventResponsesGeral.size * value;
        
        let values = Array.from(this.eventResponsesGeral.values()) ;
        //let oldVariant = this.p0Variant;
        if(values.includes('reject')) { 
            this.p0Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p0Variant = VARIANT_WARNING;
        } else {
            this.p0Variant = VARIANT_BASE;
        }
        
        if(this.p0Progress >= 99.99){
            //this.handleProgressMarker(0, oldVariant);
            this.p0Disabled = false;
        }
        
        
    }
    
    readEventResponsesAddress(){
        let value = 100/this.items2.length;
        
        this.p1Progress = this.eventResponsesAddress.size * value;
       
        let values = Array.from(this.eventResponsesAddress.values()) ;
        //let oldVariant = this.p1Variant;
        
        if(values.includes('reject')) { 
            this.p1Variant = VARIANT_EXPIRED;
        } else if(values.includes('pendency')) { 
            this.p1Variant = VARIANT_WARNING;
        } else {
            this.p1Variant = VARIANT_BASE;
        }
        
        if(this.p1Progress >= 99.99){
            //this.handleProgressMarker(1, oldVariant);
            this.p1Disabled = false;
        }
        
    }

    handleProgressMarker(inputPosition, oldVariant){
        let markerControls = this.getElementsByClassName('slds-progress__marker');
        if(inputPosition === 0){
            markerControls[inputPosition].classList.remove(oldVariant);
            markerControls[inputPosition].classList.add(this.p0Variant);
        } else if (inputPosition === 1){
            markerControls[inputPosition].classList.remove(oldVariant);
            markerControls[inputPosition].classList.add(this.p1Variant);
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
        if(Array.from(elemControls[elementValue].classList).includes('slds-is-open')){
            elemControls[elementValue].classList.toggle('slds-is-open');
            return;
        }
        //let ariaControls = this.getElementsByClassName('slds-accordion__summary-action');
        let i;     
        for(i = 0;  i < elemControls.length; i++){
            elemControls[i].classList.remove('slds-is-open');
            //ariaControls[i].setAttribute('aria-expanded','false');
        }
        elemControls[elementValue].classList.add('slds-is-open');
        //ariaControls[elementValue].setAttribute('aria-expanded','true');
        //this.changeIcon(elementValue);

      }
        /*
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
        */
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