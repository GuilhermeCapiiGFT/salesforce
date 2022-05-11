import { LightningElement, wire } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentApiController.getDocuments';

export default class DocumentsDataTable extends LightningElement {
    columns = [
        { label: 'Data', fieldName: 'novaData', type: 'date' },
        { label: 'Visualizar', fieldName: 'url', type: 'url', typeAttributes: {label: {fieldName: 'teste'}}}
    ];
    data = [];
    @wire(getDocuments, { opportunityExternalId: '', recordTypeName: 'AutoFin' })
    documents(data, error) {
        if (data) {
            if (data.data){
                this.data = data.data.items;
                this.data.novaData = data.data.items.details.formattedCreatedAt;
                console.log('Documentos', this.data);
            }
        }
        else if (error) {
            console.error(error);
        }
    };

    connectedCallback() {

    };
}