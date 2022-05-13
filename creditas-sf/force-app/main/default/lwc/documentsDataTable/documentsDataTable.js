import { LightningElement, wire, track } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentApiController.getDocuments';

export default class DocumentsDataTable extends LightningElement {
    columns = [
        { label: 'Data', fieldName: 'formattedCreatedAt', type: 'datetime' },
        { label: 'Visualizar', fieldName: 'url', type: 'url', typeAttributes: {label: 'Link'},"cellAttributes":{"iconName":"utility:preview"}}
    ];
    data = [];
    @track showTable = false;
    @wire(getDocuments, { opportunityExternalId: '', recordTypeName: 'AutoFin' })
    documents(data, error) {
        if (data) {
            if (data.data){
                this.data = data.data.items;
                if(this.data.length > 0){
                    this.showTable = true;
                }
            }
        }
        else if (error) {
            console.error(error);
            this.showTable = false;
        }
    };

}