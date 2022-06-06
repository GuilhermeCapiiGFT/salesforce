import { LightningElement, api } from 'lwc';

export default class DocumentsPreview extends LightningElement {
    
    data;
    showPreview = false;
    urlPreview;
    @api documents = [];
    
    previewDocument(event) {
        this.showPreview = true;
        this.urlPreview = event.target.src;
    };

    closePreview(event){
        this.showPreview = false;
    };

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    };

}