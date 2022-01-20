import { LightningElement,wire,api,track } from 'lwc';
import getAllObjList from '@salesforce/apex/GetAllObjects.getAllObjList';



export default class Teste extends LightningElement {

    @track valueScreen = 'Escolha uma opção!';
    @track options = [];

    //Wire
     @wire(getAllObjList) oppData({error, data}){
         if(data){
              this.options = data;
              console.log('1: ' +  this.options);
 
         }else if(error){
             console.log('ERRO: ' + error);
         }
     };
 

     selectedOptionValue;
     //selectedOptionLabel;

     handleOptionChange(event) {
        this.selectedOptionValue = event.detail.value;
        this.valueScreen = event.detail.value;
        //this.selectedOptionLabel = event.detail.label;
    }

}