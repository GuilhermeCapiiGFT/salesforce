import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityInfo from '@salesforce/apex/formalizationAnalysisController.getOpportunnityInfo';

 
export default class FormalizationAnalysis extends LightningElement {
    p1Progress = 0;
    @api recordId;
    opportunity;
    error;
    value = '';
    valor;
    tabIcon = 'utility:warning';
    isPendenciar = false;
    p1Progress = 0;
    p2Progress = 0;
    p3Progress = 0;
    isOpened = true;
    @track iconName0 = 'utility:chevrondown';
    @track iconName1 = 'utility:chevronright';
    @track iconName2 = 'utility:chevronright';
    
    get options() {
        return [
            { label: 'Aprovar', value: 'aprovar' },
            { label: 'Rejeitar', value: 'rejeitar' },
            { label: 'Pendenciar', value: 'pendenciar' },
        ];
    }
    items = [ {id: 1, name: "Joao", label: "Nome do Pai",showField: false}, {id:2, name: "Maria",label: "Nome da Mãe",showField: false}, {id: 3, name: "111.222.333-44", label: "CPF",showField: false}, {id:4, name: "33.452.132-12",label: "RG",showField: false}];

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

    handleChange(event){
        this.valor = event.detail.value;
        console.dir(event.detail);
        this.isPendenciar = event.detail.value === 'pendenciar' ? true : false;
        if(event.detail.value === 'rejeitar'){
            this.showToast('Aviso!','Ao rejeitar o campo a proposta toda será rejeitada!','warning');
            this.p1Progress = 0;
          }
        if(event.detail.value === 'aprovar'){
        this.p1Progress = 100;
        }
    }


    handleClick(event){
               
        let elementValue;
        if(event.target.value === undefined || event.target.localName === 'lightning-progress-ring'){
            elementValue = event.target.parentElement.value;
        } else {
            elementValue = event.target.value;
        }
        let elemControls = this.getElementsByClassName('slds-accordion__section');
        let ariaControls = this.getElementsByClassName('slds-accordion__summary-action');
        //let iconControls = this.getElementsByClassName('slds-var-m-right_xx-small');
        let i;     
        for(i = 0;  i < elemControls.length; i++){
            elemControls[i].classList.remove('slds-is-open');
            ariaControls[i].setAttribute('aria-expanded','false');
            /*
            iconControls[i].setAttribute('icon-name','utility:chevronright');
            iconControls[i].classList.remove('slds-icon-utility-chevrondown');
            iconControls[i].classList.add('slds-icon-utility-chevronright');
            */
        }
        elemControls[elementValue].classList.add('slds-is-open');
        ariaControls[elementValue].setAttribute('aria-expanded','true');
        this.changeIcon(elementValue);


        /*
        iconControls[event.target.parentElement.value].setAttribute('icon-name','utility:chevrondown');
        iconControls[event.target.parentElement.value].classList.remove('slds-icon-utility-chevronright');
        iconControls[event.target.parentElement.value].classList.add('slds-icon-utility-chevrondown');
        */
      }
      changeIcon(stringPos){
        if(stringPos === '0') {  
            this.iconName0 = 'utility:chevrondown';
            this.iconName1 = 'utility:chevronright';
            this.iconName2 = 'utility:chevronright';
        }
        if(stringPos === '1') {  
            this.iconName0 = 'utility:chevronright';
            this.iconName1 = 'utility:chevrondown';
            this.iconName2 = 'utility:chevronright';
         }
        if(stringPos === '2') {  
            this.iconName0 = 'utility:chevronright';
            this.iconName1 = 'utility:chevronright';
            this.iconName2 = 'utility:chevrondown'; 
        }
      }

      handleToggleSection(event) {
        //console.log(JSON.stringify(event.target));
        //console.log(JSON.stringify(event.detail));
        //let apendingChild = this.getElementsByClassName('sectionClass');
        //let i = 1;
        //console.log( apendingChild.size() );
        //console.dir( apendingChild[0].firstChild );
        //console.log(JSON.stringify( apendingChild[0].firstChild ));
        //console.log(JSON.stringify( apendingChild[0].innerHTML ));
        //console.log(JSON.stringify( apendingChild[0].children ));
        //apendingChild[0].appendChild(this.addNewChildElement(1));
    }
    /*
    handleClick(event){
        //console.log(JSON.stringify(event.target));
        //console.log(JSON.stringify(event.detail));
        let targetName = `tab${event.target.value}`;
        console.log(targetName);
        let apendingChild = this.getElementsByClassName(targetName);
        console.dir(apendingChild);

        let typeOfIcon = event.target.label.split(' ')[0];
        let iconName;
        if(typeOfIcon === 'Aprovar'){
            iconName = 'utility:success';
        } else if(typeOfIcon === 'Rejeitar'){
            iconName = 'utility:error';
        } else if (typeOfIcon === 'Pendenciar'){
            iconName = 'utility:warning';
        }
        console.log(iconName);
        console.dir( apendingChild[0].getAttribute('icon-name') );
        console.dir( apendingChild[0].getAttribute('iconName') );
        apendingChild[0].setAttribute('icon-name', iconName);
        apendingChild[0].re
        render();
        
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