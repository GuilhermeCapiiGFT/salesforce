import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getContract from '@salesforce/apex/ProposalContractController.getRelatedFilesByRecordId';

export default class ProposalContract extends NavigationMixin(LightningElement) {

    disableBtnGenerateContract = false;
    disableBtnViewContract = true;
    disableBtnSendContract = true;
    disableBtnCorrectContract = true;
    dateContract = '';
    showContractGenerated = false;

    @api opportunityid;

    handlerViewContract(){
        
        console.log('opportunityId: '+this.opportunityid);
        getContract({ recordId : this.opportunityid})
        .then( result =>{
            console.log({result});

            (result != '') ? this.previewHandler(result): this.dispatchShowToast('Warning','Contrato não localizado!','warning');;
        }).catch(error =>{
            console.log('Erro: '+error);
        });
    }

    handlerSendContract(){
        
        this.dispatchShowToast('Success','Contrato enviado com sucesso!','success');
    }
    handlerGenerateContract(){
        this.disableBtnGenerateContract = true;
        this.disableBtnViewContract = false;
        this.disableBtnSendContract = false;
        this.disableBtnCorrectContract = false;

        let dateNow = new Date();
        let splitDate = new Intl.DateTimeFormat('pt-BR', { dateStyle: 'short'}).format(dateNow);
        let splitHours = new Intl.DateTimeFormat('pt-BR', { timeStyle: 'short' }).format(dateNow);
        this.dateContract = splitDate +' às '+splitHours;

       
        this.showContractGenerated = true;
        this.dispatchShowToast('Success','Contrato gerado com sucesso!','success');
    }
    handlerCorrectContract(){       
            this.disableBtnGenerateContract = true;
            this.disableBtnViewContract = true;
            this.disableBtnSendContract = true;
            this.disableBtnCorrectContract = true;
    }

    dispatchShowToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

    previewHandler(doccumentId){
        console.log(doccumentId)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: doccumentId
            }
        })
    }
}