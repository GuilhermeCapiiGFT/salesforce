import { LightningElement, track, wire } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentApiController.getDocuments';

export default class DocumentsPreview extends LightningElement {
    
    data;
    @track showPreview = false;
    @track urlPreview;
    
    @wire(getDocuments, {opportunityExternalId: '', recordTypeName: 'AutoFin'}) documents;

    connectedCallback() {

    let payload = '{'+
    '  "items": ['+
    '    {'+
    '      "documentKey": "DOC-12345678",'+
    '      "details": {'+
    '        "file": "passport_cover",'+
    '        "extension": "jpg",'+
    '        "size": "3MB",'+
    '        "author": "Catherine Spotsky",'+
    '        "createdAt": "2020-06-01T15:20:35Z"'+
    '      },'+
    '      "metadata": {'+
    '        "classification": {'+
    '          "group": "PROOF_IDENTITY",'+
    '          "type": "CNH_BRAZILIAN_IDENTITY",'+
    '          "side": "FRONT"'+
    '        },'+
    '        "content": {'+
    '          "name": "Zé Jão da silva",'+
    '          "number": "666666-6"'+
    '        }'+
    '      },'+
    '      "creationContext": {'+
    '        "channel": "Whatsapp",'+
    '        "product": "AUTO_FIN",'+
    '        "application": {'+
    '          "id": "a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5",'+
    '          "participantsMainDocument": ['+
    '            12345678901'+
    '          ]'+
    '        }'+
    '      },'+
    '      "relations": ['+
    '        {'+
    '          "relatedWith": "DOC-1234",'+
    '          "relationType": "IS_OTHER_SIDE_OF"'+
    '        }'+
    '      ],'+
    '      "validations": ['+
    '        {'+
    '          "validationType": "UNKNOWN",'+
    '          "result": "APPROVED",'+
    '          "resultDetails": "Pending",'+
    '          "whoValidated": "OPERATOR",'+
    '          "productName": "AUTO_FIN",'+
    '          "validationDate": "2020-02-29T23:20:35Z"'+
    '        }'+
    '      ],'+
    '      "url": "https://i0.wp.com/trucao.com.br/wp-content/uploads/2017/12/cnh_cartao_destaque.jpg?fit=1920%2C1080&ssl=1"'+
    '    },'+
    '    {'+
    '      "documentKey": "DOC-12345678",'+
    '      "details": {'+
    '        "file": "passport_cover",'+
    '        "extension": "jpg",'+
    '        "size": "3MB",'+
    '        "author": "Catherine Spotsky",'+
    '        "createdAt": "2020-06-02T15:20:35Z"'+
    '      },'+
    '      "metadata": {'+
    '        "classification": {'+
    '          "group": "PROOF_IDENTITY",'+
    '          "type": "CNH_BRAZILIAN_IDENTITY",'+
    '          "side": "FRONT"'+
    '        },'+
    '        "content": {'+
    '          "name": "Catherine Spotsky",'+
    '          "number": "666666-6"'+
    '        }'+
    '      },'+
    '      "creationContext": {'+
    '        "channel": "Whatsapp",'+
    '        "product": "AUTO_FIN",'+
    '        "application": {'+
    '          "id": "a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5",'+
    '          "participantsMainDocument": ['+
    '            12345678901'+
    '          ]'+
    '        }'+
    '      },'+
    '      "relations": ['+
    '        {'+
    '          "relatedWith": "DOC-1234",'+
    '          "relationType": "IS_OTHER_SIDE_OF"'+
    '        }'+
    '      ],'+
    '      "validations": ['+
    '        {'+
    '          "validationType": "UNKNOWN",'+
    '          "result": "APPROVED",'+
    '          "resultDetails": "Pending",'+
    '          "whoValidated": "OPERATOR",'+
    '          "productName": "AUTO_FIN",'+
    '          "validationDate": "2020-02-29T23:20:35Z"'+
    '        }'+
    '      ],'+
    '      "url": "https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png"'+
    '    },'+
    '    {'+
    '      "documentKey": "DOC-12345678",'+
    '      "details": {'+
    '        "file": "passport_cover",'+
    '        "extension": "jpg",'+
    '        "size": "3MB",'+
    '        "author": "Catherine Spotsky",'+
    '        "createdAt": "2020-06-02T15:20:35Z"'+
    '      },'+
    '      "metadata": {'+
    '        "classification": {'+
    '          "group": "PROOF_IDENTITY",'+
    '          "type": "CNH_BRAZILIAN_IDENTITY",'+
    '          "side": "FRONT"'+
    '        },'+
    '        "content": {'+
    '          "name": "Catherine Spotsky",'+
    '          "number": "666666-6"'+
    '        }'+
    '      },'+
    '      "creationContext": {'+
    '        "channel": "Whatsapp",'+
    '        "product": "AUTO_FIN",'+
    '        "application": {'+
    '          "id": "a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5",'+
    '          "participantsMainDocument": ['+
    '            12345678901'+
    '          ]'+
    '        }'+
    '      },'+
    '      "relations": ['+
    '        {'+
    '          "relatedWith": "DOC-1234",'+
    '          "relationType": "IS_OTHER_SIDE_OF"'+
    '        }'+
    '      ],'+
    '      "validations": ['+
    '        {'+
    '          "validationType": "UNKNOWN",'+
    '          "result": "APPROVED",'+
    '          "resultDetails": "Pending",'+
    '          "whoValidated": "OPERATOR",'+
    '          "productName": "AUTO_FIN",'+
    '          "validationDate": "2020-02-29T23:20:35Z"'+
    '        }'+
    '      ],'+
    '      "url": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"'+
    '    }'+
    '  ]'+
    '}';
    this.data = JSON.parse( payload);
    };

    previewDocument(event) {
        this.showPreview = true;
        this.urlPreview = event.target.src;
        console.table('documentos:', this.documents);
    };

    closePreview(event){
        this.showPreview = false;
    };

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    };

}