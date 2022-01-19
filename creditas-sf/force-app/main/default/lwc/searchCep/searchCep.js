import { LightningElement, track, api} from 'lwc';
import searchCepAddress from '@salesforce/apex/searchCepController.getCepInfo';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ADDRESSES_OBJECT from '@salesforce/schema/Addresses__c';
import ADDRESSES_ACCOUNT_ID from '@salesforce/schema/Addresses__c.Account__c';
import ADDRESSES_STREET from '@salesforce/schema/Addresses__c.Street__c';
import ADDRESSES_NEIGHBORHOOD from '@salesforce/schema/Addresses__c.Neighborhood__c';
import ADDRESSES_CITY from '@salesforce/schema/Addresses__c.AreaLevel2__c';
import ADDRESSES_UF from '@salesforce/schema/Addresses__c.AreaLevel1__c';
import ADDRESSES_NUMBER from '@salesforce/schema/Addresses__c.StreetNumber__c';
import ADDRESSES_COMPLEMENT from '@salesforce/schema/Addresses__c.Complement__c';
import ADDRESSES_POSTALCODE from '@salesforce/schema/Addresses__c.PostalCode__c';


export default class SearchCep extends LightningElement {
    @api recordId;
    @track varCep = '';
    @track disabledCepInput= false;
    @track addressObj = {};
    @track bairro = '';
    @track logradouro = '';
    @track numero = '';
    @track complemento = '';
    @track cidade = '';
    @track estado = '';
    @track showLoadingScreen = false;
    @track showComponent = true;
    @track spinnerMessage = '';

    connectedCallback(){
    }

    searchCep(){
        this.spinnerMessage = 'Buscando endereço associado ao CEP';
        this.showLoadingScreen = true;
        this.showComponent = false;

        var formattedCep = this.varCep.replace(/[`qwertyuiopasdfghjklçzxcvbnm~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
        if (!formattedCep.length){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'preencha o campo CEP.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

            this.showLoadingScreen = false;
            this.showComponent = true;
            return;
        }
        if (formattedCep.length != 8){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'CEP inválido.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

            this.showLoadingScreen = false;
            this.showComponent = true;
            return;
        }

        searchCepAddress({cep: formattedCep}) 
        .then(result => { 
            let addressResult = JSON.parse(result)
            if(!addressResult.erro){
                this.disabledCepInput = true;
                this.addressObj = addressResult
                this.bairro = addressResult.bairro
                this.logradouro = addressResult.logradouro
                this.cidade = addressResult.localidade
                this.estado = addressResult.uf
                this.varCep = formattedCep.charAt(0)+formattedCep.charAt(1)+'.'+
                formattedCep.charAt(2)+formattedCep.charAt(3)+formattedCep.charAt(4)+'-'+   
                formattedCep.charAt(5)+formattedCep.charAt(6)+formattedCep.charAt(7); 
            } else {
                const event = new ShowToastEvent({
                    title: 'Erro',
                    message: 'CEP inválido.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
            this.showLoadingScreen = false;
            this.showComponent = true;

        })
        .catch(error => {
            this.disabledCepInput = false;

            this.showLoadingScreen = false;
            this.showComponent = true;
        });
    }

    reset(){
        this.addressObj = ''
        this.bairro = ''
        this.logradouro = ''
        this.cidade = ''
        this.estado = ''
        this.varCep = ''

        this.disabledCepInput = false;
    }

    save(){
        this.spinnerMessage = 'Adicionando Endereço à conta';
        this.showLoadingScreen = true;
        this.showComponent = false;

        var formattedCep = this.varCep.replace(/[`qwertyuiopasdfghjklçzxcvbnm~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
        if (!formattedCep.length){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'Preencha o campo CEP.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.showLoadingScreen = false;
            this.showComponent = true;
            return;
        }
        if (formattedCep.length != 8){
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'CEP Inválido.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.showLoadingScreen = false;
            this.showComponent = true;
            return;
        }
        
        const fields = {};
        fields[ADDRESSES_ACCOUNT_ID.fieldApiName] = this.recordId;
        fields[ADDRESSES_STREET.fieldApiName] = this.logradouro;
        fields[ADDRESSES_NEIGHBORHOOD.fieldApiName] = this.bairro;
        fields[ADDRESSES_CITY.fieldApiName] = this.cidade;
        fields[ADDRESSES_UF.fieldApiName] = this.estado;
        fields[ADDRESSES_NUMBER.fieldApiName] = this.numero;
        fields[ADDRESSES_COMPLEMENT.fieldApiName] = this.complemento;
        fields[ADDRESSES_POSTALCODE.fieldApiName] = this.varCep;

        const recordInput = { apiName: ADDRESSES_OBJECT.objectApiName, fields };

        createRecord(recordInput)
        .then(address => {
            this.showLoadingScreen = false;
            this.showComponent = true;

            const event = new ShowToastEvent({
                title: 'Êxito',
                message: 'Endereço Adicionado com sucesso',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            this.showLoadingScreen = false;
            this.showComponent = true;

            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'A inserção do novo endereço falhou. Tente novamente.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        });
    }

    handleInputChange(event){
        let inputName = event.target.name;
        let inputValue = event.target.value;
        if(inputName == 'cep'){
            this.varCep = inputValue;
        } else if(inputName == 'bairro'){
            this.bairro = this.addressObj.bairro = inputValue;
        } else if(inputName == 'logradouro'){
            this.logradouro = this.addressObj.logradouro = inputValue;           
        } else if(inputName == 'cidade'){
            this.cidade = this.addressObj.localidade = inputValue;
        } else if(inputName == 'estado'){
            this.estado = this.addressObj.uf = inputValue;
        } else if(inputName == 'complemento'){
            this.complemento = this.addressObj.complemento = inputValue;
        } else if(inputName == 'numero'){
            this.numero = this.addressObj.numero = inputValue;
        }
    }
    
}