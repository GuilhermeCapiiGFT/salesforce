import { LightningElement, track, api, wire } from 'lwc';
//import getTaskDetails from '@salesforce/apex/TaskDetailsController.getTaskDetails';

export default class TaskDetails extends LightningElement {
    @track taskDetails;
    error;
    @api recordId;
    @track picklistOptions = 
    [{
            value: 'Nenhum',
            label: 'Nenhum'
        },
        {
            value: 'Cancelada',
            label: 'Cancelada'
        },
        {
            value: 'Pendente',
            label: 'Pendente'
        },
        {
            value: 'Aguardando cliente',
            label: 'Aguardando cliente'
        },
        {
            value: 'Concluído',
            label: 'Concluído'
        
    }];

    // connectedCallback(){

    //     getTaskDetails() 
    //     .then(result => { 
    //         this.taskDetails = result;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //     });
    // }
}