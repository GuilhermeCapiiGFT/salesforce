import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getContract from '@salesforce/apex/ProposalContractController.getRelatedFilesByRecordId';

export default class ProposalContract extends NavigationMixin(LightningElement) {

    disableBtnGenerateContract = false;
    disableBtnViewContract = true;
    disableBtnSendContract = true;
    dateContract = '';
    showContractGenerated = false;

    @api opportunityid;

    handlerViewContract(){
        const markerGenerateContract = this.template.querySelector('.slds-progress__marker.marker-view-contract');
        markerGenerateContract.classList.add("completed");
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
        const markerGenerateContract = this.template.querySelector('.slds-progress__marker.marker-send-contract');
        console.log({markerGenerateContract});
        markerGenerateContract.classList.add("completed");
        this.dispatchShowToast('Success','Contrato enviado com sucesso!','success');
    }
    handlerGenerateContract(){
        this.disableBtnGenerateContract = true;
        this.disableBtnViewContract = false;
        this.disableBtnSendContract = false;

        let dateNow = new Date();
        let splitDate = new Intl.DateTimeFormat('pt-BR', { dateStyle: 'short'}).format(dateNow);
        let splitHours = new Intl.DateTimeFormat('pt-BR', { timeStyle: 'short' }).format(dateNow);
        this.dateContract = splitDate +' às '+splitHours;

        const markerGenerateContract = this.template.querySelector('.slds-progress__marker.marker-generate-contract');
        console.log({markerGenerateContract});
        markerGenerateContract.classList.add("completed");
        this.showContractGenerated = true;
        this.dispatchShowToast('Success','Contrato gerado com sucesso!','success');
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